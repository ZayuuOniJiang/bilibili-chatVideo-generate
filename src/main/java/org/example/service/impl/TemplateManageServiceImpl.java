package org.example.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.pojo.TemplateConfig;
import org.example.service.TemplateManageService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Slf4j
@Service
public class TemplateManageServiceImpl implements TemplateManageService {

    @Value("${app.storage.style-dir:runtime-data/style}")
    private String styleDirPath;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Result<List<Map<String, String>>> listTemplates() {
        try {
            Path dir = styleDir();
            if (!Files.exists(dir)) {
                Files.createDirectories(dir);
            }
            List<Map<String, String>> list = new ArrayList<Map<String, String>>();
            try (Stream<Path> stream = Files.list(dir)) {
                List<Path> files = stream
                        .filter(Files::isRegularFile)
                        .filter(p -> p.getFileName().toString().toLowerCase(Locale.ROOT).endsWith(".json"))
                        .sorted(new Comparator<Path>() {
                            @Override
                            public int compare(Path o1, Path o2) {
                                try {
                                    return Files.getLastModifiedTime(o2).compareTo(Files.getLastModifiedTime(o1));
                                } catch (IOException e) {
                                    return o2.getFileName().toString().compareToIgnoreCase(o1.getFileName().toString());
                                }
                            }
                        })
                        .collect(Collectors.toList());
                for (Path p : files) {
                    Map<String, String> item = new LinkedHashMap<String, String>();
                    item.put("fileName", p.getFileName().toString());
                    item.put("updatedAt", Files.getLastModifiedTime(p).toString());
                    try {
                        TemplateConfig cfg = objectMapper.readValue(Files.newBufferedReader(p, StandardCharsets.UTF_8), TemplateConfig.class);
                        item.put("templateName", cfg.getTemplateName() == null ? "" : cfg.getTemplateName());
                    } catch (Exception ignore) {
                        item.put("templateName", "");
                    }
                    list.add(item);
                }
            }
            return Result.ok(list);
        } catch (Exception e) {
            log.warn("读取模板列表失败", e);
            return Result.fail(500, "读取模板列表失败：" + e.getMessage());
        }
    }

    @Override
    public Result<TemplateConfig> detailTemplate(String fileName) {
        try {
            Path p = resolveTemplateFile(fileName);
            if (!Files.exists(p) || !Files.isRegularFile(p)) {
                return Result.fail(404, "模板不存在");
            }
            TemplateConfig cfg = objectMapper.readValue(Files.newBufferedReader(p, StandardCharsets.UTF_8), TemplateConfig.class);
            return Result.ok(cfg);
        } catch (IllegalArgumentException e) {
            return Result.fail(400, e.getMessage());
        } catch (Exception e) {
            log.warn("读取模板详情失败", e);
            return Result.fail(500, "读取模板详情失败：" + e.getMessage());
        }
    }

    @Override
    public Result<Map<String, String>> saveTemplate(TemplateConfig config) {
        Result<Void> valid = validateConfig(config);
        if (valid.getCode() != 200) {
            return Result.fail(valid.getCode(), valid.getMessage());
        }
        try {
            Path dir = styleDir();
            Files.createDirectories(dir);
            String fileName = buildFileName(config.getTemplateName());
            Path p = resolveTemplateFile(fileName);
            writeConfig(p, config);
            Map<String, String> data = new LinkedHashMap<String, String>();
            data.put("fileName", fileName);
            return Result.ok(data);
        } catch (Exception e) {
            log.warn("保存模板失败", e);
            return Result.fail(500, "保存模板失败：" + e.getMessage());
        }
    }

    @Override
    public Result<Void> updateTemplate(String fileName, TemplateConfig config) {
        Result<Void> valid = validateConfig(config);
        if (valid.getCode() != 200) {
            return valid;
        }
        try {
            Path p = resolveTemplateFile(fileName);
            if (!Files.exists(p)) {
                return Result.fail(404, "模板不存在");
            }
            writeConfig(p, config);
            return Result.ok();
        } catch (IllegalArgumentException e) {
            return Result.fail(400, e.getMessage());
        } catch (Exception e) {
            log.warn("更新模板失败", e);
            return Result.fail(500, "更新模板失败：" + e.getMessage());
        }
    }

    @Override
    public Result<Void> deleteTemplate(String fileName) {
        try {
            Path p = resolveTemplateFile(fileName);
            if (!Files.exists(p)) {
                return Result.fail(404, "模板不存在");
            }
            Files.delete(p);
            return Result.ok();
        } catch (IllegalArgumentException e) {
            return Result.fail(400, e.getMessage());
        } catch (Exception e) {
            log.warn("删除模板失败", e);
            return Result.fail(500, "删除模板失败：" + e.getMessage());
        }
    }

    private void writeConfig(Path file, TemplateConfig config) throws IOException {
        String json = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(config);
        Files.write(file, json.getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    }

    private Result<Void> validateConfig(TemplateConfig config) {
        if (config == null) {
            return Result.fail(400, "模板内容不能为空");
        }
        if (isBlank(config.getTemplateName())) {
            return Result.fail(400, "templateName 不能为空");
        }
        if (isBlank(config.getVideoPath())) {
            return Result.fail(400, "videoPath 不能为空");
        }
        if (isBlank(config.getMode())) {
            return Result.fail(400, "mode 不能为空");
        }
        String mode = config.getMode().trim().toLowerCase(Locale.ROOT);
        if (!"single".equals(mode) && !"double".equals(mode)) {
            return Result.fail(400, "mode 仅支持 single/double");
        }
        if ("double".equals(mode) && isBlank(config.getAudioRoleBPath())) {
            return Result.fail(400, "double 模式下 audioRoleBPath 必填");
        }
        if (isBlank(config.getAudioRoleAPath())) {
            return Result.fail(400, "audioRoleAPath 不能为空");
        }
        Result<Void> pathCheck = verifyPaths(config);
        if (pathCheck.getCode() != 200) {
            return pathCheck;
        }
        return Result.ok();
    }

    private Result<Void> verifyPaths(TemplateConfig config) {
        List<String> all = new ArrayList<String>();
        all.add(config.getVideoPath());
        all.add(config.getAudioRoleAPath());
        if (!isBlank(config.getAudioRoleBPath())) {
            all.add(config.getAudioRoleBPath());
        }
        if (!isBlank(config.getBgmPath())) {
            all.add(config.getBgmPath());
        }
        if (config.getRoleAImagePaths() != null) {
            all.addAll(config.getRoleAImagePaths());
        }
        if (config.getRoleBImagePaths() != null) {
            all.addAll(config.getRoleBImagePaths());
        }
        for (String p : all) {
            if (isBlank(p)) {
                continue;
            }
            Path path = Paths.get(p).normalize();
            if (!Files.exists(path) || !Files.isReadable(path)) {
                return Result.fail(400, "文件不可读或不存在：" + p);
            }
        }
        return Result.ok();
    }

    private String buildFileName(String templateName) {
        String safe = templateName.replaceAll("[^a-zA-Z0-9_\u4e00-\u9fa5-]", "_");
        String ts = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        return safe + "_" + ts + ".json";
    }

    private Path resolveTemplateFile(String fileName) {
        if (isBlank(fileName)) {
            throw new IllegalArgumentException("fileName 不能为空");
        }
        String n = fileName.trim();
        if (n.contains("..") || n.contains("/") || n.contains("\\")) {
            throw new IllegalArgumentException("非法文件名");
        }
        if (!n.toLowerCase(Locale.ROOT).endsWith(".json")) {
            throw new IllegalArgumentException("模板文件必须是 .json");
        }
        Path base = styleDir();
        Path resolved = base.resolve(n).normalize();
        if (!resolved.startsWith(base)) {
            throw new IllegalArgumentException("非法路径");
        }
        return resolved;
    }

    private Path styleDir() {
        return Paths.get(styleDirPath).toAbsolutePath().normalize();
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}

