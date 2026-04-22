package org.example.service;

import org.example.pojo.Result;
import org.example.pojo.biliup.BiliupLoginRequest;
import org.example.pojo.biliup.BiliupUploadRequest;

import java.util.Map;

public interface BiliupService {

    Result<Map<String, Object>> getDefaultConfig();

    Result<Map<String, Object>> openLoginShell(BiliupLoginRequest request);

    Result<Map<String, Object>> checkLoginStatus(String exePath, String workDir);

    Result<Map<String, Object>> startUpload(BiliupUploadRequest request);

    Result<Map<String, Object>> getUploadTask(String taskId);
}
