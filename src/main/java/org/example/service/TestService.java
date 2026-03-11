package org.example.service;

import org.example.pojo.Result;

/**
 * 测试服务接口
 */
public interface TestService {

    Result<String> getWelcomeMessage();
}
