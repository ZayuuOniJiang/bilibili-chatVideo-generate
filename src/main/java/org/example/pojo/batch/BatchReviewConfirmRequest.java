package org.example.pojo.batch;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class BatchReviewConfirmRequest {

    private String batchId;
    private List<BatchReviewScriptItem> scripts = new ArrayList<BatchReviewScriptItem>();
}
