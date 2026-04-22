package org.example.pojo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 批量创建模板配置（文本 JSON 落盘）。
 */
@Data
public class TemplateConfig {

    private String templateName;

    private String videoPath;
    private String mode;
    private String audioRoleAPath;
    private String audioRoleBPath;
    private String bgmPath;
    private Double bgmVolume;
    private String instruction;

    private String roleAPersona;
    private String roleBPersona;
    private Integer targetWordCount;

    private Boolean exportPortrait;

    private List<String> roleAImagePaths = new ArrayList<String>();
    private List<String> roleBImagePaths = new ArrayList<String>();

    private String roleALabel;
    private String roleBLabel;

    private String roleAImagePosXPercent;
    private String roleAImagePosYPercent;
    private String roleAImageSizePercent;
    private Boolean roleAImageFlip;

    private String roleBImagePosXPercent;
    private String roleBImagePosYPercent;
    private String roleBImageSizePercent;
    private Boolean roleBImageFlip;

    private String subtitleWrapLength;
    private String subtitleFontName;
    private String subtitleFontSize;
    private String subtitlePrimaryColor;
    private String subtitleOutlineColor;
    private String subtitleOutline;
    private String subtitleShadow;
    private String subtitleVerticalOffsetPercent;
}

