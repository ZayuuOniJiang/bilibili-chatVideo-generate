package org.example.pojo;

import lombok.Data;

/**
 * 字幕样式配置：由前端提交，用于生成 ASS 字幕样式。
 */
@Data
public class SubtitleStyleConfig {

    /**
     * 字体名称，例如 "Microsoft YaHei"。
     */
    private String fontName;

    /**
     * 字号，例如 "32"。
     */
    private String fontSize;

    /**
     * 主文字颜色，格式建议为 #RRGGBB。
     */
    private String primaryColor;

    /**
     * 描边颜色，格式建议为 #RRGGBB。
     */
    private String outlineColor;

    /**
     * 描边粗细，整数，默认 2。
     */
    private String outline;

    /**
     * 阴影大小，整数，默认 1。
     */
    private String shadow;

    /**
     * 垂直位置：bottom / middle / top。
     */
    private String position;

    /**
     * 每行最多字符数（用于自动换行），例如 "15"。
     */
    private String wrapLength;

    /**
     * 垂直偏移百分比（0-50），表示字幕底部距离屏幕底部占总高度的百分比。
     * 例如 5 表示离底边 5% 的高度。
     */
    private String verticalOffsetPercent;

    /**
     * 角色A在字幕中显示的名称，例如“熊二”或“角色A”。
     * 若为空，则默认使用“角色A”。
     */
    private String roleALabel;

    /**
     * 角色B在字幕中显示的名称，例如“熊大”或“角色B”。
     * 若为空，则默认使用“角色B”。
     */
    private String roleBLabel;
}