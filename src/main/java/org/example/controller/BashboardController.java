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
        java.nio.file.Path path = resolveQaPathForRead();
        java.util.List<java.util.Map<String, String>> list = new java.util.ArrayList<>();
        if (!java.nio.file.Files.exists(path)) {
            return Result.ok(list);
        }
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        try (java.io.BufferedReader reader = java.nio.file.Files.newBufferedReader(path, java.nio.charset.StandardCharsets.UTF_8)) {
            String line;
            int idx = 1;
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
                    java.util.Map<String, String> item = new java.util.LinkedHashMap<>();
                    item.put("index", String.valueOf(idx));
                    item.put("questionId", m.getOrDefault("questionId", ""));
                    item.put("title", m.getOrDefault("title", ""));
                    item.put("answerContent", m.getOrDefault("answerContent", ""));
                    item.put("bookmarked", m.getOrDefault("bookmarked", "false"));
                    list.add(item);
                    idx++;
                } catch (Exception e) {
                    log.warn("解析 QA.txt 某行失败，line={}", line, e);
                }
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
        return primary;
    }
}


