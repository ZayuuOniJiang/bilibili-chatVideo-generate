package org.example.controller;

import org.example.pojo.Result;
import org.example.pojo.biliup.BiliupLoginRequest;
import org.example.pojo.biliup.BiliupUploadRequest;
import org.example.service.BiliupService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping
public class BiliupController {

    private final BiliupService biliupService;

    @Value("${app.storage.base-dir:runtime-data}")
    private String storageBaseDir;

    public BiliupController(BiliupService biliupService) {
        this.biliupService = biliupService;
    }

    @GetMapping("/biliup-upload")
    public String biliupUploadPage(Model model) {
        model.addAttribute("title", "上传至B站视频 - 仪表盘风格");
        return "biliup-upload";
    }

    @GetMapping(value = "/api/biliup/default-config", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> defaultConfig() {
        return biliupService.getDefaultConfig();
    }

    @PostMapping(value = "/api/biliup/login-shell", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> loginShell(@RequestBody BiliupLoginRequest request) {
        return biliupService.openLoginShell(request);
    }

    @GetMapping(value = "/api/biliup/login-status", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> loginStatus(
            @RequestParam(value = "exePath", required = false) String exePath,
            @RequestParam(value = "workDir", required = false) String workDir
    ) {
        return biliupService.checkLoginStatus(exePath, workDir);
    }

    @PostMapping(value = "/api/biliup/upload/start", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> startUpload(@RequestBody BiliupUploadRequest request) {
        return biliupService.startUpload(request);
    }

    @GetMapping(value = "/api/biliup/upload/task", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> uploadTask(@RequestParam("taskId") String taskId) {
        return biliupService.getUploadTask(taskId);
    }

    @PostMapping(value = "/api/biliup/upload-asset", produces = "application/json")
    @ResponseBody
    public Result<Map<String, String>> uploadAsset(
            @RequestParam("file") MultipartFile file,
            @RequestParam("assetType") String assetType
    ) {
        if (file == null || file.isEmpty()) {
            return Result.fail(400, "请选择需要上传的文件");
        }
        if (assetType == null || assetType.trim().isEmpty()) {
            return Result.fail(400, "assetType 不能为空");
        }
        String type = assetType.trim().toLowerCase(Locale.ROOT);
        String relativeDir;
        if ("video".equals(type)) {
            relativeDir = "biliup/videos";
        } else if ("cover".equals(type)) {
            relativeDir = "biliup/covers";
        } else {
            return Result.fail(400, "不支持的 assetType：" + assetType);
        }

        try {
            String originalFileName = file.getOriginalFilename();
            String original = originalFileName == null ? "file" : originalFileName;
            int dot = original.lastIndexOf('.');
            String ext = "";
            if (dot > -1 && dot < original.length() - 1) {
                ext = original.substring(dot);
            }
            String baseName = dot > -1 ? original.substring(0, dot) : original;
            baseName = baseName.replaceAll("[^a-zA-Z0-9_\\-\\u4e00-\\u9fa5.]", "_");
            if (baseName.trim().isEmpty()) {
                baseName = "asset";
            }

            Path base = Paths.get(storageBaseDir).toAbsolutePath().normalize();
            Path dir = base.resolve(relativeDir).normalize();
            if (!dir.startsWith(base)) {
                return Result.fail(400, "非法上传目录");
            }
            Files.createDirectories(dir);

            String ts = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String fileName = ts + "_" + UUID.randomUUID().toString().replace("-", "") + "_" + baseName + ext;
            Path target = dir.resolve(fileName).normalize();
            if (!target.startsWith(base)) {
                return Result.fail(400, "非法上传路径");
            }

            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            Map<String, String> data = new LinkedHashMap<String, String>();
            data.put("path", target.toString());
            data.put("fileName", fileName);
            data.put("assetType", type);
            return Result.ok(data);
        } catch (Exception e) {
            return Result.fail(500, "上传失败：" + e.getMessage());
        }
    }
}
