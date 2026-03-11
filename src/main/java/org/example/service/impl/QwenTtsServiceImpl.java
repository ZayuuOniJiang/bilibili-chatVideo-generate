package org.example.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.extern.slf4j.Slf4j;
import org.example.service.QwenTtsService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;

/**
 * 千问 TTS：声音复刻（customization）+ 多模态对话 TTS 生成
 */
@Slf4j
@Service
public class QwenTtsServiceImpl implements QwenTtsService {

    @Value("${dashscope.api-key}")
    private String apiKey;

    @Value("${dashscope.tts-customization-url}")
    private String customizationUrl;

    @Value("${dashscope.tts-model}")
    private String ttsModel;

    @Value("${dashscope.tts-generation-url}")
    private String generationUrl;

    private static final String ENROLLMENT_MODEL = "qwen-voice-enrollment";
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String createVoice(byte[] audioBytes, String preferredName, String audioMimeType) {
        if (audioMimeType == null || audioMimeType.isEmpty()) {
            audioMimeType = "audio/mpeg";
        }
        String dataUri = "data:" + audioMimeType + ";base64," + Base64.getEncoder().encodeToString(audioBytes);

        ObjectNode input = objectMapper.createObjectNode();
        input.put("action", "create");
        input.put("target_model", ttsModel);
        input.put("preferred_name", preferredName != null ? preferredName : "custom_voice");
        ObjectNode audio = objectMapper.createObjectNode();
        audio.put("data", dataUri);
        input.set("audio", audio);

        ObjectNode body = objectMapper.createObjectNode();
        body.put("model", ENROLLMENT_MODEL);
        body.set("input", input);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    customizationUrl,
                    HttpMethod.POST,
                    new HttpEntity<>(objectMapper.writeValueAsString(body), headers),
                    String.class
            );
            if (response.getStatusCode() != HttpStatus.OK || response.getBody() == null) {
                throw new RuntimeException("声音复刻失败: HTTP " + response.getStatusCode());
            }
            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode output = root.path("output");
            if (output.isMissingNode()) {
                throw new RuntimeException("声音复刻返回无 output: " + response.getBody());
            }
            String voice = output.path("voice").asText(null);
            if (voice == null) {
                throw new RuntimeException("声音复刻返回无 voice: " + response.getBody());
            }
            log.info("声音复刻成功, voice={}", voice);
            return voice;
        } catch (Exception e) {
            log.error("声音复刻异常", e);
            throw new RuntimeException("声音复刻失败: " + e.getMessage());
        }
    }

    @Override
    public String synthesize(String voiceId, String text, String instructions) {
        // 官方文档：voice 必须在 input 中，否则服务端会使用默认音色 Cherry（仅系统音色模型支持），复刻音色会报错
        ObjectNode input = objectMapper.createObjectNode();
        input.put("text", text);
        input.put("voice", voiceId);
        if (instructions != null && !instructions.trim().isEmpty()) {
            input.put("instructions", instructions.trim());
        }

        ObjectNode body = objectMapper.createObjectNode();
        body.put("model", ttsModel);
        body.set("input", input);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    generationUrl,
                    HttpMethod.POST,
                    new HttpEntity<>(objectMapper.writeValueAsString(body), headers),
                    String.class
            );
            if (response.getStatusCode() != HttpStatus.OK || response.getBody() == null) {
                throw new RuntimeException("TTS 合成失败: HTTP " + response.getStatusCode() + " " + response.getBody());
            }
            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode output = root.path("output");
            if (output.isMissingNode()) {
                throw new RuntimeException("TTS 返回无 output: " + response.getBody());
            }
            String url = null;
            JsonNode audio = output.path("audio");
            if (!audio.isMissingNode()) {
                JsonNode u = audio.path("url");
                if (!u.isMissingNode() && !u.isNull()) {
                    url = u.asText(null);
                }
            }
            if (url == null || url.isEmpty()) {
                JsonNode choices = output.path("choices");
                if (!choices.isMissingNode() && choices.isArray() && choices.size() > 0) {
                    JsonNode msg = choices.get(0).path("message").path("content");
                    if (msg.isArray() && msg.size() > 0) {
                        for (JsonNode part : msg) {
                            JsonNode u = part.path("url");
                            if (!u.isMissingNode() && !u.isNull()) {
                                url = u.asText(null);
                                break;
                            }
                        }
                    }
                }
            }
            if (url == null || url.isEmpty()) {
                throw new RuntimeException("TTS 返回的音频 URL 为空，output: " + output);
            }
            log.info("TTS 合成成功, url={}", url);
            return url;
        } catch (Exception e) {
            log.error("TTS 合成异常", e);
            throw new RuntimeException("TTS 合成失败: " + e.getMessage());
        }
    }
}
