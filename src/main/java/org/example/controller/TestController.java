package org.example.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.service.TestService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Slf4j
@Controller
@RequiredArgsConstructor
public class TestController {

    private final TestService testService;

    @GetMapping({"/", "/index"})
    public String index(Model model) {
        log.info("访问首页");
        model.addAttribute("title", "B站 跑酷+角色问答 视频生成 - 测试页");
        model.addAttribute("welcome", testService.getWelcomeMessage().getData());
        return "index";
    }

    @GetMapping("/api/hello")
    @ResponseBody
    public Result<String> hello() {
        return testService.getWelcomeMessage();
    }

    @GetMapping("/api/error-test")
    @ResponseBody
    public Result<String> errorTest() {
        throw new org.example.exception.BusinessException(400, "这是一个测试业务异常");
    }
}
