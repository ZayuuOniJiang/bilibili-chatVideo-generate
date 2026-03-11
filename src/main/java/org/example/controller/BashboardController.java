package org.example.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.service.BashboardService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

/**
 * /bashboard 仪表盘：承载 README 中描述的整体业务流程。
 */
@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping
public class BashboardController {

    private final BashboardService bashboardService;

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
            @RequestParam("content") String content
    ) {
        log.info("调用千问生成对话模板, title={}", title);
        return bashboardService.generateDialogTemplate(title, content);
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
            @RequestParam(value = "instruction", required = false) String instruction
    ) {
        log.info("确认模板并生成视频, mode={}, title={}", mode, title);
        return bashboardService.confirmTemplateAndGenerateVideo(title, templateText, mode, video, audioRoleA, audioRoleB, instruction);
    }
}

