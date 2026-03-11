package org.example.service;

/**
 * 千问 TTS：声音复刻 + 语音合成
 */
public interface QwenTtsService {

    /**
     * 用上传的音频创建专属音色，返回 voice 标识
     */
    String createVoice(byte[] audioBytes, String preferredName, String audioMimeType);

    /**
     * 使用指定音色将文本合成为语音，返回音频 URL
     *
     * @param voiceId     createVoice 返回的音色 ID
     * @param text        待合成文本
     * @param instructions 指令控制描述（风格/类型），可为空
     */
    String synthesize(String voiceId, String text, String instructions);
}
