package org.example.service.impl;

import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.service.TestService;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class TestServiceImpl implements TestService {

    @Override
    public Result<String> getWelcomeMessage() {
        log.info("TestService.getWelcomeMessage 被调用");
        return Result.ok("欢迎使用 B站 跑酷+角色问答 视频生成网站");
    }
}
