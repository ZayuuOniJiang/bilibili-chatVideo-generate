package org.example.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.pojo.SubtitleStyleConfig;
import org.example.service.BashboardService;
import org.example.service.ZhihuService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;


@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping
public class BashboardController {

    private final BashboardService bashboardService;
    private final ZhihuService zhihuService;

    @Value("${app.storage.qa-file:runtime-data/QA.txt}")
    private String qaFilePath;

    @Value("${app.storage.qa-legacy-file:src/main/resources/QA.txt}")
    private String qaLegacyFilePath;

    /**
     * 仪表盘首页。
     */
    @GetMapping("/bashboard")
    public String bashboardPage(Model model) {
        model.addAttribute("title", "知乎问答跑酷视频生成 - 仪表盘");
        return "bashboard";
    }

    /**
     * 操作一：根据知乎标题 + 高赞回答调用千问生成对话模板。
     */
    @PostMapping(value = "/api/bashboard/generate-template", produces = "application/json")
    @ResponseBody
    public Result<String> generateTemplate(
            @RequestParam("title") String title,
            @RequestParam("content") String content,
            @RequestParam(value = "roleAPersona", required = false) String roleAPersona,
            @RequestParam(value = "roleBPersona", required = false) String roleBPersona,
            @RequestParam(value = "targetWordCount", required = false) Integer targetWordCount
    ) {
        log.info("调用千问生成对话模板, title={}", title);
        return bashboardService.generateDialogTemplate(title, content, roleAPersona, roleBPersona, targetWordCount);
    }

    /**
     * 操作二 ~ 五：确认模板后，提交模板 + 训练音频 + 跑酷视频，完成 TTS 生成 + 音频插入视频 + 剪辑。
     *
     * 前端表单字段定义：
     * - mode: single / double
     * - title: 知乎标题
     * - templateText: 已确认的模板全文
     * - video: 跑酷视频（MP4）
     * - audioRoleA: 角色A（或单人模式下唯一角色）的训练音频
     * - audioRoleB: 角色B 训练音频（仅双人模式必填）
     * - instruction: 指令控制文本（可选，用于整体控制语速/情感/音色等）
     */
    @PostMapping(value = "/api/bashboard/confirm-and-generate", produces = "application/json")
    @ResponseBody
    public Result<String> confirmAndGenerate(
            @RequestParam("mode") String mode,
            @RequestParam("title") String title,
            @RequestParam("templateText") String templateText,
            @RequestParam("video") MultipartFile video,
            @RequestParam("audioRoleA") MultipartFile audioRoleA,
            @RequestParam(value = "audioRoleB", required = false) MultipartFile audioRoleB,
            @RequestParam(value = "bgm", required = false) MultipartFile bgm,
            @RequestParam(value = "bgmVolume", required = false) String bgmVolume,
            @RequestParam(value = "instruction", required = false) String instruction,
            @RequestParam(value = "subtitleWrapLength", required = false) String subtitleWrapLength,
            @RequestParam(value = "subtitleVerticalOffsetPercent", required = false) String subtitleVerticalOffsetPercent,
            @RequestParam(value = "subtitleFontName", required = false) String subtitleFontName,
            @RequestParam(value = "subtitleFontSize", required = false) String subtitleFontSize,
            @RequestParam(value = "subtitlePrimaryColor", required = false) String subtitlePrimaryColor,
            @RequestParam(value = "subtitleOutlineColor", required = false) String subtitleOutlineColor,
            @RequestParam(value = "subtitleOutline", required = false) String subtitleOutline,
            @RequestParam(value = "subtitleShadow", required = false) String subtitleShadow,
            @RequestParam(value = "subtitlePosition", required = false) String subtitlePosition,
            @RequestParam(value = "roleALabel", required = false) String roleALabel,
            @RequestParam(value = "roleBLabel", required = false) String roleBLabel,
            @RequestParam(value = "roleAImages", required = false) MultipartFile[] roleAImages,
            @RequestParam(value = "roleBImages", required = false) MultipartFile[] roleBImages,
            @RequestParam(value = "roleAImagePosXPercent", required = false) String roleAImagePosXPercent,
            @RequestParam(value = "roleAImagePosYPercent", required = false) String roleAImagePosYPercent,
            @RequestParam(value = "roleAImageSizePercent", required = false) String roleAImageSizePercent,
            @RequestParam(value = "roleAImageFlip", required = false) String roleAImageFlip,
            @RequestParam(value = "roleBImagePosXPercent", required = false) String roleBImagePosXPercent,
            @RequestParam(value = "roleBImagePosYPercent", required = false) String roleBImagePosYPercent,
            @RequestParam(value = "roleBImageSizePercent", required = false) String roleBImageSizePercent,
            @RequestParam(value = "roleBImageFlip", required = false) String roleBImageFlip,
            @RequestParam(value = "exportPortrait", required = false) Boolean exportPortrait
    ) {
        log.info("确认模板并生成视频, mode={}, title={}", mode, title);
        SubtitleStyleConfig styleConfig = new SubtitleStyleConfig();
        styleConfig.setWrapLength(subtitleWrapLength);
        styleConfig.setVerticalOffsetPercent(subtitleVerticalOffsetPercent);
        styleConfig.setFontName(subtitleFontName);
        styleConfig.setFontSize(subtitleFontSize);
        styleConfig.setPrimaryColor(subtitlePrimaryColor);
        styleConfig.setOutlineColor(subtitleOutlineColor);
        styleConfig.setOutline(subtitleOutline);
        styleConfig.setShadow(subtitleShadow);
        styleConfig.setPosition(subtitlePosition);
        styleConfig.setRoleALabel(roleALabel);
        styleConfig.setRoleBLabel(roleBLabel);
        return bashboardService.confirmTemplateAndGenerateVideo(
                title, templateText, mode, video, audioRoleA, audioRoleB, bgm, bgmVolume, instruction, styleConfig,
                exportPortrait != null && exportPortrait,
                roleAImages,
                roleBImages,
                roleAImagePosXPercent,
                roleAImagePosYPercent,
                roleAImageSizePercent,
                roleAImageFlip,
                roleBImagePosXPercent,
                roleBImagePosYPercent,
                roleBImageSizePercent,
                roleBImageFlip
        );
    }

    /**
     * 右侧：知乎热榜 + 最高赞回答聚合接口。
     * - 使用知乎 Cookie 调用热榜接口，获取前 10 个 questionId；
     * - 对每个问题调用 ZhihuService.fetchTopAnswer；
     * - 将结果写入 resources/QA.txt；
     * - 返回精简列表用于前端可折叠展示。
     */
    @PostMapping(value = "/api/bashboard/zhihu/hot-qa", produces = "application/json")
    @ResponseBody
    public Result<java.util.List<java.util.Map<String, String>>> fetchHotQa(
            @RequestParam("cookie") String cookie
    ) {
        // 先拉取热榜 questionId 列表
        Result<java.util.List<java.util.Map<String, String>>> hotRes = zhihuService.fetchHotQuestions(cookie, 10);
        if (hotRes == null || hotRes.getCode() != 200) {
            return hotRes == null
                    ? Result.fail(500, "调用知乎热榜接口失败")
                    : Result.fail(hotRes.getCode(), hotRes.getMessage());
        }
        java.util.List<java.util.Map<String, String>> hotList = hotRes.getData();
        if (hotList == null || hotList.isEmpty()) {
            return Result.fail(500, "知乎热榜为空");
        }

        java.util.List<java.util.Map<String, String>> merged = new java.util.ArrayList<>();
        for (java.util.Map<String, String> q : hotList) {
            String qid = q.get("questionId");
            if (qid == null || qid.trim().isEmpty()) {
                continue;
            }
            Result<java.util.Map<String, String>> ansRes =
                    zhihuService.fetchTopAnswer(qid, cookie, 20, 5);
            if (ansRes == null || ansRes.getCode() != 200 || ansRes.getData() == null) {
                // 某个问题失败时仅记录日志，不终止整个流程
                log.warn("抓取知乎问题最高赞回答失败, questionId={}, code={}, msg={}",
                        qid,
                        ansRes == null ? 500 : ansRes.getCode(),
                        ansRes == null ? "unknown error" : ansRes.getMessage());
                continue;
            }
            java.util.Map<String, String> data = ansRes.getData();
            java.util.Map<String, String> item = new java.util.LinkedHashMap<>();
            item.put("questionId", data.getOrDefault("questionId", qid));
            item.put("title", data.getOrDefault("title", q.getOrDefault("title", "")));
            item.put("answerContent", data.getOrDefault("answerContent", ""));
            merged.add(item);
        }
        // 合并到 QA.txt，按 questionId+title 去重，仅返回本次新增的条目
        java.util.List<java.util.Map<String, String>> added = mergeAndPersistQa(merged);
        return Result.ok(added);
    }

    /**
     * 右侧：从 QA.txt 中读取所有已持久化的问题及回答，用于“总览”展示。
     */
    @GetMapping(value = "/api/bashboard/qa/overview", produces = "application/json")
    @ResponseBody
    public Result<java.util.List<java.util.Map<String, String>>> loadQaOverview() {
        java.util.List<java.util.Map<String, String>> list = new java.util.ArrayList<>();
        java.util.List<java.nio.file.Path> readPaths = resolveQaPathsForOverviewRead();
        if (readPaths.isEmpty()) {
            log.info("QA 总览读取：未找到可读取的 QA 文件");
            return Result.ok(list);
        }
        try {
            java.util.List<java.util.Map<String, String>> parsed = new java.util.ArrayList<>();
            java.util.Set<String> seen = new java.util.HashSet<>();
            for (java.nio.file.Path p : readPaths) {
                java.util.List<java.util.Map<String, String>> one = parseQaRecords(p);
                for (java.util.Map<String, String> m : one) {
                    String qid = m.getOrDefault("questionId", "").trim();
                    String title = m.getOrDefault("title", "").trim();
                    String answer = m.getOrDefault("answerContent", "").trim();
                    String dedupKey = qid + "||" + title + "||" + answer;
                    if (seen.add(dedupKey)) {
                        parsed.add(m);
                    }
                }
            }
            int idx = 1;
            for (java.util.Map<String, String> m : parsed) {
                java.util.Map<String, String> item = new java.util.LinkedHashMap<>();
                item.put("index", String.valueOf(idx));
                item.put("questionId", m.getOrDefault("questionId", ""));
                item.put("title", m.getOrDefault("title", ""));
                item.put("answerContent", m.getOrDefault("answerContent", ""));
                item.put("bookmarked", m.getOrDefault("bookmarked", "false"));
                list.add(item);
                idx++;
            }
        } catch (Exception e) {
            log.warn("读取 QA.txt 失败", e);
            return Result.fail(500, "读取 QA.txt 失败：" + e.getMessage());
        }
        return Result.ok(list);
    }

    /**
     * 更新某个问题的书签状态（bookmarked），用于总览界面的小圆点标记功能。
     */
    @PostMapping(value = "/api/bashboard/qa/bookmark", produces = "application/json")
    @ResponseBody
    public Result<Void> updateBookmark(
            @RequestParam("questionId") String questionId,
            @RequestParam("title") String title,
            @RequestParam("bookmarked") String bookmarked
    ) {
        java.nio.file.Path path = resolveQaPathForRead();
        if (!java.nio.file.Files.exists(path)) {
            return Result.ok();
        }
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        java.util.List<java.util.Map<String, String>> all = new java.util.ArrayList<>();
        String targetKey = (questionId == null ? "" : questionId.trim()) + "||" + (title == null ? "" : title.trim());
        try (java.io.BufferedReader reader = java.nio.file.Files.newBufferedReader(
                path, java.nio.charset.StandardCharsets.UTF_8)) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.startsWith("\uFEFF")) {
                    line = line.substring(1).trim();
                }
                if (line.isEmpty()) {
                    continue;
                }
                try {
                    @SuppressWarnings("unchecked")
                    java.util.Map<String, String> m = mapper.readValue(line, java.util.LinkedHashMap.class);
                    String qid = m.getOrDefault("questionId", "").trim();
                    String t = m.getOrDefault("title", "").trim();
                    String key = qid + "||" + t;
                    if (key.equals(targetKey)) {
                        m.put("bookmarked", "true".equalsIgnoreCase(bookmarked) ? "true" : "false");
                    }
                    all.add(m);
                } catch (Exception e) {
                    log.warn("updateBookmark 解析 QA.txt 行失败，line={}", line, e);
                }
            }
        } catch (Exception e) {
            log.warn("updateBookmark 读取 QA.txt 失败", e);
            return Result.fail(500, "更新书签失败：" + e.getMessage());
        }

        try (java.io.BufferedWriter writer = java.nio.file.Files.newBufferedWriter(
                path,
                java.nio.charset.StandardCharsets.UTF_8,
                java.nio.file.StandardOpenOption.CREATE,
                java.nio.file.StandardOpenOption.TRUNCATE_EXISTING
        )) {
            for (java.util.Map<String, String> m : all) {
                String json = mapper.writeValueAsString(m);
                writer.write(json);
                writer.newLine();
            }
        } catch (Exception e) {
            log.warn("updateBookmark 写入 QA.txt 失败", e);
            return Result.fail(500, "更新书签失败：" + e.getMessage());
        }
        return Result.ok();
    }

    /**
     * 将新抓取的问答与现有 QA.txt 合并：
     * - 使用 questionId + title 作为“哈希键”去重；
     * - 已存在的记录不会重复写入；
     * - 最终重写 QA.txt；
     * - 返回本次真正新增写入的条目列表（用于前端显示“新增/跳过”情况）。
     */
    private java.util.List<java.util.Map<String, String>> mergeAndPersistQa(java.util.List<java.util.Map<String, String>> newItems) {
        java.nio.file.Path path = resolveQaPathForWrite();
        try {
            java.nio.file.Path parent = path.getParent();
            if (parent != null) {
                java.nio.file.Files.createDirectories(parent);
            }
        } catch (Exception e) {
            log.warn("创建 resources 目录失败", e);
            return new java.util.ArrayList<>();
        }
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        java.util.List<java.util.Map<String, String>> all = new java.util.ArrayList<>();
        java.util.Set<String> seenKeys = new java.util.HashSet<>();

        // 先读取已有的 QA.txt，构建去重集合
        if (java.nio.file.Files.exists(path)) {
            try (java.io.BufferedReader reader = java.nio.file.Files.newBufferedReader(
                    path, java.nio.charset.StandardCharsets.UTF_8)) {
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.startsWith("\uFEFF")) {
                        line = line.substring(1).trim();
                    }
                    if (line.isEmpty()) {
                        continue;
                    }
                    try {
                        @SuppressWarnings("unchecked")
                        java.util.Map<String, String> m = mapper.readValue(line, java.util.LinkedHashMap.class);
                        String qid = m.getOrDefault("questionId", "").trim();
                        String title = m.getOrDefault("title", "").trim();
                        String key = qid + "||" + title;
                        seenKeys.add(key);
                        all.add(m);
                    } catch (Exception e) {
                        log.warn("mergeAndPersistQa 解析已有 QA.txt 行失败，line={}", line, e);
                    }
                }
            } catch (Exception e) {
                log.warn("mergeAndPersistQa 读取 QA.txt 失败", e);
            }
        }

        // 处理新抓取的条目：只有未出现过的才加入 all 与 added 列表
        java.util.List<java.util.Map<String, String>> added = new java.util.ArrayList<>();
        if (newItems != null) {
            for (java.util.Map<String, String> m : newItems) {
                String qid = m.getOrDefault("questionId", "").trim();
                String title = m.getOrDefault("title", "").trim();
                String key = qid + "||" + title;
                if (seenKeys.contains(key)) {
                    continue;
                }
                java.util.Map<String, String> toWrite = new java.util.LinkedHashMap<>();
                toWrite.put("questionId", qid);
                toWrite.put("title", title);
                toWrite.put("answerContent", m.getOrDefault("answerContent", ""));
                toWrite.put("bookmarked", "false");
                seenKeys.add(key);
                all.add(toWrite);
                added.add(toWrite);
            }
        }

        // 重写 QA.txt：包含历史记录 + 本次新增记录
        try (java.io.BufferedWriter writer = java.nio.file.Files.newBufferedWriter(
                path,
                java.nio.charset.StandardCharsets.UTF_8,
                java.nio.file.StandardOpenOption.CREATE,
                java.nio.file.StandardOpenOption.TRUNCATE_EXISTING
        )) {
            for (java.util.Map<String, String> m : all) {
                String json = mapper.writeValueAsString(m);
                writer.write(json);
                writer.newLine();
            }
        } catch (Exception e) {
            log.warn("写入 QA.txt 失败", e);
        }
        return added;
    }

    private java.nio.file.Path resolveQaPathForWrite() {
        return java.nio.file.Paths.get(qaFilePath);
    }

    private java.nio.file.Path resolveQaPathForRead() {
        java.nio.file.Path primary = java.nio.file.Paths.get(qaFilePath);
        if (java.nio.file.Files.exists(primary)) {
            return primary;
        }
        java.nio.file.Path legacy = java.nio.file.Paths.get(qaLegacyFilePath);
        if (java.nio.file.Files.exists(legacy)) {
            return legacy;
        }
        java.nio.file.Path runtimeUpper = java.nio.file.Paths.get("runtime-data", "QA.TXT");
        if (java.nio.file.Files.exists(runtimeUpper)) {
            return runtimeUpper;
        }
        java.nio.file.Path resourcesUpper = java.nio.file.Paths.get("src", "main", "resources", "QA.TXT");
        if (java.nio.file.Files.exists(resourcesUpper)) {
            return resourcesUpper;
        }
        return primary;
    }

    private java.util.List<java.nio.file.Path> resolveQaPathsForOverviewRead() {
        java.util.List<java.nio.file.Path> candidates = java.util.Arrays.asList(
                java.nio.file.Paths.get(qaFilePath),
                java.nio.file.Paths.get(qaLegacyFilePath),
                java.nio.file.Paths.get("runtime-data", "QA.TXT"),
                java.nio.file.Paths.get("src", "main", "resources", "QA.TXT")
        );
        java.util.List<java.nio.file.Path> paths = new java.util.ArrayList<>();
        java.util.Set<String> seenAbs = new java.util.HashSet<>();
        for (java.nio.file.Path p : candidates) {
            try {
                if (!java.nio.file.Files.exists(p)) {
                    continue;
                }
                String abs = p.toAbsolutePath().normalize().toString();
                if (seenAbs.add(abs)) {
                    paths.add(p);
                }
            } catch (Exception ignore) {
                // 忽略异常候选路径
            }
        }
        return paths;
    }

    private java.util.List<java.util.Map<String, String>> parseQaRecords(java.nio.file.Path path) throws java.io.IOException {
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        java.util.List<java.util.Map<String, String>> result = new java.util.ArrayList<>();
        java.util.Set<String> seen = new java.util.HashSet<>();

        String content = new String(java.nio.file.Files.readAllBytes(path), java.nio.charset.StandardCharsets.UTF_8);
        if (content.startsWith("\uFEFF")) {
            content = content.substring(1);
        }
        String trimmed = content.trim();

        if (!trimmed.isEmpty()) {
            if (trimmed.startsWith("[")) {
                try {
                    com.fasterxml.jackson.databind.JsonNode arr = mapper.readTree(trimmed);
                    if (arr.isArray()) {
                        for (com.fasterxml.jackson.databind.JsonNode node : arr) {
                            java.util.Map<String, String> m = jsonNodeToQaMap(node);
                            addIfValid(result, seen, m);
                        }
                    }
                } catch (Exception e) {
                    log.warn("QA 文件按 JSON 数组解析失败，回退到逐行解析，path={}", path.toAbsolutePath(), e);
                }
            } else if (trimmed.startsWith("{")) {
                try {
                    com.fasterxml.jackson.databind.JsonNode obj = mapper.readTree(trimmed);
                    // 支持容器结构：{"data":[...]}, {"items":[...]} 等
                    collectQaRecordsFromNode(obj, result, seen);
                } catch (Exception e) {
                    log.warn("QA 文件按单个 JSON 对象解析失败，回退到逐行解析，path={}", path.toAbsolutePath(), e);
                }
            }
        }

        java.util.List<String> lines = java.nio.file.Files.readAllLines(path, java.nio.charset.StandardCharsets.UTF_8);
        for (String rawLine : lines) {
            String line = rawLine == null ? "" : rawLine.trim();
            if (line.startsWith("\uFEFF")) {
                line = line.substring(1).trim();
            }
            if (line.isEmpty()) {
                continue;
            }
            try {
                @SuppressWarnings("unchecked")
                java.util.Map<String, String> m = mapper.readValue(line, java.util.LinkedHashMap.class);
                addIfValid(result, seen, normalizeQaMap(m));
            } catch (Exception ignore) {
                // 继续尝试文本键值格式解析
            }
        }

        if (!result.isEmpty()) {
            return result;
        }

        return parseQaTextBlocks(lines, seen);
    }

    private java.util.List<java.util.Map<String, String>> parseQaTextBlocks(
            java.util.List<String> lines,
            java.util.Set<String> seen
    ) {
        java.util.List<java.util.Map<String, String>> result = new java.util.ArrayList<>();
        java.util.Map<String, String> current = new java.util.LinkedHashMap<>();
        StringBuilder answerBuilder = new StringBuilder();

        for (String rawLine : lines) {
            String line = rawLine == null ? "" : rawLine.trim();
            if (line.startsWith("\uFEFF")) {
                line = line.substring(1).trim();
            }
            if (line.isEmpty() || line.startsWith("---")) {
                flushTextBlockRecord(result, seen, current, answerBuilder);
                continue;
            }

            String lower = line.toLowerCase(java.util.Locale.ROOT);
            if (lower.startsWith("questionid") || lower.startsWith("question_id") || line.startsWith("问题ID")) {
                current.put("questionId", extractKvValue(line));
            } else if (lower.startsWith("title") || line.startsWith("标题") || line.startsWith("问题标题")) {
                current.put("title", extractKvValue(line));
            } else if (lower.startsWith("bookmarked") || line.startsWith("书签")) {
                String v = extractKvValue(line);
                current.put("bookmarked", "true".equalsIgnoreCase(v) ? "true" : "false");
            } else if (lower.startsWith("answercontent") || line.startsWith("回答") || line.startsWith("答案")) {
                String v = extractKvValue(line);
                if (!v.isEmpty()) {
                    if (answerBuilder.length() > 0) {
                        answerBuilder.append("\n");
                    }
                    answerBuilder.append(v);
                }
            } else {
                if (answerBuilder.length() > 0) {
                    answerBuilder.append("\n");
                }
                answerBuilder.append(line);
            }
        }
        flushTextBlockRecord(result, seen, current, answerBuilder);
        return result;
    }

    private void flushTextBlockRecord(
            java.util.List<java.util.Map<String, String>> result,
            java.util.Set<String> seen,
            java.util.Map<String, String> current,
            StringBuilder answerBuilder
    ) {
        if (answerBuilder.length() > 0 && !current.containsKey("answerContent")) {
            current.put("answerContent", answerBuilder.toString().trim());
        }
        addIfValid(result, seen, normalizeQaMap(current));
        current.clear();
        answerBuilder.setLength(0);
    }

    private java.util.Map<String, String> jsonNodeToQaMap(com.fasterxml.jackson.databind.JsonNode node) {
        java.util.Map<String, String> m = new java.util.LinkedHashMap<>();
        if (node == null || node.isNull()) {
            return normalizeQaMap(m);
        }
        m.put("questionId", node.path("questionId").asText(""));
        m.put("title", node.path("title").asText(""));
        m.put("answerContent", node.path("answerContent").asText(""));
        m.put("bookmarked", node.path("bookmarked").asText("false"));
        return normalizeQaMap(m);
    }

    private void collectQaRecordsFromNode(
            com.fasterxml.jackson.databind.JsonNode node,
            java.util.List<java.util.Map<String, String>> result,
            java.util.Set<String> seen
    ) {
        if (node == null || node.isNull()) {
            return;
        }
        if (node.isArray()) {
            for (com.fasterxml.jackson.databind.JsonNode item : node) {
                collectQaRecordsFromNode(item, result, seen);
            }
            return;
        }
        if (!node.isObject()) {
            return;
        }

        // 先尝试把当前对象当作 QA 记录
        addIfValid(result, seen, jsonNodeToQaMap(node));

        // 再递归尝试常见容器字段
        String[] containerKeys = new String[] {"data", "items", "list", "records", "rows", "result"};
        for (String key : containerKeys) {
            com.fasterxml.jackson.databind.JsonNode child = node.get(key);
            if (child != null && !child.isNull()) {
                collectQaRecordsFromNode(child, result, seen);
            }
        }
    }

    private java.util.Map<String, String> normalizeQaMap(java.util.Map<String, String> source) {
        java.util.Map<String, String> m = new java.util.LinkedHashMap<>();
        String qid = source == null ? "" : source.getOrDefault("questionId", "");
        String title = source == null ? "" : source.getOrDefault("title", "");
        String answer = source == null ? "" : source.getOrDefault("answerContent", "");
        String bookmarked = source == null ? "false" : source.getOrDefault("bookmarked", "false");

        m.put("questionId", qid == null ? "" : qid.trim());
        m.put("title", title == null ? "" : title.trim());
        m.put("answerContent", answer == null ? "" : answer.trim());
        m.put("bookmarked", "true".equalsIgnoreCase(bookmarked) ? "true" : "false");
        return m;
    }

    private void addIfValid(
            java.util.List<java.util.Map<String, String>> result,
            java.util.Set<String> seen,
            java.util.Map<String, String> m
    ) {
        if (m == null) {
            return;
        }
        String qid = m.getOrDefault("questionId", "").trim();
        String title = m.getOrDefault("title", "").trim();
        String answer = m.getOrDefault("answerContent", "").trim();
        if (qid.isEmpty() && title.isEmpty() && answer.isEmpty()) {
            return;
        }
        String dedupKey = qid + "||" + title + "||" + answer;
        if (seen.contains(dedupKey)) {
            return;
        }
        seen.add(dedupKey);
        result.add(m);
    }

    private String extractKvValue(String line) {
        if (line == null) {
            return "";
        }
        int idx = line.indexOf(':');
        if (idx < 0) {
            idx = line.indexOf('：');
        }
        if (idx < 0) {
            idx = line.indexOf('=');
        }
        if (idx < 0 || idx >= line.length() - 1) {
            return "";
        }
        return line.substring(idx + 1).trim();
    }
}


