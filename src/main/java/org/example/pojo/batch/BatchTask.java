package org.example.pojo.batch;

import lombok.Data;

/**
 * 单个批量任务。
 */
@Data
public class BatchTask {

    private String taskId;
    private String questionId;
    private String title;
    private String answerContent;

    private String scriptDraft;

    private BatchTaskStatus status = BatchTaskStatus.PENDING;
    private int progress;
    private String outputPath;
    private String errorMessage;
}

