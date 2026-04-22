package org.example.service;

import org.example.pojo.Result;
import org.example.pojo.TemplateConfig;

import java.util.List;
import java.util.Map;

public interface TemplateManageService {

    Result<List<Map<String, String>>> listTemplates();

    Result<TemplateConfig> detailTemplate(String fileName);

    Result<Map<String, String>> saveTemplate(TemplateConfig config);

    Result<Void> updateTemplate(String fileName, TemplateConfig config);

    Result<Void> deleteTemplate(String fileName);
}
