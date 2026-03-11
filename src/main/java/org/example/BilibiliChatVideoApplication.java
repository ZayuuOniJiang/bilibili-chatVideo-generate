package org.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * B站 跑酷+角色问答 视频生成网站启动类
 */
@SpringBootApplication
public class BilibiliChatVideoApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(BilibiliChatVideoApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(BilibiliChatVideoApplication.class, args);
    }
}
