package org.example.service;

import org.example.pojo.Result;
import org.example.pojo.SubtitleStyleConfig;
import org.example.pojo.TemplateConfig;
import org.springframework.web.multipart.MultipartFile;

/**
 * 仪表盘页面（/bashboard）整体流程 Service：
 * - 调用千问 Responses API 生成对话模板
 * - 保存最终确认的模板为文本文件
 * - 调用千问 TTS 生成音频、下载并计算时长
 * - 使用 ffmpeg 将多段音频按时间轴插入到跑酷视频中并剪辑结尾
 */
public interface BashboardService {

    /**
     * 操作一：根据知乎标题和高赞回答，调用千问模型生成对话模板。
     *
     * @param title   知乎标题
     * @param content 高赞文本回答
     * @return 模板文本，使用 {@link Result#ok(Object)} 封装
     */
        Result<String> generateDialogTemplate(
            String title,
            String content,
            String roleAPersona,
            String roleBPersona,
            Integer targetWordCount
        );

    /**
     * 操作二 ~ 五：前端在用户确认模板后，提交模板 + 跑酷视频 + 训练音频，
     * 服务端负责：
     * <ul>
     *     <li>保存模板为 contents 目录下的 txt 文件</li>
     *     <li>按角色逐句拆分台词</li>
     *     <li>基于训练音频创建声音（单人 / 双人）并批量 TTS 合成</li>
     *     <li>使用 OkHttp3 下载 OSS 上的音频到 sounds 目录并记录时长</li>
     *     <li>调用 ffmpeg 将多段音频按时间轴插入到跑酷视频中，并在文本读完处剪辑结束</li>
     * </ul>
     *
     * @param title          知乎标题（用于 txt 文件名以及生成的音频命名）
     * @param templateText   已确认的模板全文
     * @param mode           single / double：单人视频模式 or 双人视频模式
     * @param video          跑酷视频（用户上传的 MP4）
     * @param audioRoleA     角色 A（或单人模式下唯一角色）的训练音频
     * @param audioRoleB     角色 B 训练音频（仅双人模式必填，其余场景可为 null）
     * @param instruction    指令控制文本（可选，会传给 TTS 的 instructions 字段，用于控制整体语气/语速/情感等）
     * @return 生成结果，data 一般为最终视频文件的本地绝对路径（便于后续下载或预览）
     */
    Result<String> confirmTemplateAndGenerateVideo(
            String title,
            String templateText,
            String mode,
            MultipartFile video,
            MultipartFile audioRoleA,
            MultipartFile audioRoleB,
            MultipartFile bgm,
            String bgmVolume,
            String instruction,
            SubtitleStyleConfig subtitleStyle,
            boolean exportPortrait,
            MultipartFile[] roleAImages,
            MultipartFile[] roleBImages,
            String roleAImagePosXPercent,
            String roleAImagePosYPercent,
            String roleAImageSizePercent,
            String roleAImageFlip,
            String roleBImagePosXPercent,
            String roleBImagePosYPercent,
            String roleBImageSizePercent,
            String roleBImageFlip
    );

            /**
             * 批量模式：按模板中的本地文件路径复用单次视频生成链路。
             */
            Result<String> confirmTemplateAndGenerateVideoByTemplate(
                String title,
                String templateText,
                TemplateConfig templateConfig
            );
}


