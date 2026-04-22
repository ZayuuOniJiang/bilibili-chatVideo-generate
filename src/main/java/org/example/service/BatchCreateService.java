package org.example.service;

import org.example.pojo.Result;
import org.example.pojo.batch.BatchCreateRequest;
import org.example.pojo.batch.BatchReviewConfirmRequest;

import java.util.Map;

public interface BatchCreateService {

    Result<Map<String, Object>> createBatch(BatchCreateRequest request);

    Result<Void> confirmManualScripts(BatchReviewConfirmRequest request);

    Result<Map<String, Object>> getBatchProgress(String batchId);

    Result<Void> cancelBatch(String batchId);

    Result<Object> listBatchHistory();
}
