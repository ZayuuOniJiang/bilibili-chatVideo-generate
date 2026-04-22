package org.example.pojo.batch;

/**
 * 批量任务状态。
 */
public enum BatchTaskStatus {
    PENDING,
    SCRIPT_GENERATING,
    SCRIPT_REVIEW_PENDING,
    VIDEO_GENERATING,
    SUCCESS,
    FAILED,
    CANCELLED
}

