package org.example.service.impl;

import org.example.pojo.Result;
import org.example.pojo.biliup.BiliupLoginRequest;
import org.example.pojo.biliup.BiliupUploadRequest;
import org.example.service.BiliupService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Service
public class BiliupServiceImpl implements BiliupService {

    private static final Logger log = LoggerFactory.getLogger(BiliupServiceImpl.class);

    @Value("${app.biliup.exe-path:}")
    private String defaultExePath;

    @Value("${app.biliup.work-dir:}")
    private String defaultWorkDir;

    @Value("${app.biliup.cookie-file-name:cookie.json}")
    private String cookieFileName;

    private ExecutorService uploadExecutor;

    private final Map<String, UploadTask> taskMap = new ConcurrentHashMap<String, UploadTask>();

    @PostConstruct
    public void init() {
        uploadExecutor = Executors.newFixedThreadPool(2);
    }

    @PreDestroy
    public void destroy() {
        if (uploadExecutor != null) {
            uploadExecutor.shutdownNow();
        }
    }

    @Override
    public Result<Map<String, Object>> getDefaultConfig() {
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("exePath", nvl(defaultExePath));
        data.put("workDir", nvl(defaultWorkDir));
        data.put("cookieFileName", nvl(cookieFileName));
        return Result.ok(data);
    }

    @Override
    public Result<Map<String, Object>> openLoginShell(BiliupLoginRequest request) {
        try {
            Path exePath = resolveExePath(request == null ? null : request.getExePath());
            Path workDir = resolveWorkDir(request == null ? null : request.getWorkDir(), exePath);
            if (!Files.exists(exePath)) {
                return Result.fail(400, "biliup.exe 不存在：" + exePath);
            }
                String mode = normalizeLoginMode(request == null ? null : request.getLoginMode());

                StringBuilder psBuilder = new StringBuilder();
                psBuilder.append("Set-Location -LiteralPath '")
                    .append(escapePs(workDir.toString()))
                    .append("'; ")
                    .append(".\\")
                    .append(exePath.getFileName().toString())
                    .append(" login");
                if (!isBlank(mode)) {
                psBuilder.append(" ").append(mode);
                }
                String ps = psBuilder.toString();

            List<String> cmd = new ArrayList<String>();
            cmd.add("cmd");
            cmd.add("/c");
            cmd.add("start");
            cmd.add("\"biliup-login\"");
            cmd.add("powershell");
            cmd.add("-NoExit");
            cmd.add("-ExecutionPolicy");
            cmd.add("Bypass");
            cmd.add("-Command");
            cmd.add(ps);

            ProcessBuilder pb = new ProcessBuilder(cmd);
            pb.directory(workDir.toFile());
            pb.start();

            Map<String, Object> data = new LinkedHashMap<String, Object>();
            data.put("message", "已打开登录终端，请在终端中完成登录操作");
            data.put("workDir", workDir.toString());
            data.put("command", ".\\" + exePath.getFileName().toString() + " login" + (isBlank(mode) ? "" : (" " + mode)));
            return Result.ok(data);
        } catch (Exception e) {
            log.warn("打开 biliup 登录终端失败", e);
            return Result.fail(500, "打开登录终端失败：" + e.getMessage());
        }
    }

    @Override
    public Result<Map<String, Object>> checkLoginStatus(String exePath, String workDir) {
        try {
            Path resolvedExePath = resolveExePath(exePath);
            Path resolvedWorkDir = resolveWorkDir(workDir, resolvedExePath);
            Path cookiePath = resolvedWorkDir.resolve(cookieFileName).normalize();

            Map<String, Object> data = new LinkedHashMap<String, Object>();
            data.put("exeExists", Files.exists(resolvedExePath));
            data.put("workDirExists", Files.exists(resolvedWorkDir));
            data.put("cookiePath", cookiePath.toString());
            data.put("loggedIn", Files.exists(cookiePath));
            data.put("cookieSize", Files.exists(cookiePath) ? Files.size(cookiePath) : 0);
            return Result.ok(data);
        } catch (Exception e) {
            log.warn("检查 biliup 登录状态失败", e);
            return Result.fail(500, "检查登录状态失败：" + e.getMessage());
        }
    }

    @Override
    public Result<Map<String, Object>> startUpload(BiliupUploadRequest request) {
        if (request == null || isBlank(request.getVideoPath())) {
            return Result.fail(400, "videoPath 不能为空");
        }
        try {
            Path exePath = resolveExePath(request.getExePath());
            Path workDir = resolveWorkDir(request.getWorkDir(), exePath);
            if (!Files.exists(exePath)) {
                return Result.fail(400, "biliup.exe 不存在：" + exePath);
            }
            Path videoPath = Paths.get(request.getVideoPath().trim()).toAbsolutePath().normalize();
            if (!Files.exists(videoPath)) {
                return Result.fail(400, "视频文件不存在：" + videoPath);
            }

            List<String> cmd = buildUploadCommand(exePath, request, videoPath);
            String taskId = UUID.randomUUID().toString();

            UploadTask task = new UploadTask();
            task.id = taskId;
            task.command = joinForDisplay(cmd);
            task.status = "PENDING";
            task.startedAt = System.currentTimeMillis();
            taskMap.put(taskId, task);

            uploadExecutor.execute(new Runnable() {
                @Override
                public void run() {
                    runUploadTask(task, cmd, workDir);
                }
            });

            Map<String, Object> data = new LinkedHashMap<String, Object>();
            data.put("taskId", taskId);
            data.put("status", task.status);
            data.put("command", task.command);
            return Result.ok(data);
        } catch (Exception e) {
            log.warn("启动 biliup 上传失败", e);
            return Result.fail(500, "启动上传失败：" + e.getMessage());
        }
    }

    @Override
    public Result<Map<String, Object>> getUploadTask(String taskId) {
        if (isBlank(taskId)) {
            return Result.fail(400, "taskId 不能为空");
        }
        UploadTask task = taskMap.get(taskId.trim());
        if (task == null) {
            return Result.fail(404, "任务不存在");
        }
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("taskId", task.id);
        data.put("status", task.status);
        data.put("command", task.command);
        data.put("exitCode", task.exitCode);
        data.put("errorMessage", task.errorMessage);
        data.put("startedAt", task.startedAt);
        data.put("finishedAt", task.finishedAt);
        data.put("logs", task.logs);
        return Result.ok(data);
    }

    private void runUploadTask(UploadTask task, List<String> cmd, Path workDir) {
        task.status = "RUNNING";
        Process process = null;
        try {
            ProcessBuilder pb = new ProcessBuilder(cmd);
            pb.redirectErrorStream(true);
            pb.directory(workDir.toFile());
            process = pb.start();
            task.logs.add("[INFO] 开始执行上传命令");

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream(), Charset.forName("GBK"))
            );
            String line;
            while ((line = reader.readLine()) != null) {
                task.logs.add(line);
            }

            int exit = process.waitFor();
            task.exitCode = exit;
            task.status = exit == 0 ? "SUCCESS" : "FAILED";
            if (exit != 0) {
                task.errorMessage = "biliup 退出码非 0：" + exit;
                task.logs.add("[ERROR] 上传失败，退出码=" + exit);
            } else {
                task.logs.add("[INFO] 上传命令执行完成");
            }
        } catch (Exception e) {
            task.status = "FAILED";
            task.errorMessage = e.getMessage();
            task.logs.add("[ERROR] 执行异常：" + e.getMessage());
            log.warn("执行 biliup 上传任务失败, taskId={}", task.id, e);
        } finally {
            task.finishedAt = System.currentTimeMillis();
            if (process != null) {
                process.destroy();
            }
        }
    }

    private List<String> buildUploadCommand(Path exePath, BiliupUploadRequest request, Path videoPath) {
        List<String> cmd = new ArrayList<String>();
        cmd.add(exePath.toString());
        cmd.add("upload");
        cmd.add(videoPath.toString());

        if (!isBlank(request.getTitle())) {
            cmd.add("--title");
            cmd.add(request.getTitle().trim());
        }
        if (!isBlank(request.getDescription())) {
            cmd.add("--desc");
            cmd.add(request.getDescription().trim());
        }
        if (!isBlank(request.getTags())) {
            cmd.add("--tag");
            cmd.add(request.getTags().trim());
        }
        if (!isBlank(request.getPartitionId())) {
            cmd.add("--tid");
            cmd.add(request.getPartitionId().trim());
        }
        if (!isBlank(request.getCoverPath())) {
            Path coverPath = Paths.get(request.getCoverPath().trim()).toAbsolutePath().normalize();
            cmd.add("--cover");
            cmd.add(coverPath.toString());
        }

        if (!isBlank(request.getExtraArgs())) {
            cmd.addAll(splitArgs(request.getExtraArgs()));
        }
        return cmd;
    }

    private List<String> splitArgs(String raw) {
        List<String> args = new ArrayList<String>();
        if (isBlank(raw)) {
            return args;
        }
        String s = raw.trim();
        StringBuilder token = new StringBuilder();
        boolean inQuote = false;
        char quoteChar = '"';
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if ((c == '"' || c == '\'') && (!inQuote || c == quoteChar)) {
                if (!inQuote) {
                    inQuote = true;
                    quoteChar = c;
                } else {
                    inQuote = false;
                }
                continue;
            }
            if (!inQuote && Character.isWhitespace(c)) {
                if (token.length() > 0) {
                    args.add(token.toString());
                    token.setLength(0);
                }
                continue;
            }
            token.append(c);
        }
        if (token.length() > 0) {
            args.add(token.toString());
        }
        return args;
    }

    private Path resolveExePath(String candidate) {
        String value = !isBlank(candidate) ? candidate.trim() : nvl(defaultExePath);
        if (isBlank(value)) {
            return Paths.get("biliup.exe").toAbsolutePath().normalize();
        }
        return Paths.get(value).toAbsolutePath().normalize();
    }

    private Path resolveWorkDir(String candidate, Path exePath) {
        String value = !isBlank(candidate) ? candidate.trim() : nvl(defaultWorkDir);
        if (!isBlank(value)) {
            return Paths.get(value).toAbsolutePath().normalize();
        }
        Path parent = exePath.getParent();
        return parent == null ? Paths.get(".").toAbsolutePath().normalize() : parent;
    }

    private String normalizeLoginMode(String loginMode) {
        if (isBlank(loginMode)) {
            return "";
        }
        String mode = loginMode.trim().toLowerCase(Locale.ROOT);
        if ("interactive".equals(mode)) {
            return "";
        }
        if ("qrcode".equals(mode) || "password".equals(mode) || "sms".equals(mode)) {
            return mode;
        }
        return "";
    }

    private String joinForDisplay(List<String> command) {
        StringBuilder sb = new StringBuilder();
        for (String c : command) {
            if (sb.length() > 0) {
                sb.append(' ');
            }
            if (c.contains(" ")) {
                sb.append('"').append(c).append('"');
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    private String escapePs(String s) {
        return s == null ? "" : s.replace("'", "''");
    }

    private String nvl(String s) {
        return s == null ? "" : s;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static class UploadTask {
        String id;
        String status;
        String command;
        Integer exitCode;
        String errorMessage;
        Long startedAt;
        Long finishedAt;
        List<String> logs = new CopyOnWriteArrayList<String>();
    }
}
