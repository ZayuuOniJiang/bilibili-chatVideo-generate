package org.example.controller;

import org.example.pojo.Result;
import org.example.pojo.TemplateConfig;
import org.example.service.TemplateManageService;
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
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping
public class TemplateManageController {

    private final TemplateManageService templateManageService;

    @Value("${app.storage.base-dir:runtime-data}")
    private String storageBaseDir;

    public TemplateManageController(TemplateManageService templateManageService) {
        this.templateManageService = templateManageService;
    }

    @GetMapping("/template-manage")
    public String templateManagePage(Model model) {
        model.addAttribute("title", "模板管理 - 仪表盘风格");
        return "template-manage";
    }

    @GetMapping(value = "/api/template/list", produces = "application/json")
    @ResponseBody
    public Result<List<Map<String, String>>> listTemplates() {
        return templateManageService.listTemplates();
    }

    @GetMapping(value = "/api/template/detail", produces = "application/json")
    @ResponseBody
    public Result<TemplateConfig> detailTemplate(@RequestParam("fileName") String fileName) {
        return templateManageService.detailTemplate(fileName);
    }

    @PostMapping(value = "/api/template/save", produces = "application/json")
    @ResponseBody
    public Result<Map<String, String>> saveTemplate(@RequestBody TemplateConfig config) {
        return templateManageService.saveTemplate(config);
    }

    @PostMapping(value = "/api/template/update", produces = "application/json")
    @ResponseBody
    public Result<Void> updateTemplate(@RequestParam("fileName") String fileName,
                                       @RequestBody TemplateConfig config) {
        return templateManageService.updateTemplate(fileName, config);
    }

    @PostMapping(value = "/api/template/delete", produces = "application/json")
    @ResponseBody
    public Result<Void> deleteTemplate(@RequestParam("fileName") String fileName) {
        return templateManageService.deleteTemplate(fileName);
    }

    @PostMapping(value = "/api/template/upload-asset", produces = "application/json")
    @ResponseBody
    public Result<Map<String, String>> uploadTemplateAsset(
            @RequestParam("file") MultipartFile file,
            @RequestParam("category") String category
    ) {
        if (file == null || file.isEmpty()) {
            return Result.fail(400, "请选择需要上传的文件");
        }
        if (category == null || category.trim().isEmpty()) {
            return Result.fail(400, "category 不能为空");
        }

        String normalized = category.trim().toLowerCase(Locale.ROOT);
        String relativeDir;
        switch (normalized) {
            case "video":
                relativeDir = "videos";
                break;
            case "audiorolea":
            case "audioroleb":
            case "bgm":
                relativeDir = "sounds";
                break;
            case "roleaimage":
                relativeDir = "images/roleA";
                break;
            case "rolebimage":
                relativeDir = "images/roleB";
                break;
            default:
                return Result.fail(400, "不支持的 category：" + category);
        }

        try {
            String originalFileName = file.getOriginalFilename();
            String original = originalFileName == null ? "file" : originalFileName;
            String ext = "";
            int dot = original.lastIndexOf('.');
            if (dot > -1 && dot < original.length() - 1) {
                ext = original.substring(dot);
            }
            String ts = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String safeName = original.replaceAll("[^a-zA-Z0-9_\\-\\u4e00-\\u9fa5.]", "_");
            String baseName = safeName;
            if (dot > -1) {
                baseName = safeName.substring(0, dot);
            }
            if (baseName.trim().isEmpty()) {
                baseName = "asset";
            }

            Path base = Paths.get(storageBaseDir).toAbsolutePath().normalize();
            Path dir = base.resolve(relativeDir).normalize();
            if (!dir.startsWith(base)) {
                return Result.fail(400, "非法上传目录");
            }
            Files.createDirectories(dir);

            String fileName = ts + "_" + UUID.randomUUID().toString().replace("-", "") + "_" + baseName + ext;
            Path target = dir.resolve(fileName).normalize();
            if (!target.startsWith(base)) {
                return Result.fail(400, "非法上传路径");
            }

            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            String relativePath = storageBaseDir.replace('\\', '/') + "/" + relativeDir.replace('\\', '/') + "/" + fileName;
            Map<String, String> data = new LinkedHashMap<>();
            data.put("path", relativePath);
            data.put("fileName", fileName);
            data.put("category", normalized);
            return Result.ok(data);
        } catch (Exception e) {
            return Result.fail(500, "上传失败：" + e.getMessage());
        }
    }
}

