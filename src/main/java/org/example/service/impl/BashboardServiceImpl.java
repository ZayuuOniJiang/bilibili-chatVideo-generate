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
    private final OkHttpClient okHttpClient = new OkHttpClient();

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

    private volatile String ffmpegPath;
    private volatile String ffprobePath;

    private static final double DIALOG_GAP_SECONDS = 1.5;

    @Override
    public Result<String> generateDialogTemplate(String title, String content) {
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

        String prompt = buildPrompt(title.trim(), content.trim());

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
            String instruction
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
        Path contentsDir = Paths.get("src/main/resources/contents");
        Path soundsBaseDir = Paths.get("src/main/resources/sounds");
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

        // 4. 逐句调用 TTS，OkHttp3 下载 OSS 音频到 sounds 目录，并记录每段音频时长
        List<File> audioFiles = new ArrayList<>();
        List<Double> startTimes = new ArrayList<>();
        double cursor = 0.0;
        double finalEndTime = 0.0;

        int indexA = 0;
        int indexB = 0;

        for (Utterance utterance : utterances) {
            String voiceId;
            String roleLabel;
            int roleIndex;
            if ("A".equals(utterance.role)) {
                voiceId = voiceA;
                roleLabel = "角色A";
                indexA++;
                roleIndex = indexA;
            } else {
                voiceId = voiceB;
                roleLabel = "角色B";
                indexB++;
                roleIndex = indexB;
            }

            String text = utterance.text;
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

            audioFiles.add(audioFile);
            startTimes.add(cursor);
            cursor += duration + DIALOG_GAP_SECONDS;
            finalEndTime = cursor - DIALOG_GAP_SECONDS;
        }

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

    private String buildPrompt(String title, String content) {
        return "你现在是一个专门用来返回文本的接口机器人。"
                + "你要根据我接下来给你的摘抄自知乎的标题和文本展开角色A和角色B的对话。"
                + "其中角色A扮演《熊出没》中的熊二，负责提问者；角色B扮演《熊出没》中的熊大，担当理性的回答者。"
                + "请严格按“角色A：台词。/换行 角色B：台词。/换行”的形式输出，每一句单独一行，只允许出现角色A或角色B两个角色。"
                + "格式类似于{角色A：台词。 /换行  角色B：台词。 /换行}这样的形式，不要让:前面不要加熊大熊二"
                + "标题内容为：{" + title + "}，文本内容为：{" + content + "}。"
                + "你可以根据输入的文本进行合理扩展，尽量让最终输出的模板控制在 1200 字左右。";
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

    private String buildAudioFileName(String roleLabel, String title, int index) {
        String base = buildQuestionFileName(title);
        if (base.toLowerCase(Locale.ROOT).endsWith(".txt")) {
            base = base.substring(0, base.length() - 4);
        }
        return roleLabel + "_" + base + "_" + index + ".mp3";
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

    private static class Utterance {
        String role;
        String text;
    }
}

