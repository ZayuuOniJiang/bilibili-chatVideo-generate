package org.example.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.service.QwenTtsService;
import org.example.service.ZhihuService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 测试页 /test：实装接口功能测试
 */
@Slf4j
@Controller
@RequiredArgsConstructor
public class TestPageController {



    private final QwenTtsService qwenTtsService;
    private final ZhihuService zhihuService;

    /**
     * 打包在 resources/ffmpeg 目录下的 ffmpeg / ffprobe 可执行文件。
     * 通过 @Value + classpath 方式注入，运行时解压到临时目录后使用绝对路径调用。
     */
    @Value("classpath:ffmpeg/ffmpeg.exe")
    private Resource ffmpegExecutable;

    @Value("classpath:ffmpeg/ffprobe.exe")
    private Resource ffprobeExecutable;

    /**
     * 此处可以根据性能自定义PAGESIZE和PAGECOUNT，默认为遍历1000条问答
     */
    private static final int PAGE_SIZE = 20;
    private static final int PAGE_COUNT = 50;

    /**
     * 运行时解压后的 ffmpeg / ffprobe 绝对路径（仅初始化一次）
     */
    private volatile String ffmpegPath;
    private volatile String ffprobePath;

    /** 风格/类型选项：展示名 -> 请求体中 instructions 的文案 */
    public static final Map<String, String> TTS_STYLE_OPTIONS = new LinkedHashMap<>();

    static {
        TTS_STYLE_OPTIONS.put("", "不指定风格");
        TTS_STYLE_OPTIONS.put("吐字清晰精准，字正腔圆", "标准播音风格");
        TTS_STYLE_OPTIONS.put("音量由正常对话迅速增强至高喊，性格直率，情绪易激动且外露", "情绪递进效果");
        TTS_STYLE_OPTIONS.put("哭腔导致发音略微含糊，略显沙哑，带有明显哭腔的紧张感", "特殊情感状态（哭腔）");
        TTS_STYLE_OPTIONS.put("音调偏高，语速中等，充满活力和感染力，适合广告配音", "广告配音风格");
        TTS_STYLE_OPTIONS.put("语速偏慢，音调温柔甜美，语气治愈温暖，像贴心朋友般关怀", "温柔治愈风格");
        TTS_STYLE_OPTIONS.put("语速较快，带有明显的上扬语调，适合介绍时尚产品", "时尚产品介绍");
        TTS_STYLE_OPTIONS.put("低沉、沉稳，适合新闻播报", "新闻播报");
        TTS_STYLE_OPTIONS.put("活泼、开朗，适合动画角色", "动画角色");
    }

    @GetMapping("/test")
    public String testPage(Model model) {
        model.addAttribute("styleOptions", TTS_STYLE_OPTIONS);
        return "test";
    }

    /**
     * 自定义音频 + 文本 -> 声音复刻并 TTS 合成，返回生成的音频 URL
     * 请求体（表单）：audio 文件、text、instruction（选中的风格对应的 instructions 文案，可选）
     */
    @PostMapping(value = "/api/tts/generate", produces = "application/json")
    @ResponseBody
    public Result<String> ttsGenerate(
            @RequestParam("audio") MultipartFile audio,
            @RequestParam("text") String text,
            @RequestParam(value = "instruction", required = false) String instruction
    ) {
        if (audio == null || audio.isEmpty()) {
            return Result.fail(400, "请上传用于复刻的音频文件");
        }
        if (text == null || text.trim().isEmpty()) {
            return Result.fail(400, "请输入要合成的文本");
        }
        try {
            byte[] bytes = audio.getBytes();
            String mimeType = audio.getContentType();
            if (mimeType == null) {
                mimeType = "audio/mpeg";
            }
            String preferredName = "web_voice";
            String voiceId = qwenTtsService.createVoice(bytes, preferredName, mimeType);
            String audioUrl = qwenTtsService.synthesize(voiceId, text.trim(), instruction != null ? instruction : "");
            return Result.ok(audioUrl);
        } catch (Exception e) {
            log.warn("TTS 生成失败", e);
            return Result.fail(500, "生成失败: " + e.getMessage());
        }
    }

    /**
     * 调用知乎问题回答接口，返回问题标题和最高赞回答内容
     */
    @PostMapping(value = "/api/zhihu/answers", produces = "application/json")
    @ResponseBody
    public Result<Map<String, String>> fetchZhihuTopAnswer(
            @RequestParam("questionId") String questionId,
            @RequestParam("cookie") String cookie
    ) {
        Result<Map<String, String>> serviceResult = zhihuService.fetchTopAnswer(
                questionId, cookie, PAGE_SIZE, PAGE_COUNT
        );
        if (serviceResult == null || serviceResult.getCode() != 200) {
            int code = serviceResult == null ? 500 : serviceResult.getCode();
            String msg = serviceResult == null ? "调用知乎接口失败" : serviceResult.getMessage();
            return Result.fail(code, msg);
        }
        Map<String, String> data = serviceResult.getData();
        Map<String, String> resp = new LinkedHashMap<>();
        resp.put("title", data.getOrDefault("title", ""));
        resp.put("answerContent", data.getOrDefault("answerContent", ""));
        return Result.ok(resp);
    }

    /**
     * 上传视频 + 音频，将音频插入到视频的指定时间点，返回合成后的视频文件流
     *
     * 请求体（表单）：
     * - video：原始 MP4 视频
     * - audio：要插入的 MP3 / 音频
     * - startTime：插入开始时间（单位：秒，支持小数）
     */
    @PostMapping(value = "/api/video/merge-audio")
    public ResponseEntity<Resource> mergeAudioIntoVideo(
            @RequestParam("video") MultipartFile video,
            @RequestParam("audio") MultipartFile audio,
            @RequestParam("startTime") String startTime
    ) {
        // 确保 ffmpeg/ffprobe 已从 classpath 解压到本地并获得可执行路径
        try {
            initFfmpegIfNecessary();
        } catch (IOException e) {
            log.warn("初始化 ffmpeg/ffprobe 可执行文件失败", e);
            return ResponseEntity.status(500)
                    .body(new ByteArrayResource(("初始化 ffmpeg 失败: " + e.getMessage()).getBytes()));
        }

        if (video == null || video.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(new ByteArrayResource("请上传视频文件".getBytes()));
        }
        if (audio == null || audio.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(new ByteArrayResource("请上传要插入的音频文件".getBytes()));
        }
        double startSeconds;
        try {
            startSeconds = Double.parseDouble(startTime);
            if (startSeconds < 0) {
                throw new IllegalArgumentException("开始时间不能为负数");
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ByteArrayResource("开始时间格式不正确，请输入秒数，例如 10 或 12.5".getBytes()));
        }

        File videoFile = null;
        File audioFile = null;
        File outputFile = null;
        try {
            videoFile = File.createTempFile("merge_video_", ".mp4");
            audioFile = File.createTempFile("merge_audio_", ".mp3");
            outputFile = File.createTempFile("merge_output_", ".mp4");

            video.transferTo(videoFile);
            audio.transferTo(audioFile);

            // 使用 ffprobe 预先检测媒体时长，若视频时长小于音频时长，则给出明确日志与错误提示
            double videoDuration = getMediaDurationSeconds(videoFile);
            double audioDuration = getMediaDurationSeconds(audioFile);
            if (videoDuration > 0 && audioDuration > 0 && videoDuration < audioDuration) {
                log.warn("视频长度小于音频长度，videoDuration={}s, audioDuration={}s，建议选择更短的音频或更长的视频。",
                        String.format("%.2f", videoDuration), String.format("%.2f", audioDuration));
                String msg = String.format("视频长度(%.2fs) 小于音频长度(%.2fs)，请重新选择视频或音频。", videoDuration, audioDuration);
                return ResponseEntity.badRequest()
                        .body(new ByteArrayResource(msg.getBytes()));
            }

            long startMs = (long) (startSeconds * 1000);
            String delay = startMs + "|" + startMs;

            boolean videoHasAudio = hasAudioStream(videoFile);
            String filterComplex;
            if (videoHasAudio) {
                // 有原始音频：将插入音频延时后与原音频混音为 aout，duration=longest 确保整体时长不被截断
                filterComplex = "[1:a]adelay=" + delay + "[a1];"
                        + "[0:a][a1]amix=inputs=2:duration=longest:normalize=0[aout]";
            } else {
                // 无原始音频：仅使用插入音频（延时后）作为最终音轨
                filterComplex = "[1:a]adelay=" + delay + "[aout]";
            }

            ProcessBuilder pb = new ProcessBuilder(
                    ffmpegPath,
                    "-y",
                    "-i", videoFile.getAbsolutePath(),
                    "-i", audioFile.getAbsolutePath(),
                    "-filter_complex", filterComplex,
                    // 显式映射：总是使用原视频画面 + 过滤后的音频 aout
                    "-map", "0:v",
                    "-map", "[aout]",
                    "-c:v", "copy",
                    "-c:a", "aac",
                    outputFile.getAbsolutePath()
            );
            pb.redirectErrorStream(true);
            Process process = pb.start();

            // 读取 ffmpeg 输出到日志，便于排查问题
            try (InputStream is = process.getInputStream();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                byte[] buf = new byte[1024];
                int len;
                while ((len = is.read(buf)) != -1) {
                    baos.write(buf, 0, len);
                }
                String ffmpegLog = new String(baos.toByteArray());
                int exit = process.waitFor();
                if (exit != 0) {
                    log.warn("ffmpeg 合成失败，exitCode={}, log={}", exit, ffmpegLog);
                    return ResponseEntity.status(500)
                            .body(new ByteArrayResource(("FFmpeg 合成失败，具体日志如下：\n" + ffmpegLog).getBytes()));
                } else {
                    log.info("ffmpeg 合成成功，log={}", ffmpegLog);
                }
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                return ResponseEntity.status(500)
                        .body(new ByteArrayResource("FFmpeg 执行被中断".getBytes()));
            }

            byte[] data = Files.readAllBytes(outputFile.toPath());
            ByteArrayResource resource = new ByteArrayResource(data);
            return ResponseEntity.ok()
                    .contentType(MediaType.valueOf("video/mp4"))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"merged.mp4\"")
                    .body(resource);
        } catch (IOException e) {
            log.warn("视频音频合成异常", e);
            return ResponseEntity.status(500)
                    .body(new ByteArrayResource(("视频音频合成异常: " + e.getMessage()).getBytes()));
        } finally {
            if (videoFile != null && videoFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                videoFile.delete();
            }
            if (audioFile != null && audioFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                audioFile.delete();
            }
            if (outputFile != null && outputFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                outputFile.delete();
            }
        }
    }

    /**
     * 上传视频 + 一段背景音频，将音频循环/截断以匹配视频总时长，返回合成后的视频文件流。
     *
     * - 不拉伸音频（不加速/减速），仅重复或截断。
     * - 使用 ffmpeg 的 stream_loop 和 shortest，让音频自动循环并在视频结束处截断。
     */
    @PostMapping(value = "/api/video/loop-audio")
    public ResponseEntity<Resource> loopAudioToVideo(
            @RequestParam("video") MultipartFile video,
            @RequestParam("audio") MultipartFile audio
    ) {
        try {
            initFfmpegIfNecessary();
        } catch (IOException e) {
            log.warn("初始化 ffmpeg/ffprobe 可执行文件失败", e);
            return ResponseEntity.status(500)
                    .body(new ByteArrayResource(("初始化 ffmpeg 失败: " + e.getMessage()).getBytes()));
        }

        if (video == null || video.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(new ByteArrayResource("请上传视频文件".getBytes()));
        }
        if (audio == null || audio.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(new ByteArrayResource("请上传要匹配时长的音频文件".getBytes()));
        }

        File videoFile = null;
        File audioFile = null;
        File outputFile = null;
        try {
            videoFile = File.createTempFile("loop_video_", ".mp4");
            audioFile = File.createTempFile("loop_audio_", ".mp3");
            outputFile = File.createTempFile("loop_output_", ".mp4");

            video.transferTo(videoFile);
            audio.transferTo(audioFile);

            // ffmpeg -stream_loop -1 -i audio -i video -map 1:v -map 0:a -c:v copy -shortest out.mp4
            ProcessBuilder pb = new ProcessBuilder(
                    ffmpegPath,
                    "-y",
                    "-stream_loop", "-1",
                    "-i", audioFile.getAbsolutePath(),
                    "-i", videoFile.getAbsolutePath(),
                    "-map", "1:v",
                    "-map", "0:a",
                    "-c:v", "copy",
                    "-shortest",
                    outputFile.getAbsolutePath()
            );
            pb.redirectErrorStream(true);
            Process process = pb.start();

            try (InputStream is = process.getInputStream();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                byte[] buf = new byte[1024];
                int len;
                while ((len = is.read(buf)) != -1) {
                    baos.write(buf, 0, len);
                }
                String ffmpegLog = new String(baos.toByteArray());
                int exit = process.waitFor();
                if (exit != 0) {
                    log.warn("ffmpeg 循环匹配音频失败，exitCode={}, log={}", exit, ffmpegLog);
                    return ResponseEntity.status(500)
                            .body(new ByteArrayResource(("FFmpeg 处理失败，具体日志如下：\n" + ffmpegLog).getBytes()));
                } else {
                    log.info("ffmpeg 循环匹配音频成功，log={}", ffmpegLog);
                }
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                return ResponseEntity.status(500)
                        .body(new ByteArrayResource("FFmpeg 执行被中断".getBytes()));
            }

            FileSystemResource resource = new FileSystemResource(outputFile);
            return ResponseEntity.ok()
                    .contentLength(outputFile.length())
                    .contentType(MediaType.valueOf("video/mp4"))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"looped.mp4\"")
                    .body(resource);
        } catch (IOException e) {
            log.warn("视频与音频循环匹配合成异常", e);
            return ResponseEntity.status(500)
                    .body(new ByteArrayResource(("视频与音频循环匹配合成异常: " + e.getMessage()).getBytes()));
        } finally {
            if (videoFile != null && videoFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                videoFile.delete();
            }
            if (audioFile != null && audioFile.exists()) {
                //noinspection ResultOfMethodCallIgnored
                audioFile.delete();
            }
            // outputFile 不在这里删除，以避免流式响应过程中找不到文件；
            // 可由外部定期清理临时目录。
        }
    }

    /**
     * 使用 ffprobe 获取媒体文件时长（秒）。
     * 依赖系统已安装 ffmpeg/ffprobe 并在 PATH 中可直接调用。
     *
     * @param file 媒体文件
     * @return 时长（秒），获取失败时返回 -1
     */
    private double getMediaDurationSeconds(File file) {
        // 若尚未初始化路径，这里也尝试初始化一次（容错）
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
        } catch (IOException e) {
            log.warn("调用 ffprobe 获取媒体时长异常，file={}", file.getAbsolutePath(), e);
        } catch (InterruptedException e) {
            log.warn("调用 ffprobe 获取媒体时长被中断，file={}", file.getAbsolutePath(), e);
            Thread.currentThread().interrupt();
        }
        return -1;
    }

    /**
     * 判断媒体文件是否包含音频流。
     */
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
                // 有任意一行输出，就认为存在音频流
                return line != null && !line.trim().isEmpty();
            }
        } catch (IOException e) {
            log.warn("调用 ffprobe 检查音频流异常，file={}", file.getAbsolutePath(), e);
        } catch (InterruptedException e) {
            log.warn("调用 ffprobe 检查音频流被中断，file={}", file.getAbsolutePath(), e);
            Thread.currentThread().interrupt();
        }
        return false;
    }

    /**
     * 从 classpath:ffmpeg 目录中将 ffmpeg.exe / ffprobe.exe 解压到本地临时目录，并记录绝对路径。
     * 仅在首次调用时执行，后续复用已解压的可执行文件。
     */
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

    /**
     * 将打包在 classpath 中的 exe 拷贝到目标目录，并返回绝对路径。
     */
    private String extractExecutable(Resource resource, File targetDir, String defaultName) throws IOException {
        String filename = resource.getFilename();
        if (filename == null || !filename.toLowerCase().endsWith(".exe")) {
            filename = defaultName;
        }
        File target = new File(targetDir, filename);
        if (!target.exists() || target.length() == 0L) {
            try (InputStream in = resource.getInputStream()) {
                Files.copy(in, target.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            // 尝试标记为可执行（在 Windows 上通常不是必须，但设置无害）
            //noinspection ResultOfMethodCallIgnored
            target.setExecutable(true, false);
        }
        return target.getAbsolutePath();
    }
}
