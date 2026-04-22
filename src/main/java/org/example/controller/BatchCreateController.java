package org.example.controller;

import org.example.pojo.Result;
import org.example.pojo.batch.BatchCreateRequest;
import org.example.pojo.batch.BatchReviewConfirmRequest;
import org.example.service.BatchCreateService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
@RequestMapping
public class BatchCreateController {

    private final BatchCreateService batchCreateService;

    public BatchCreateController(BatchCreateService batchCreateService) {
        this.batchCreateService = batchCreateService;
    }

    @GetMapping("/batch-create")
    public String batchCreatePage(Model model) {
        model.addAttribute("title", "批量创建视频 - 仪表盘风格");
        return "batch-create";
    }

    @PostMapping(value = "/api/batch/create", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> createBatch(@RequestBody BatchCreateRequest request) {
        return batchCreateService.createBatch(request);
    }

    @PostMapping(value = "/api/batch/review/confirm", produces = "application/json")
    @ResponseBody
    public Result<Void> confirmReview(@RequestBody BatchReviewConfirmRequest request) {
        return batchCreateService.confirmManualScripts(request);
    }

    @GetMapping(value = "/api/batch/progress", produces = "application/json")
    @ResponseBody
    public Result<Map<String, Object>> batchProgress(@RequestParam("batchId") String batchId) {
        return batchCreateService.getBatchProgress(batchId);
    }

    @PostMapping(value = "/api/batch/cancel", produces = "application/json")
    @ResponseBody
    public Result<Void> cancelBatch(@RequestParam("batchId") String batchId) {
        return batchCreateService.cancelBatch(batchId);
    }

    @GetMapping(value = "/api/batch/history", produces = "application/json")
    @ResponseBody
    public Result<Object> listHistory() {
        return batchCreateService.listBatchHistory();
    }
}

