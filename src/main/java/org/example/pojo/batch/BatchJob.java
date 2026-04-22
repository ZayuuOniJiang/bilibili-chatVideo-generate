package org.example.pojo.batch;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 批量任务批次。
 */
@Data
public class BatchJob {

    private String batchId;
    private String templateFileName;
    private BatchRunMode runMode;
    private long createdAt;

    private volatile boolean cancelled;

    private List<BatchTask> tasks = new ArrayList<BatchTask>();
}

