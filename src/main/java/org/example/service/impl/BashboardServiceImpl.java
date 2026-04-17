package org.example.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import org.example.pojo.Result;
import org.example.pojo.SubtitleStyleConfig;
import org.example.service.BashboardService;
import org.example.service.QwenTtsService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

/**
 * /bashboard 页面整体流程实现。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BashboardServiceImpl implements BashboardService {

    private final QwenTtsService qwenTtsService;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    private OkHttpClient okHttpClient;

    @Value("${dashscope.api-key}")
    private String apiKey;

    @Value("${dashscope.responses-url}")
    private String responsesUrl;

    @Value("${dashscope.model}")
    private String dashscopeModel;

    @Value("classpath:ffmpeg/ffmpeg.exe")
    private Resource ffmpegExecutable;

    @Value("classpath:ffmpeg/ffprobe.exe")
    private Resource ffprobeExecutable;

    @Value("${ffmpeg.video.codec:libx264}")
    private String ffmpegVideoCodec;

    @Value("${ffmpeg.video.preset:faster}")
    private String ffmpegVideoPreset;

    @Value("${ffmpeg.video.crf:23}")
    private String ffmpegVideoCrf;

    @Value("${ffmpeg.video.threads:0}")
    private String ffmpegVideoThreads;

    @Value("${app.storage.contents-dir:runtime-data/contents}")
    private String contentsDirPath;

    @Value("${app.storage.sounds-dir:runtime-data/sounds}")
    private String soundsDirPath;

    @Value("${download.http.connect-timeout-ms:5000}")
    private long downloadConnectTimeoutMs;

    @Value("${download.http.read-timeout-ms:120000}")
    private long downloadReadTimeoutMs;

    @Value("${download.http.write-timeout-ms:30000}")
    private long downloadWriteTimeoutMs;

    @Value("${download.http.call-timeout-ms:180000}")
    private long downloadCallTimeoutMs;

    private volatile String ffmpegPath;
    private volatile String ffprobePath;

    private static final double DIALOG_GAP_SECONDS = 1.5;

    @PostConstruct
    private void initHttpClient() {
        this.okHttpClient = new OkHttpClient.Builder()
                .connectTimeout(downloadConnectTimeoutMs, TimeUnit.MILLISECONDS)
                .readTimeout(downloadReadTimeoutMs, TimeUnit.MILLISECONDS)
                .writeTimeout(downloadWriteTimeoutMs, TimeUnit.MILLISECONDS)
                .callTimeout(downloadCallTimeoutMs, TimeUnit.MILLISECONDS)
                .build();
    }

    @PreDestroy
    private void shutdownHttpClient() {
        if (okHttpClient == null) {
            return;
        }
        try {
            okHttpClient.dispatcher().executorService().shutdown();
            okHttpClient.connectionPool().evictAll();
            okhttp3.Cache cache = okHttpClient.cache();
            if (cache != null) {
                cache.close();
            }
        } catch (Exception e) {
            log.warn("关闭 OkHttpClient 资源失败", e);
        }
    }

    @Override
        public Result<String> generateDialogTemplate(
            String title,
            String content,
            String roleAPersona,
            String roleBPersona,
            Integer targetWordCount
        ) {
        if (title == null || title.trim().isEmpty()) {
            return Result.fail(400, "知乎标题不能为空");
        }
        if (content == null || content.trim().isEmpty()) {
            return Result.fail(400, "知乎高赞回答不能为空");
        }
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return Result.fail(500, "DashScope API Key 未配置");
        }
        if (responsesUrl == null || responsesUrl.trim().isEmpty()) {
            return Result.fail(500, "DashScope Responses URL 未配置");
        }

        String prompt = buildPrompt(title.trim(), content.trim(), roleAPersona, roleBPersona, targetWordCount);

        ObjectNode body = objectMapper.createObjectNode();
        body.put("model", dashscopeModel);
        body.put("input", prompt);

        String requestJson;
        try {
            requestJson = objectMapper.writeValueAsString(body);
        } catch (Exception e) {
            log.warn("序列化 DashScope 请求体失败", e);
            return Result.fail(500, "内部错误：无法构建请求体");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    responsesUrl,
                    HttpMethod.POST,
                    new HttpEntity<>(requestJson, headers),
                    String.class
            );
            if (response.getStatusCodeValue() != 200 || response.getBody() == null) {
                return Result.fail(500, "千问对话模板生成失败，HTTP " + response.getStatusCodeValue());
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode textNode = root
                    .path("output")
                    .path(0)
                    .path("content")
                    .path(0)
                    .path("text");
            if (textNode.isMissingNode() || textNode.isNull()) {
                log.warn("DashScope 响应中未找到 output[0].content[0].text，原始响应：{}", response.getBody());
                return Result.fail(500, "千问响应格式异常，未找到文本内容");
            }
            String text = textNode.asText();
            if (text == null || text.trim().isEmpty()) {
                return Result.fail(500, "千问返回的模板为空");
            }
            return Result.ok(text.trim());
        } catch (Exception e) {
            log.warn("调用 DashScope Responses API 生成对话模板失败", e);
            return Result.fail(500, "调用千问接口失败：" + e.getMessage());
        }
    }

    @Override
    public Result<String> confirmTemplateAndGenerateVideo(
            String title,
            String templateText,
            String mode,
            MultipartFile video,
            MultipartFile audioRoleA,
            MultipartFile audioRoleB,
            MultipartFile bgm,
            String bgmVolume,
            String instruction,
            SubtitleStyleConfig subtitleStyle,
            boolean exportPortrait,
            MultipartFile[] roleAImages,
            MultipartFile[] roleBImages,
            String roleAImagePosXPercent,
            String roleAImagePosYPercent,
            String roleAImageSizePercent,
            String roleAImageFlip,
            String roleBImagePosXPercent,
            String roleBImagePosYPercent,
            String roleBImageSizePercent,
            String roleBImageFlip
    ) {
        if (title == null || title.trim().isEmpty()) {
            return Result.fail(400, "知乎标题不能为空");
        }
        if (templateText == null || templateText.trim().isEmpty()) {
            return Result.fail(400, "模板内容不能为空");
        }
        String normalizedMode = mode == null ? "" : mode.trim().toLowerCase(Locale.ROOT);
        boolean singleMode = "single".equals(normalizedMode);
        boolean doubleMode = "double".equals(normalizedMode);
        if (!singleMode && !doubleMode) {
            return Result.fail(400, "视频模式必须为 single 或 double");
        }
        if (video == null || video.isEmpty()) {
            return Result.fail(400, "请上传跑酷视频（MP4）");
        }
        if (audioRoleA == null || audioRoleA.isEmpty()) {
            return Result.fail(400, "请上传角色A（或单人模式音色）的训练音频");
        }
        if (doubleMode && (audioRoleB == null || audioRoleB.isEmpty())) {
            return Result.fail(400, "双人模式下角色B训练音频必填");
        }

        try {
            initFfmpegIfNecessary();
        } catch (IOException e) {
            log.warn("初始化 ffmpeg/ffprobe 可执行文件失败", e);
            return Result.fail(500, "初始化 ffmpeg 失败：" + e.getMessage());
        }

        // 1. 保存模板到 contents 目录，文件名基于知乎标题
        String fileName = buildQuestionFileName(title);
        Path contentsDir = Paths.get(contentsDirPath);
        Path soundsBaseDir = Paths.get(soundsDirPath);
        try {
            Files.createDirectories(contentsDir);
            Files.createDirectories(soundsBaseDir);
        } catch (IOException e) {
            log.warn("创建 contents/sounds 目录失败", e);
            return Result.fail(500, "创建本地目录失败：" + e.getMessage());
        }
        // sounds/知乎标题 子目录（若不存在则创建）
        String questionFolderName = fileName;
        if (questionFolderName.toLowerCase(Locale.ROOT).endsWith(".txt")) {
            questionFolderName = questionFolderName.substring(0, questionFolderName.length() - 4);
        }
        Path soundsDir = soundsBaseDir.resolve(questionFolderName);
        try {
            Files.createDirectories(soundsDir);
        } catch (IOException e) {
            log.warn("创建知乎标题子目录失败, dir={}", soundsDir.toAbsolutePath(), e);
            return Result.fail(500, "创建知乎标题子目录失败：" + e.getMessage());
        }
        Path templatePath = contentsDir.resolve(fileName);
        try {
            Files.write(
                    templatePath,
                    templateText.getBytes(StandardCharsets.UTF_8),
                    StandardOpenOption.CREATE,
                    StandardOpenOption.TRUNCATE_EXISTING
            );
            log.info("模板已写入文件：{}", templatePath.toAbsolutePath());
        } catch (IOException e) {
            log.warn("写入模板文件失败", e);
            return Result.fail(500, "保存模板文件失败：" + e.getMessage());
        }

        // 2. 按行解析模板，拆分为角色 A/B 的按顺序对话
        List<Utterance> utterances = parseUtterances(templateText, title);
        if (utterances.isEmpty()) {
            return Result.fail(400, "未能从模板中解析出任何角色台词，请检查格式是否为“角色A：台词”/“角色B：台词”");
        }

        // 3. 基于训练音频创建声音
        String voiceA;
        String voiceB;
        try {
            byte[] bytesA = audioRoleA.getBytes();
            String mimeA = audioRoleA.getContentType();
            if (mimeA == null || mimeA.trim().isEmpty()) {
                mimeA = "audio/mpeg";
            }
            voiceA = qwenTtsService.createVoice(bytesA, "roleA_voice", mimeA);
            if (doubleMode) {
                byte[] bytesB = audioRoleB.getBytes();
                String mimeB = audioRoleB.getContentType();
                if (mimeB == null || mimeB.trim().isEmpty()) {
                    mimeB = "audio/mpeg";
                }
                voiceB = qwenTtsService.createVoice(bytesB, "roleB_voice", mimeB);
            } else {
                voiceB = voiceA;
            }
        } catch (Exception e) {
            log.warn("创建角色声音失败", e);
            return Result.fail(500, "创建角色声音失败：" + e.getMessage());
        }

        // 4. 逐句调用 TTS，OkHttp3 下载 OSS 音频到 sounds 目录，并记录每段音频时长，同时准备字幕时间轴
        List<File> audioFiles = new ArrayList<>();
        List<Double> startTimes = new ArrayList<>();
        double cursor = 0.0;
        double finalEndTime = 0.0;

        int indexA = 0;
        int indexB = 0;
        List<SubtitleEntry> subtitleEntries = new ArrayList<>();

        String labelA = resolveRoleLabel(subtitleStyle, "A");
        String labelB = resolveRoleLabel(subtitleStyle, "B");

        // 角色立绘图片：保存到 soundsDir/images 目录
        List<File> roleAImageFiles = new ArrayList<>();
        List<File> roleBImageFiles = new ArrayList<>();
        Path imagesDir = soundsDir.resolve("images");
        try {
            Files.createDirectories(imagesDir);
            if (roleAImages != null) {
                for (MultipartFile mf : roleAImages) {
                    if (mf == null || mf.isEmpty()) continue;
                    String original = mf.getOriginalFilename();
                    if (original == null || original.trim().isEmpty()) {
                        original = "roleA_" + System.currentTimeMillis() + ".jpg";
                    }
                    Path target = imagesDir.resolve("A_" + original);
                    try (InputStream in = mf.getInputStream()) {
                        Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
                    }
                    roleAImageFiles.add(target.toFile());
                }
            }
            if (roleBImages != null) {
                for (MultipartFile mf : roleBImages) {
                    if (mf == null || mf.isEmpty()) continue;
                    String original = mf.getOriginalFilename();
                    if (original == null || original.trim().isEmpty()) {
                        original = "roleB_" + System.currentTimeMillis() + ".jpg";
                    }
                    Path target = imagesDir.resolve("B_" + original);
                    try (InputStream in = mf.getInputStream()) {
                        Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
                    }
                    roleBImageFiles.add(target.toFile());
                }
            }
        } catch (IOException e) {
            log.warn("保存角色立绘图片失败", e);
            return Result.fail(500, "保存角色立绘图片失败：" + e.getMessage());
        }

        CharacterImageConfig cfgA = CharacterImageConfig.fromParams(
                roleAImagePosXPercent, roleAImagePosYPercent, roleAImageSizePercent, roleAImageFlip);
        CharacterImageConfig cfgB = CharacterImageConfig.fromParams(
                roleBImagePosXPercent, roleBImagePosYPercent, roleBImageSizePercent, roleBImageFlip);

        // 分角色维护立绘时间片：
        // - segmentsA：角色A 的每个图像片段；
        // - segmentsB：角色B 的每个图像片段。
        // 之后再拼成一个总的 characterSegments 传给 FFmpeg。
        List<CharacterSegment> segmentsA = new ArrayList<>();
        List<CharacterSegment> segmentsB = new ArrayList<>();

        for (Utterance utterance : utterances) {
            String voiceId;
            String roleLabel;
            int roleIndex;
            if ("A".equals(utterance.role)) {
                voiceId = voiceA;
                roleLabel = labelA;
                indexA++;
                roleIndex = indexA;
            } else {
                voiceId = voiceB;
                roleLabel = labelB;
                indexB++;
                roleIndex = indexB;
            }

            String text = sanitizeUtteranceText(
                    utterance.text,
                    roleLabel,
                    "A".equals(utterance.role) ? labelB : labelA
            );
            if (text == null || text.trim().isEmpty()) {
                continue;
            }

            String audioUrl;
            try {
                audioUrl = qwenTtsService.synthesize(voiceId, text.trim(), instruction);
            } catch (Exception e) {
                log.warn("TTS 合成失败，role={}, index={}, text={}", roleLabel, roleIndex, text, e);
                return Result.fail(500, "TTS 合成失败（" + roleLabel + " 第 " + roleIndex + " 句）：" + e.getMessage());
            }

            String audioFileName = buildAudioFileName(roleLabel, title, roleIndex);
            File audioFile;
            try {
                audioFile = downloadAudio(audioUrl, soundsDir, audioFileName);
            } catch (IOException e) {
                log.warn("下载 TTS 音频失败, url={}", audioUrl, e);
                return Result.fail(500, "下载 TTS 音频失败：" + e.getMessage());
            }

            double duration = getMediaDurationSeconds(audioFile);
            if (duration <= 0) {
                log.warn("无法获取音频时长，file={}", audioFile.getAbsolutePath());
                return Result.fail(500, "无法获取音频时长，请检查 ffprobe 是否可用");
            }

            // 记录音频插入时间和文件
            audioFiles.add(audioFile);
            startTimes.add(cursor);

            // 同步构建字幕条目：开始时间为当前 cursor，结束时间为 cursor + 音频时长
            SubtitleEntry entry = new SubtitleEntry();
            entry.index = subtitleEntries.size() + 1;
            entry.startSec = cursor;
            entry.endSec = cursor + duration;
            String fullText = roleLabel + "：" + text.trim();
            entry.text = applyWrap(fullText, subtitleStyle);
            subtitleEntries.add(entry);

            // 为对应角色新增一段立绘时间片，先记录当前句的起止时间，
            // 后续会按「延长到下一次同角色说话开始时间 / 对话结束时间」再统一调整。
            if ("A".equals(utterance.role) && !roleAImageFiles.isEmpty()) {
                File img = roleAImageFiles.get((indexA - 1) % roleAImageFiles.size());
                CharacterSegment seg = new CharacterSegment();
                seg.role = "A";
                seg.imageFile = img;
                seg.config = cfgA;
                seg.startSec = cursor;
                seg.endSec = cursor + duration;
                segmentsA.add(seg);
            } else if ("B".equals(utterance.role) && !roleBImageFiles.isEmpty()) {
                File img = roleBImageFiles.get((indexB - 1) % roleBImageFiles.size());
                CharacterSegment seg = new CharacterSegment();
                seg.role = "B";
                seg.imageFile = img;
                seg.config = cfgB;
                seg.startSec = cursor;
                seg.endSec = cursor + duration;
                segmentsB.add(seg);
            }

            cursor += duration + DIALOG_GAP_SECONDS;
            finalEndTime = cursor - DIALOG_GAP_SECONDS;
        }

        // 立绘时间轴规则：
        // - 若某角色只有 1 张图片：整段对话期间都显示这张图（0 ~ finalEndTime）；
        // - 若某角色有多张图片：该角色每次说话时切换下一张，
        //   且该图像会一直延长显示到下一次该角色说话开始时间（或对话结束时间），
        //   从而在对方说话时，本角色仍保持上一张立绘。
        if (!segmentsA.isEmpty()) {
            if (segmentsA.size() == 1) {
                // 仅 1 张图：从 0 秒撑到整段结束
                segmentsA.get(0).startSec = 0.0;
                segmentsA.get(0).endSec = finalEndTime;
            } else {
                for (int i = 0; i < segmentsA.size(); i++) {
                    CharacterSegment seg = segmentsA.get(i);
                    // 第一张立绘从 0 秒开始出现，后续按照该角色下一次说话开始时间衔接
                    if (i == 0) {
                        seg.startSec = 0.0;
                    }
                    double nextStart;
                    if (i + 1 < segmentsA.size()) {
                        nextStart = segmentsA.get(i + 1).startSec;
                    } else {
                        nextStart = finalEndTime;
                    }
                    if (nextStart > seg.startSec) {
                        seg.endSec = nextStart;
                    }
                }
            }
        }
        if (!segmentsB.isEmpty()) {
            if (segmentsB.size() == 1) {
                segmentsB.get(0).startSec = 0.0;
                segmentsB.get(0).endSec = finalEndTime;
            } else {
                for (int i = 0; i < segmentsB.size(); i++) {
                    CharacterSegment seg = segmentsB.get(i);
                    if (i == 0) {
                        seg.startSec = 0.0;
                    }
                    double nextStart;
                    if (i + 1 < segmentsB.size()) {
                        nextStart = segmentsB.get(i + 1).startSec;
                    } else {
                        nextStart = finalEndTime;
                    }
                    if (nextStart > seg.startSec) {
                        seg.endSec = nextStart;
                    }
                }
            }
        }

        // 汇总两个角色的时间片，供后续 FFmpeg 叠加使用
        List<CharacterSegment> characterSegments = new ArrayList<>();
        characterSegments.addAll(segmentsA);
        characterSegments.addAll(segmentsB);

        if (audioFiles.isEmpty()) {
            return Result.fail(500, "未生成任何 TTS 音频文件");
        }

        // 5. 将用户上传的跑酷视频保存为临时文件
        File videoFile;
        try {
            videoFile = File.createTempFile("bilibili_parkour_upload_", ".mp4");
            video.transferTo(videoFile);
        } catch (IOException e) {
            log.warn("保存上传视频失败", e);
            return Result.fail(500, "保存上传视频失败：" + e.getMessage());
        }

        // 6. 调用 ffmpeg 将多段音频插入到视频中，并在最终时间点剪辑结束，输出到项目根目录下的 Result 目录
        File outputFile = null;
        try {
            Path resultDir = Paths.get("Result");
            Files.createDirectories(resultDir);
            String outputFileName = buildVideoFileName(title);
            outputFile = resultDir.resolve(outputFileName).toFile();
            boolean videoHasAudio = hasAudioStream(videoFile);
            mergeAudiosIntoVideo(videoFile, audioFiles, startTimes, finalEndTime, videoHasAudio, outputFile);

            // 如需导出竖屏 1080x1920，则再进行一次视频转换
            if (exportPortrait) {
                File portraitFile = resultDir.resolve(buildPortraitVideoFileName(title)).toFile();
                convertToPortrait(outputFile, portraitFile);
                outputFile = portraitFile;
            }

            // 如用户上传了背景音乐，则将其循环/截断后与当前视频音频进行混音，保证 BGM 覆盖整个视频时长
            if (bgm != null && !bgm.isEmpty()) {
                double bgmVol = parseDoubleOrDefault(bgmVolume, 0.6d);
                if (bgmVol < 0d) bgmVol = 0d;
                if (bgmVol > 1d) bgmVol = 1d;
                File bgmFile = null;
                try {
                    bgmFile = File.createTempFile("bilibili_bgm_", ".mp3");
                    bgm.transferTo(bgmFile);
                    File withBgmFile = resultDir.resolve(buildBgmVideoFileName(title)).toFile();
                    addLoopedBgmToVideo(outputFile, bgmFile, withBgmFile, bgmVol);
                    outputFile = withBgmFile;
                } finally {
                    if (bgmFile != null && bgmFile.exists()) {
                        //noinspection ResultOfMethodCallIgnored
                        bgmFile.delete();
                    }
                }
            }

            // 若配置了角色立绘图片，则在最终视频上叠加角色图片（跟随每句台词时间段，轮询切换）
            if (!characterSegments.isEmpty()) {
                File withCharacters = resultDir.resolve(buildCharacterVideoFileName(title)).toFile();
                addCharacterImagesToVideo(outputFile, characterSegments, withCharacters);
                outputFile = withCharacters;
            }

            // 若传入了字幕样式配置，则基于前面记录的字幕时间轴生成 ASS 文件并再次用 ffmpeg 烧录字幕
            if (subtitleStyle != null) {
                Path assPath = resultDir.resolve(buildAssFileName(title));
                int[] size = getVideoSize(outputFile);
                int playResX = size[0];
                int playResY = size[1];
                String assContent = buildAssContent(subtitleEntries, subtitleStyle, playResX, playResY);
                Files.write(assPath, assContent.getBytes(StandardCharsets.UTF_8));

                File subbedFile = resultDir.resolve(buildSubbedVideoFileName(title)).toFile();
                burnAssSubtitles(outputFile, assPath.toFile(), subbedFile);
                // 使用带字幕的视频作为最终输出
                outputFile = subbedFile;
            }
        } catch (Exception e) {
            log.warn("FFmpeg 合成视频失败", e);
            if (outputFile != null && outputFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                outputFile.delete();
            }
            return Result.fail(500, "FFmpeg 合成视频失败：" + e.getMessage());
        } finally {
            if (videoFile != null && videoFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                videoFile.delete();
            }
        }

        String finalPath = outputFile != null ? outputFile.getAbsolutePath() : "";
        log.info("对话全部读完的时间为 {} 秒，最终视频文件：{}", String.format(Locale.US, "%.3f", finalEndTime), finalPath);
        return Result.ok(finalPath);
    }

    private String buildPrompt(String title, String content, String roleAPersona, String roleBPersona, Integer targetWordCount) {
        String personaA = normalizePersona(roleAPersona, "开放式提问者");
        String personaB = normalizePersona(roleBPersona, "理性解答者");
        int words = targetWordCount == null ? 1200 : Math.max(200, Math.min(5000, targetWordCount));
        return "你现在是一个专门用来返回文本的接口机器人。"
                + "你要根据我接下来给你的摘抄自知乎的标题和文本展开角色A和角色B的对话。"
                + "其中角色A的人设是：" + personaA + "；角色B的人设是：" + personaB + "。"
                + "请严格按“角色A：台词。/换行 角色B：台词。/换行”的形式输出，每一句单独一行，只允许出现角色A或角色B两个角色。"
                + "格式类似于{角色A：台词。 /换行  角色B：台词。 /换行}这样的形式，不要在角色A或角色B后重复附加其他称呼前缀。"
                + "标题内容为：{" + title + "}，文本内容为：{" + content + "}。"
                + "你可以根据输入的文本进行合理扩展，尽量让最终输出的模板控制在 " + words + " 字左右。";
    }

    private String normalizePersona(String persona, String defaultValue) {
        if (persona == null || persona.trim().isEmpty()) {
            return defaultValue;
        }
        String p = persona.trim();
        if (p.length() > 120) {
            p = p.substring(0, 120);
        }
        return p;
    }

    private String sanitizeUtteranceText(String text, String currentRoleLabel, String otherRoleLabel) {
        if (text == null) {
            return "";
        }
        String normalized = text.trim();
        List<String> prefixes = new ArrayList<>();
        prefixes.add("角色A");
        prefixes.add("角色B");
        prefixes.add("熊大");
        prefixes.add("熊二");
        if (currentRoleLabel != null && !currentRoleLabel.trim().isEmpty()) {
            prefixes.add(currentRoleLabel.trim());
        }
        if (otherRoleLabel != null && !otherRoleLabel.trim().isEmpty()) {
            prefixes.add(otherRoleLabel.trim());
        }

        for (int i = 0; i < 3; i++) {
            boolean stripped = false;
            for (String p : prefixes) {
                if (normalized.startsWith(p + "：")) {
                    normalized = normalized.substring((p + "：").length()).trim();
                    stripped = true;
                    break;
                }
                if (normalized.startsWith(p + ":")) {
                    normalized = normalized.substring((p + ":").length()).trim();
                    stripped = true;
                    break;
                }
            }
            if (!stripped) {
                break;
            }
        }
        return normalized;
    }

    private String buildQuestionFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        // Windows 文件名非法字符替换为下划线
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + ".txt";
    }

    private String buildVideoFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + ".mp4";
    }

    private String buildAssFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        // 先替换掉 Windows 文件名非法字符
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        // 再额外替换掉会干扰 ffmpeg filtergraph 解析的特殊字符（逗号、分号、括号等），
        // 同时将非 ASCII 字符统一替换为下划线，避免在 subtitles=filename 中被误解析。
        base = base.replaceAll("[,;\\[\\]\\(\\)'=]", "_");
        base = base.replaceAll("[^A-Za-z0-9_.-]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + ".ass";
    }

    private String buildSubbedVideoFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + "_sub.mp4";
    }

    private String buildPortraitVideoFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + "_portrait.mp4";
    }

    private String buildAudioFileName(String roleLabel, String title, int index) {
        String base = buildQuestionFileName(title);
        if (base.toLowerCase(Locale.ROOT).endsWith(".txt")) {
            base = base.substring(0, base.length() - 4);
        }
        return roleLabel + "_" + base + "_" + index + ".mp3";
    }

    /**
     * 构建 ASS 字幕内容：包含一个默认样式行和基于字幕条目的 Events 段。
     *
     * @param playResX 视频宽度，用于 ASS PlayResX
     * @param playResY 视频高度，用于 ASS PlayResY
     */
    private String buildAssContent(List<SubtitleEntry> entries, SubtitleStyleConfig styleConfig,
                                   int playResX, int playResY) {
        StringBuilder sb = new StringBuilder();
        sb.append("[Script Info]\n");
        sb.append("ScriptType: v4.00+\n");
        sb.append("Collisions: Normal\n");
        sb.append("PlayResX: ").append(playResX).append("\n");
        sb.append("PlayResY: ").append(playResY).append("\n\n");

        sb.append("[V4+ Styles]\n");
        sb.append("Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, ")
                .append("Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, ")
                .append("Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n");

        String fontName = (styleConfig != null && styleConfig.getFontName() != null && !styleConfig.getFontName().trim().isEmpty())
                ? styleConfig.getFontName().trim()
                : "Microsoft YaHei";
        // 在前端输入的基础上，后端额外增加 10 个字号，让最终导出字幕略大一些。
        int baseFontSize = parseIntOrDefault(styleConfig != null ? styleConfig.getFontSize() : null, 32);
        if (baseFontSize <= 0) {
            baseFontSize = 32;
        }
        int fontSize = baseFontSize + 10;
        String primary = toAssColor(styleConfig != null ? styleConfig.getPrimaryColor() : null, "&H00FFFFFF&");
        String outlineColor = toAssColor(styleConfig != null ? styleConfig.getOutlineColor() : null, "&H00000000&");
        int outline = parseIntOrDefault(styleConfig != null ? styleConfig.getOutline() : null, 2);
        int shadow = parseIntOrDefault(styleConfig != null ? styleConfig.getShadow() : null, 1);
        // 底部居中对齐，垂直位置通过 MarginV + verticalOffsetPercent 控制
        int alignment = 2;

        int offsetPercent = parseIntOrDefault(
                styleConfig != null ? styleConfig.getVerticalOffsetPercent() : null, 5);
        if (offsetPercent < 0) {
            offsetPercent = 0;
        }
        if (offsetPercent > 100) {
            offsetPercent = 100;
        }
        int marginV = (int) Math.round(playResY * (offsetPercent / 100.0));

        sb.append("Style: Default,")
                .append(fontName).append(",")
                .append(fontSize).append(",")
                .append(primary).append(",")
                .append("&H000000FF&,") // SecondaryColour（未使用）
                .append(outlineColor).append(",")
                .append("&H00000000&,") // BackColour
                .append("0,0,0,0,100,100,0,0,1,")
                .append(outline).append(",")
                .append(shadow).append(",")
                .append(alignment).append(",")
                .append("20,20,").append(marginV).append(",1\n\n");

        sb.append("[Events]\n");
        sb.append("Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n");
        for (SubtitleEntry e : entries) {
            String start = formatAssTime(e.startSec);
            String end = formatAssTime(e.endSec);
            sb.append("Dialogue: 0,")
                    .append(start).append(",")
                    .append(end).append(",")
                    .append("Default,,20,20,000,,") // 事件级别的 MarginV 设为 0，完全使用样式中的 MarginV（由 verticalOffsetPercent 控制）
                    .append(e.text.replace("\n", "\\N"))
                    .append("\n");
        }
        return sb.toString();
    }

    /**
     * 根据样式配置与角色标识，解析字幕中显示的角色名称：
     * - 对于 A：优先使用 styleConfig.roleALabel，默认为“角色A”；
     * - 对于 B：优先使用 styleConfig.roleBLabel，默认为“角色B”；
     * - 其他情况统一回退为“角色A”。
     */
    private String resolveRoleLabel(SubtitleStyleConfig styleConfig, String role) {
        if ("B".equals(role)) {
            if (styleConfig != null && styleConfig.getRoleBLabel() != null
                    && !styleConfig.getRoleBLabel().trim().isEmpty()) {
                return styleConfig.getRoleBLabel().trim();
            }
            return "角色B";
        }
        // 默认视为 A
        if (styleConfig != null && styleConfig.getRoleALabel() != null
                && !styleConfig.getRoleALabel().trim().isEmpty()) {
            return styleConfig.getRoleALabel().trim();
        }
        return "角色A";
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null) {
            return def;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private double parseDoubleOrDefault(String s, double def) {
        if (s == null) {
            return def;
        }
        try {
            return Double.parseDouble(s.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    /**
     * 使用 ffprobe 获取视频宽高，失败时返回 {1920, 1080} 作为默认值。
     */
    private int[] getVideoSize(File file) {
        try {
            initFfmpegIfNecessary();
        } catch (IOException e) {
            log.warn("初始化 ffprobe 失败，无法获取视频尺寸，file={}", file.getAbsolutePath(), e);
            return new int[]{1920, 1080};
        }

        ProcessBuilder pb = new ProcessBuilder(
                ffprobePath,
                "-v", "error",
                "-select_streams", "v:0",
                "-show_entries", "stream=width,height",
                "-of", "csv=s=x:p=0",
                file.getAbsolutePath()
        );
        pb.redirectErrorStream(true);
        try {
            Process process = pb.start();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line = br.readLine();
                int exit = process.waitFor();
                if (exit != 0 || line == null || line.trim().isEmpty()) {
                    return new int[]{1920, 1080};
                }
                String[] parts = line.trim().split("x");
                int w = Integer.parseInt(parts[0]);
                int h = Integer.parseInt(parts[1]);
                return new int[]{w, h};
            }
        } catch (Exception e) {
            log.warn("获取视频尺寸失败，file={}", file.getAbsolutePath(), e);
            return new int[]{1920, 1080};
        }
    }

    /**
     * 将视频转换为 1080x1920 竖屏（9:16），策略：先按高度缩放至 1920，再居中裁剪宽度为 1080。
     */
    private void convertToPortrait(File inputVideo, File outputVideo) throws IOException, InterruptedException {
        initFfmpegIfNecessary();
        List<String> command = new ArrayList<>();
        command.add(ffmpegPath);
        command.add("-y");
        command.add("-i");
        command.add(inputVideo.getAbsolutePath());
        // 先将高度缩放到 1920，再居中裁剪宽度到 1080
        command.add("-vf");
        command.add("scale=-2:1920,crop=1080:1920");
        appendVideoEncodeArgs(command);
        command.add("-pix_fmt");
        command.add("yuv420p");
        command.add("-c:a");
        command.add("copy");
        command.add(outputVideo.getAbsolutePath());

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        Process process = pb.start();
        try (InputStream is = process.getInputStream();
             InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
             BufferedReader br = new BufferedReader(isr)) {
            StringBuilder logBuf = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                logBuf.append(line).append('\n');
            }
            int exit = process.waitFor();
            if (exit != 0) {
                String ffmpegLog = logBuf.toString();
                log.warn("ffmpeg 竖屏转换失败，exitCode={}, log={}", exit, ffmpegLog);
                throw new IOException("FFmpeg 竖屏转换失败，exitCode=" + exit);
            } else {
                log.info("ffmpeg 竖屏转换成功，输出文件：{}", outputVideo.getAbsolutePath());
            }
        }
    }

    /**
     * 为已有含对白的成品视频增加循环/截断后的 BGM，并进行混音，保证：
     * - BGM 会循环播放直至覆盖整个视频时长；
     * - 最终音频长度与视频长度一致；
     * - 不对任一音频做变速处理，稳定、安全。
     */
    private void addLoopedBgmToVideo(File inputVideo, File bgmFile, File outputVideo, double bgmVolume) throws IOException, InterruptedException {
        initFfmpegIfNecessary();

        boolean hasAudio = hasAudioStream(inputVideo);

        List<String> command = new ArrayList<>();
        command.add(ffmpegPath);
        command.add("-y");

        // 0: 原视频（包含对白等）
        command.add("-i");
        command.add(inputVideo.getAbsolutePath());

        // 1: BGM，开启无限循环
        command.add("-stream_loop");
        command.add("-1");
        command.add("-i");
        command.add(bgmFile.getAbsolutePath());

        double vol = bgmVolume;
        if (Double.isNaN(vol) || vol < 0d) vol = 0d;
        if (vol > 1d) vol = 1d;

        if (hasAudio) {
            // 使用 filter_complex 做混音：
            // [1:a]volume=用户指定[a1]   ==> 将 BGM 调整到指定音量，避免压制人声
            // [0:a][a1]amix=inputs=2:duration=first:normalize=0[aout]
            //   - inputs=2：两路音频
            //   - duration=first：以第一路（0:a，即视频原有音频）的时长为准，确保最终音频长度与视频一致
            //   - normalize=0：避免自动归一化导致音量突变
            command.add("-filter_complex");
            command.add(String.format(java.util.Locale.US,
                    "[1:a]volume=%.3f[a1];[0:a][a1]amix=inputs=2:duration=first:normalize=0[aout]", vol));

            // 输出映射：视频沿用 0:v；音频使用混合后的 [aout]
            command.add("-map");
            command.add("0:v");
            command.add("-map");
            command.add("[aout]");

            // 不重新编码视频，保证性能与稳定性
            command.add("-c:v");
            command.add("copy");
        } else {
            // 如果原视频没有音频流，则直接用调整过音量的循环 BGM 作为音频
            command.add("-filter_complex");
            command.add(String.format(java.util.Locale.US, "[1:a]volume=%.3f[aout]", vol));
            command.add("-map");
            command.add("0:v");
            command.add("-map");
            command.add("[aout]");
            command.add("-c:v");
            command.add("copy");
        }

        // 以最短流为准（这里等价于视频流长度），增加稳健性
        command.add("-shortest");

        command.add(outputVideo.getAbsolutePath());

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        Process process = pb.start();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
            // 仅消费输出，防止缓冲区阻塞；如需调试可记录日志
            while (reader.readLine() != null) {
                // no-op
            }
        }
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            log.warn("ffmpeg 添加 BGM 失败，exitCode={}", exitCode);
            throw new IOException("FFmpeg 添加 BGM 失败，exitCode=" + exitCode);
        } else {
            log.info("ffmpeg 添加 BGM 成功，输出文件：{}", outputVideo.getAbsolutePath());
        }
    }

    private String buildBgmVideoFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + "_with_bgm.mp4";
    }

    /**
     * 将角色立绘图片按照每句台词的时间段叠加到视频上：
     * - 角色A和角色B的图片流交替出现；
     * - 使用百分比控制位置与缩放；
     * - 支持水平镜像翻转；
     * - 不改变原视频音频，仅叠加画面。
     */
    private void addCharacterImagesToVideo(File inputVideo,
                                           List<CharacterSegment> segments,
                                           File outputVideo) throws IOException, InterruptedException {
        if (segments == null || segments.isEmpty()) {
            return;
        }
        initFfmpegIfNecessary();

        // 获取视频宽高，用于按“角色立绘占视频宽度的百分比”来统一缩放，
        // 确保同一个角色的所有图片在画面上的宽度一致（不同原始分辨率也统一成同一视觉大小）。
        int[] videoSize = getVideoSize(inputVideo);
        int videoWidth = (videoSize != null && videoSize.length == 2 && videoSize[0] > 0) ? videoSize[0] : 1080;
        int videoHeight = (videoSize != null && videoSize.length == 2 && videoSize[1] > 0) ? videoSize[1] : 1920;

        List<String> command = new ArrayList<>();
        command.add(ffmpegPath);
        command.add("-y");
        // 0: 视频
        command.add("-i");
        command.add(inputVideo.getAbsolutePath());

        // 1..N: 每个台词片段对应一张图片（允许同一文件重复出现）
        for (CharacterSegment seg : segments) {
            command.add("-loop");
            command.add("1");
            command.add("-i");
            command.add(seg.imageFile.getAbsolutePath());
        }

        StringBuilder filter = new StringBuilder();
        String currentVideoLabel = "0:v";

        for (int i = 0; i < segments.size(); i++) {
            CharacterSegment seg = segments.get(i);
            int inputIndex = i + 1; // 对应 -i 的索引
            String imgLabel = "img" + inputIndex;
            String scaledLabel = "img" + inputIndex + "_s";
            String finalImgLabel = "img" + inputIndex + "_f";

            CharacterImageConfig cfg = seg.config != null ? seg.config : CharacterImageConfig.defaultConfig();
            double posX = cfg.posXPercent / 100.0;
            double posY = cfg.posYPercent / 100.0;
            double size = cfg.sizePercent / 100.0;
            if (size <= 0) size = 0.3;

            // 统一按“视频宽度 * 百分比”来控制立绘宽度，保证同一角色的所有图片视觉宽度一致
            int targetWidth = (int) Math.round(videoWidth * size);
            if (targetWidth <= 0) {
                targetWidth = (int) Math.round(videoWidth * 0.3);
            }

            // 缩放到统一宽度，高度按比例自适应（-2 保证可被编码器接受）
            filter.append("[")
                    .append(inputIndex)
                    .append(":v]scale=")
                    .append(targetWidth)
                    .append(":-2")
                    .append("[").append(scaledLabel).append("];");

            // 是否镜像
            if (cfg.flipHorizontal) {
                filter.append("[")
                        .append(scaledLabel)
                        .append("]hflip[")
                        .append(finalImgLabel)
                        .append("];");
            } else {
                finalImgLabel = scaledLabel;
            }

            // 叠加到当前视频流
            String nextVideoLabel = "v" + inputIndex;
            filter.append("[")
                    .append(currentVideoLabel)
                    .append("][")
                    .append(finalImgLabel)
                    .append("]overlay=")
                    .append("x=W*")
                    .append(String.format(Locale.US, "%.4f", posX))
                    .append(":y=H*")
                    .append(String.format(Locale.US, "%.4f", posY))
                    .append(":enable='between(t,")
                    .append(String.format(Locale.US, "%.3f", seg.startSec))
                    .append(",")
                    .append(String.format(Locale.US, "%.3f", seg.endSec))
                    .append(")'[")
                    .append(nextVideoLabel)
                    .append("];");

            currentVideoLabel = nextVideoLabel;
        }

        // 去掉最后一个多余的 ';'
        String filterStr = filter.toString();
        if (filterStr.endsWith(";")) {
            filterStr = filterStr.substring(0, filterStr.length() - 1);
        }

        command.add("-filter_complex");
        command.add(filterStr);
        // 映射最终叠加后的滤镜输出标签（例如 [v3]）
        command.add("-map");
        command.add("[" + currentVideoLabel + "]");
        appendVideoEncodeArgs(command);
        command.add("-pix_fmt");
        command.add("yuv420p");
        // 音频直接沿用原视频
        command.add("-map");
        command.add("0:a?");
        command.add("-c:a");
        command.add("copy");

        // 以最短流为准，避免因图片输入无限循环导致处理卡死
        command.add("-shortest");

        command.add(outputVideo.getAbsolutePath());

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        Process process = pb.start();
        StringBuilder logBuf = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                logBuf.append(line).append('\n');
            }
        }
        int exit = process.waitFor();
        if (exit != 0) {
            String ffmpegLog = logBuf.toString();
            log.warn("ffmpeg 叠加角色立绘失败，exitCode={}, log={}", exit, ffmpegLog);
            throw new IOException("FFmpeg 叠加角色立绘失败，exitCode=" + exit + ", log=" + ffmpegLog);
        } else {
            log.info("ffmpeg 叠加角色立绘成功，输出文件：{}", outputVideo.getAbsolutePath());
        }
    }

    private String buildCharacterVideoFileName(String title) {
        String base = title.trim();
        base = Normalizer.normalize(base, Normalizer.Form.NFKC);
        base = base.replaceAll("[\\\\/:*?\"<>|]", "_");
        if (base.isEmpty()) {
            base = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        }
        return base + "_with_roles.mp4";
    }

    private static class CharacterImageConfig {
        double posXPercent;
        double posYPercent;
        double sizePercent;
        boolean flipHorizontal;

        static CharacterImageConfig fromParams(String x, String y, String size, String flip) {
            CharacterImageConfig c = new CharacterImageConfig();
            c.posXPercent = parsePercent(x, 5);
            c.posYPercent = parsePercent(y, 60);
            c.sizePercent = parsePercent(size, 30);
            c.flipHorizontal = "true".equalsIgnoreCase(flip) || "1".equals(flip);
            return c;
        }

        static CharacterImageConfig defaultConfig() {
            CharacterImageConfig c = new CharacterImageConfig();
            c.posXPercent = 5;
            c.posYPercent = 60;
            c.sizePercent = 30;
            c.flipHorizontal = false;
            return c;
        }

        private static double parsePercent(String s, double def) {
            if (s == null) return def;
            try {
                double v = Double.parseDouble(s.trim());
                if (v < 0) v = 0;
                if (v > 100) v = 100;
                return v;
            } catch (NumberFormatException e) {
                return def;
            }
        }
    }

    private static class CharacterSegment {
        String role;
        File imageFile;
        double startSec;
        double endSec;
        CharacterImageConfig config;
    }

    /**
     * 根据样式配置中的 wrapLength，将长文本按固定字符数自动换行，返回包含 '\n' 的字符串。
     */
    private String applyWrap(String text, SubtitleStyleConfig styleConfig) {
        if (text == null) {
            return "";
        }
        int limit = parseIntOrDefault(styleConfig != null ? styleConfig.getWrapLength() : null, 15);
        if (limit <= 0) {
            limit = 15;
        }
        StringBuilder current = new StringBuilder();
        List<String> lines = new ArrayList<>();
        int count = 0;
        for (int i = 0; i < text.length(); i++) {
            char ch = text.charAt(i);
            if (ch == '\n' || ch == '\r') {
                if (current.length() > 0) {
                    lines.add(current.toString());
                    current.setLength(0);
                    count = 0;
                }
                continue;
            }
            current.append(ch);
            count++;
            if (count >= limit) {
                lines.add(current.toString());
                current.setLength(0);
                count = 0;
            }
        }
        if (current.length() > 0) {
            lines.add(current.toString());
        }
        if (lines.isEmpty()) {
            return "";
        }
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < lines.size(); i++) {
            if (i > 0) {
                result.append('\n');
            }
            result.append(lines.get(i));
        }
        return result.toString();
    }

    /**
     * 将 #RRGGBB 转换为 ASS 颜色格式 &H00BBGGRR&，若为空或非法则返回默认值。
     */
    private String toAssColor(String hex, String defaultAss) {
        if (hex == null) {
            return defaultAss;
        }
        String v = hex.trim();
        if (v.isEmpty()) {
            return defaultAss;
        }
        if (v.startsWith("#")) {
            v = v.substring(1);
        }
        if (v.length() != 6) {
            return defaultAss;
        }
        try {
            int r = Integer.parseInt(v.substring(0, 2), 16);
            int g = Integer.parseInt(v.substring(2, 4), 16);
            int b = Integer.parseInt(v.substring(4, 6), 16);
            // ASS 颜色为 &HAABBGGRR&，此处 Alpha 设为 00（不透明）
            return String.format("&H%02X%02X%02X%02X&", 0, b, g, r);
        } catch (Exception e) {
            return defaultAss;
        }
    }

    /**
     * 根据位置字符串映射到 ASS 对齐方式：
     * bottom -> 2（底部居中），middle -> 5（中间居中），top -> 8（顶部居中）
     */
    private int toAssAlignment(String position) {
        if (position == null) {
            return 2;
        }
        String p = position.trim().toLowerCase(Locale.ROOT);
        switch (p) {
            case "top":
                return 8;
            case "middle":
            case "center":
                return 5;
            case "bottom":
            default:
                return 2;
        }
    }

    /**
     * 将秒数格式化为 ASS 时间字符串：H:MM:SS.cs（centiseconds）。
     */
    private String formatAssTime(double seconds) {
        long cs = Math.round(seconds * 100); // 1/100 秒
        long h = cs / 360000;
        long m = (cs % 360000) / 6000;
        long s = (cs % 6000) / 100;
        long cent = cs % 100;
        return String.format("%d:%02d:%02d.%02d", h, m, s, cent);
    }

    /**
     * 使用 ffmpeg 将 ASS 字幕烧录到视频中。
     */
    private void burnAssSubtitles(File inputVideo, File assFile, File outputVideo) throws IOException, InterruptedException {
        List<String> command = new ArrayList<>();
        command.add(ffmpegPath);
        command.add("-y");
        command.add("-i");
        command.add(inputVideo.getAbsolutePath());
        // 为避免 Windows 绝对路径在 subtitles 滤镜中被误解析，这里只使用文件名，
        // 并将工作目录切换到字幕文件所在目录。
        String filter = "subtitles=" + assFile.getName();
        command.add("-vf");
        command.add(filter);
        appendVideoEncodeArgs(command);
        command.add("-pix_fmt");
        command.add("yuv420p");
        command.add("-c:a");
        command.add("copy");
        command.add(outputVideo.getAbsolutePath());

        ProcessBuilder pb = new ProcessBuilder(command);
        // 在字幕文件所在目录下运行 ffmpeg，这样 subtitles=文件名 就能正确找到字幕
        pb.directory(assFile.getParentFile());
        pb.redirectErrorStream(true);
        Process process = pb.start();
        try (InputStream is = process.getInputStream();
             InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
             BufferedReader br = new BufferedReader(isr)) {
            StringBuilder logBuf = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                logBuf.append(line).append('\n');
            }
            int exit = process.waitFor();
            if (exit != 0) {
                String ffmpegLog = logBuf.toString();
                log.warn("ffmpeg 烧录字幕失败，exitCode={}, log={}", exit, ffmpegLog);
                throw new IOException("FFmpeg 烧录字幕失败，exitCode=" + exit);
            } else {
                log.info("ffmpeg 烧录字幕成功，输出文件：{}", outputVideo.getAbsolutePath());
            }
        }
    }

    private List<Utterance> parseUtterances(String templateText, String title) {
        List<Utterance> list = new ArrayList<>();
        String[] lines = templateText.split("\\r?\\n");
        for (String rawLine : lines) {
            if (rawLine == null) {
                continue;
            }
            String line = rawLine.trim();
            if (line.isEmpty()) {
                continue;
            }
            String role;
            if (line.startsWith("角色A")) {
                role = "A";
            } else if (line.startsWith("角色B")) {
                role = "B";
            } else {
                // 不带前缀时，尝试根据上一句角色轮流，或者直接跳过
                if (!list.isEmpty()) {
                    String lastRole = list.get(list.size() - 1).role;
                    role = "A".equals(lastRole) ? "B" : "A";
                } else {
                    role = "A";
                }
            }
            String textPart = line;
            int idx = line.indexOf('：');
            if (idx < 0) {
                idx = line.indexOf(':');
            }
            if (idx >= 0 && idx + 1 < line.length()) {
                textPart = line.substring(idx + 1);
            }
            textPart = textPart.trim();
            if (textPart.isEmpty()) {
                continue;
            }
            Utterance u = new Utterance();
            u.role = role;
            u.text = textPart;
            list.add(u);
        }
        log.info("从模板中解析出 {} 句对话，标题={}", list.size(), title);
        return list;
    }

    private File downloadAudio(String url, Path soundsDir, String fileName) throws IOException {
        Request request = new Request.Builder()
                .url(url)
                .get()
                .build();
        try (Response response = okHttpClient.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("下载音频失败，HTTP " + response.code());
            }
            ResponseBody body = response.body();
            if (body == null) {
                throw new IOException("下载音频失败，响应体为空");
            }
            Path target = soundsDir.resolve(fileName);
            try (InputStream is = body.byteStream()) {
                Files.copy(is, target, StandardCopyOption.REPLACE_EXISTING);
            }
            log.info("音频已下载到：{}", target.toAbsolutePath());
            return target.toFile();
        }
    }

    private synchronized void initFfmpegIfNecessary() throws IOException {
        if (ffmpegPath != null && ffprobePath != null) {
            return;
        }
        if (ffmpegExecutable == null || ffprobeExecutable == null) {
            throw new IOException("未在 classpath 中找到 ffmpeg/ffprobe 资源，请确认已放置在 resources/ffmpeg 目录下。");
        }
        File baseDir = new File(System.getProperty("java.io.tmpdir"), "bilibili-chatVideo-ffmpeg");
        if (!baseDir.exists() && !baseDir.mkdirs()) {
            throw new IOException("无法创建 ffmpeg 临时目录: " + baseDir.getAbsolutePath());
        }
        this.ffmpegPath = extractExecutable(ffmpegExecutable, baseDir, "ffmpeg.exe");
        this.ffprobePath = extractExecutable(ffprobeExecutable, baseDir, "ffprobe.exe");
        log.info("ffmpeg 可执行路径: {}, ffprobe 可执行路径: {}", ffmpegPath, ffprobePath);
    }

    private String extractExecutable(Resource resource, File targetDir, String defaultName) throws IOException {
        String filename = resource.getFilename();
        if (filename == null || !filename.toLowerCase(Locale.ROOT).endsWith(".exe")) {
            filename = defaultName;
        }
        File target = new File(targetDir, filename);
        if (!target.exists() || target.length() == 0L) {
            try (InputStream in = resource.getInputStream()) {
                Files.copy(in, target.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            //noinspection ResultOfMethodCallIgnored
            target.setExecutable(true, false);
        }
        return target.getAbsolutePath();
    }

    private double getMediaDurationSeconds(File file) {
        try {
            initFfmpegIfNecessary();
        } catch (IOException e) {
            log.warn("初始化 ffprobe 失败，无法获取媒体时长，file={}", file.getAbsolutePath(), e);
            return -1;
        }

        ProcessBuilder pb = new ProcessBuilder(
                ffprobePath,
                "-v", "error",
                "-show_entries", "format=duration",
                "-of", "default=noprint_wrappers=1:nokey=1",
                file.getAbsolutePath()
        );
        pb.redirectErrorStream(true);
        try {
            Process process = pb.start();
            try (InputStream is = process.getInputStream();
                 InputStreamReader isr = new InputStreamReader(is);
                 BufferedReader br = new BufferedReader(isr)) {
                String line = br.readLine();
                int exit = process.waitFor();
                if (exit != 0) {
                    log.warn("ffprobe 获取媒体时长失败，exitCode={}, file={}", exit, file.getAbsolutePath());
                    return -1;
                }
                if (line != null && !line.trim().isEmpty()) {
                    try {
                        return Double.parseDouble(line.trim());
                    } catch (NumberFormatException nfe) {
                        log.warn("解析 ffprobe 时长输出失败，file={}, line={}", file.getAbsolutePath(), line);
                    }
                }
            }
        } catch (IOException | InterruptedException e) {
            log.warn("调用 ffprobe 获取媒体时长异常，file={}", file.getAbsolutePath(), e);
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
        }
        return -1;
    }

    private boolean hasAudioStream(File file) {
        try {
            initFfmpegIfNecessary();
        } catch (IOException e) {
            log.warn("初始化 ffprobe 失败，无法判断是否包含音频流，file={}", file.getAbsolutePath(), e);
            return false;
        }

        ProcessBuilder pb = new ProcessBuilder(
                ffprobePath,
                "-v", "error",
                "-select_streams", "a",
                "-show_entries", "stream=index",
                "-of", "csv=p=0",
                file.getAbsolutePath()
        );
        pb.redirectErrorStream(true);
        try {
            Process process = pb.start();
            try (InputStream is = process.getInputStream();
                 InputStreamReader isr = new InputStreamReader(is);
                 BufferedReader br = new BufferedReader(isr)) {
                String line = br.readLine();
                int exit = process.waitFor();
                if (exit != 0) {
                    log.warn("ffprobe 检查音频流失败，exitCode={}, file={}", exit, file.getAbsolutePath());
                    return false;
                }
                return line != null && !line.trim().isEmpty();
            }
        } catch (IOException | InterruptedException e) {
            log.warn("调用 ffprobe 检查音频流异常，file={}", file.getAbsolutePath(), e);
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
        }
        return false;
    }

    private void mergeAudiosIntoVideo(
            File videoFile,
            List<File> audioFiles,
            List<Double> startTimes,
            double finalEndTimeSeconds,
            boolean videoHasAudio,
            File outputFile
    ) throws IOException, InterruptedException {
        if (audioFiles.size() != startTimes.size()) {
            throw new IllegalArgumentException("音频文件数量与开始时间数量不一致");
        }

        List<String> command = new ArrayList<>();
        command.add(ffmpegPath);
        command.add("-y");
        command.add("-i");
        command.add(videoFile.getAbsolutePath());
        for (File audioFile : audioFiles) {
            command.add("-i");
            command.add(audioFile.getAbsolutePath());
        }

        StringBuilder filter = new StringBuilder();
        for (int i = 0; i < audioFiles.size(); i++) {
            double start = startTimes.get(i);
            long startMs = (long) (start * 1000);
            String delay = startMs + "|" + startMs;
            filter.append("[").append(i + 1).append(":a]adelay=").append(delay)
                    .append("[a").append(i + 1).append("];");
        }

        StringBuilder amix = new StringBuilder();
        int inputsCount = 0;
        if (videoHasAudio) {
            amix.append("[0:a]");
            inputsCount++;
        }
        for (int i = 0; i < audioFiles.size(); i++) {
            amix.append("[a").append(i + 1).append("]");
            inputsCount++;
        }
        amix.append("amix=inputs=").append(inputsCount)
                .append(":duration=longest:normalize=0[aout]");
        filter.append(amix);

        command.add("-filter_complex");
        command.add(filter.toString());
        command.add("-map");
        command.add("0:v");
        command.add("-map");
        command.add("[aout]");
        command.add("-c:v");
        command.add("copy");
        command.add("-c:a");
        command.add("aac");
        if (finalEndTimeSeconds > 0) {
            command.add("-t");
            command.add(String.format(Locale.US, "%.3f", finalEndTimeSeconds));
        }
        command.add(outputFile.getAbsolutePath());

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);

        Process process = pb.start();
        try (InputStream is = process.getInputStream();
             InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
             BufferedReader br = new BufferedReader(isr)) {
            StringBuilder logBuf = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                logBuf.append(line).append('\n');
            }
            int exit = process.waitFor();
            if (exit != 0) {
                String ffmpegLog = logBuf.toString();
                log.warn("ffmpeg 合成失败，exitCode={}, log={}", exit, ffmpegLog);
                throw new IOException("FFmpeg 合成失败，exitCode=" + exit);
            } else {
                log.info("ffmpeg 合成成功");
            }
        }
    }

    /**
     * 为需要重编码的视频步骤追加统一编码参数。
     * 保持默认值稳健，同时可通过配置调优性能与画质。
     */
    private void appendVideoEncodeArgs(List<String> command) {
        String codec = safeValue(ffmpegVideoCodec, "libx264");
        String preset = safeValue(ffmpegVideoPreset, "faster");
        String crf = safeValue(ffmpegVideoCrf, "23");
        String threads = safeValue(ffmpegVideoThreads, "0");

        command.add("-c:v");
        command.add(codec);
        command.add("-preset");
        command.add(preset);
        command.add("-crf");
        command.add(crf);
        command.add("-threads");
        command.add(threads);
        command.add("-movflags");
        command.add("+faststart");
    }

    private String safeValue(String value, String defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    private static class Utterance {
        String role;
        String text;
    }

    private static class SubtitleEntry {
        int index;
        double startSec;
        double endSec;
        String text;
    }
}

