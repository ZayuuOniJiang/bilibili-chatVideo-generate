package org.example.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.example.pojo.TemplateConfig;
import org.example.pojo.batch.BatchCreateRequest;
import org.example.pojo.batch.BatchJob;
import org.example.pojo.batch.BatchReviewConfirmRequest;
import org.example.pojo.batch.BatchReviewScriptItem;
import org.example.pojo.batch.BatchRunMode;
import org.example.pojo.batch.BatchTask;
import org.example.pojo.batch.BatchTaskStatus;
import org.example.service.BashboardService;
import org.example.service.BatchCreateService;
import org.example.service.TemplateManageService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.BufferedReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class BatchCreateServiceImpl implements BatchCreateService {

    private final BashboardService bashboardService;
    private final TemplateManageService templateManageService;

    @Value("${app.storage.qa-file:runtime-data/QA.txt}")
    private String qaFilePath;

    @Value("${app.storage.qa-legacy-file:src/main/resources/QA.txt}")
    private String qaLegacyFilePath;

    @Value("${app.batch.thread.core-size:2}")
    private int coreSize;

    @Value("${app.batch.thread.max-size:4}")
    private int maxSize;

    @Value("${app.batch.thread.queue-capacity:100}")
    private int queueCapacity;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private ThreadPoolExecutor executor;

    private final Map<String, BatchJob> jobs = new ConcurrentHashMap<String, BatchJob>();
    private final List<String> historyBatchIds = new CopyOnWriteArrayList<String>();

    @PostConstruct
    public void initExecutor() {
        executor = new ThreadPoolExecutor(
                coreSize,
                maxSize,
                60L,
                TimeUnit.SECONDS,
                new LinkedBlockingQueue<Runnable>(queueCapacity),
                new ThreadPoolExecutor.AbortPolicy()
        );
    }

    @PreDestroy
    public void destroyExecutor() {
        if (executor != null) {
            executor.shutdown();
        }
    }

    @Override
    public Result<Map<String, Object>> createBatch(BatchCreateRequest request) {
        if (request == null || isBlank(request.getTemplateFileName())) {
            return Result.fail(400, "templateFileName 不能为空");
        }

        Result<TemplateConfig> detail = templateManageService.detailTemplate(request.getTemplateFileName());
        if (detail.getCode() != 200 || detail.getData() == null) {
            return Result.fail(detail.getCode(), detail.getMessage());
        }
        TemplateConfig template = detail.getData();

        List<Map<String, String>> qaList = loadQaList();
        if (qaList.isEmpty()) {
            return Result.fail(400, "QA 列表为空，请先抓取或写入 QA.txt");
        }

        Set<String> qaIdSet = new HashSet<String>();
        if (request.getQaIds() != null) {
            for (String id : request.getQaIds()) {
                if (!isBlank(id)) {
                    qaIdSet.add(id.trim());
                }
            }
        }

        List<Map<String, String>> selected = new ArrayList<Map<String, String>>();
        for (Map<String, String> qa : qaList) {
            String qid = qa.get("questionId");
            if (qaIdSet.isEmpty() || qaIdSet.contains(qid)) {
                selected.add(qa);
            }
        }
        if (selected.isEmpty()) {
            return Result.fail(400, "未命中任何 QA 记录");
        }

        BatchRunMode mode = BatchRunMode.from(request.getRunMode());
        BatchJob job = new BatchJob();
        job.setBatchId(UUID.randomUUID().toString());
        job.setCreatedAt(new Date().getTime());
        job.setRunMode(mode);
        job.setTemplateFileName(request.getTemplateFileName());

        List<BatchTask> tasks = new ArrayList<BatchTask>();
        for (Map<String, String> qa : selected) {
            BatchTask task = new BatchTask();
            task.setTaskId(UUID.randomUUID().toString());
            task.setQuestionId(qa.get("questionId"));
            task.setTitle(qa.get("title"));
            task.setAnswerContent(qa.get("answerContent"));
            task.setProgress(0);
            task.setStatus(BatchTaskStatus.PENDING);
            tasks.add(task);
        }
        job.setTasks(tasks);
        jobs.put(job.getBatchId(), job);
        historyBatchIds.add(0, job.getBatchId());

        for (final BatchTask task : tasks) {
            submitTask(job, task, template, mode == BatchRunMode.AUTO);
        }

        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("batchId", job.getBatchId());
        data.put("taskCount", tasks.size());
        data.put("runMode", mode.name().toLowerCase(Locale.ROOT));
        return Result.ok(data);
    }

    @Override
    public Result<Void> confirmManualScripts(BatchReviewConfirmRequest request) {
        if (request == null || isBlank(request.getBatchId())) {
            return Result.fail(400, "batchId 不能为空");
        }
        BatchJob job = jobs.get(request.getBatchId().trim());
        if (job == null) {
            return Result.fail(404, "批次不存在");
        }
        if (job.getRunMode() != BatchRunMode.MANUAL) {
            return Result.fail(400, "仅 MANUAL 模式需要确认脚本");
        }
        if (request.getScripts() == null || request.getScripts().isEmpty()) {
            return Result.fail(400, "scripts 不能为空");
        }

        Map<String, String> scriptMap = new HashMap<String, String>();
        for (BatchReviewScriptItem item : request.getScripts()) {
            if (item == null || isBlank(item.getTaskId()) || isBlank(item.getTemplateText())) {
                continue;
            }
            scriptMap.put(item.getTaskId().trim(), item.getTemplateText());
        }

        Result<TemplateConfig> detail = templateManageService.detailTemplate(job.getTemplateFileName());
        if (detail.getCode() != 200 || detail.getData() == null) {
            return Result.fail(detail.getCode(), detail.getMessage());
        }
        TemplateConfig template = detail.getData();

        for (final BatchTask task : job.getTasks()) {
            if (!scriptMap.containsKey(task.getTaskId())) {
                continue;
            }
            if (task.getStatus() != BatchTaskStatus.SCRIPT_REVIEW_PENDING) {
                continue;
            }
            task.setScriptDraft(scriptMap.get(task.getTaskId()));
            submitVideoOnly(job, task, template);
        }
        return Result.ok();
    }

    @Override
    public Result<Map<String, Object>> getBatchProgress(String batchId) {
        if (isBlank(batchId)) {
            return Result.fail(400, "batchId 不能为空");
        }
        BatchJob job = jobs.get(batchId.trim());
        if (job == null) {
            return Result.fail(404, "批次不存在");
        }

        int total = job.getTasks().size();
        int sumProgress = 0;
        int success = 0;
        int failed = 0;
        int cancelled = 0;
        for (BatchTask t : job.getTasks()) {
            sumProgress += t.getProgress();
            if (t.getStatus() == BatchTaskStatus.SUCCESS) {
                success++;
            } else if (t.getStatus() == BatchTaskStatus.FAILED) {
                failed++;
            } else if (t.getStatus() == BatchTaskStatus.CANCELLED) {
                cancelled++;
            }
        }
        int overall = total == 0 ? 0 : (sumProgress / total);

        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("batchId", job.getBatchId());
        data.put("runMode", job.getRunMode().name().toLowerCase(Locale.ROOT));
        data.put("templateFileName", job.getTemplateFileName());
        data.put("createdAt", job.getCreatedAt());
        data.put("cancelled", job.isCancelled());
        data.put("overallProgress", overall);
        data.put("successCount", success);
        data.put("failedCount", failed);
        data.put("cancelledCount", cancelled);
        data.put("taskCount", total);
        data.put("tasks", job.getTasks());
        return Result.ok(data);
    }

    @Override
    public Result<Void> cancelBatch(String batchId) {
        if (isBlank(batchId)) {
            return Result.fail(400, "batchId 不能为空");
        }
        BatchJob job = jobs.get(batchId.trim());
        if (job == null) {
            return Result.fail(404, "批次不存在");
        }
        job.setCancelled(true);
        for (BatchTask task : job.getTasks()) {
            if (task.getStatus() == BatchTaskStatus.PENDING || task.getStatus() == BatchTaskStatus.SCRIPT_REVIEW_PENDING) {
                task.setStatus(BatchTaskStatus.CANCELLED);
                task.setProgress(100);
            }
        }
        return Result.ok();
    }

    @Override
    public Result<Object> listBatchHistory() {
        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
        for (String id : historyBatchIds) {
            BatchJob job = jobs.get(id);
            if (job == null) {
                continue;
            }
            Map<String, Object> item = new LinkedHashMap<String, Object>();
            item.put("batchId", job.getBatchId());
            item.put("createdAt", job.getCreatedAt());
            item.put("runMode", job.getRunMode().name().toLowerCase(Locale.ROOT));
            item.put("templateFileName", job.getTemplateFileName());
            item.put("taskCount", job.getTasks().size());
            list.add(item);
        }
        return Result.ok((Object) list);
    }

    private void submitTask(final BatchJob job, final BatchTask task, final TemplateConfig template, final boolean autoMode) {
        try {
            executor.execute(new Runnable() {
                @Override
                public void run() {
                    processTask(job, task, template, autoMode);
                }
            });
        } catch (RejectedExecutionException e) {
            log.warn("批量任务被线程池拒绝，可能队列已满", e);
            markFailed(task, "任务提交失败：线程池繁忙，请稍后重试");
        } catch (Exception e) {
            log.warn("提交批量任务失败", e);
            markFailed(task, "任务提交失败：" + e.getMessage());
        }
    }

    private void submitVideoOnly(final BatchJob job, final BatchTask task, final TemplateConfig template) {
        try {
            executor.execute(new Runnable() {
                @Override
                public void run() {
                    runVideoGeneration(job, task, template);
                }
            });
        } catch (RejectedExecutionException e) {
            log.warn("视频生成任务被线程池拒绝，可能队列已满", e);
            markFailed(task, "任务提交失败：线程池繁忙，请稍后重试");
        } catch (Exception e) {
            log.warn("提交视频生成任务失败", e);
            markFailed(task, "任务提交失败：" + e.getMessage());
        }
    }

    private void processTask(BatchJob job, BatchTask task, TemplateConfig template, boolean autoMode) {
        if (job.isCancelled()) {
            task.setStatus(BatchTaskStatus.CANCELLED);
            task.setProgress(100);
            return;
        }

        task.setStatus(BatchTaskStatus.SCRIPT_GENERATING);
        task.setProgress(10);

        Result<String> scriptRes = bashboardService.generateDialogTemplate(
                safe(task.getTitle()),
                safe(task.getAnswerContent()),
                template.getRoleAPersona(),
                template.getRoleBPersona(),
                template.getTargetWordCount()
        );
        if (scriptRes.getCode() != 200 || isBlank(scriptRes.getData())) {
            markFailed(task, "脚本生成失败：" + scriptRes.getMessage());
            return;
        }

        task.setScriptDraft(scriptRes.getData());
        task.setProgress(30);

        if (!autoMode) {
            task.setStatus(BatchTaskStatus.SCRIPT_REVIEW_PENDING);
            task.setProgress(40);
            return;
        }

        runVideoGeneration(job, task, template);
    }

    private void runVideoGeneration(BatchJob job, BatchTask task, TemplateConfig template) {
        if (job.isCancelled()) {
            task.setStatus(BatchTaskStatus.CANCELLED);
            task.setProgress(100);
            return;
        }

        task.setStatus(BatchTaskStatus.VIDEO_GENERATING);
        task.setProgress(70);

        Result<String> videoRes = bashboardService.confirmTemplateAndGenerateVideoByTemplate(
                safe(task.getTitle()),
                safe(task.getScriptDraft()),
                template
        );

        if (videoRes.getCode() != 200 || isBlank(videoRes.getData())) {
            markFailed(task, "视频生成失败：" + videoRes.getMessage());
            return;
        }

        task.setOutputPath(videoRes.getData());
        task.setStatus(BatchTaskStatus.SUCCESS);
        task.setProgress(100);
    }

    private void markFailed(BatchTask task, String message) {
        task.setStatus(BatchTaskStatus.FAILED);
        task.setProgress(100);
        task.setErrorMessage(message);
    }

    private List<Map<String, String>> loadQaList() {
        List<Path> paths = new ArrayList<Path>();
        Path main = Paths.get(qaFilePath).toAbsolutePath().normalize();
        Path legacy = Paths.get(qaLegacyFilePath).toAbsolutePath().normalize();

        if (Files.exists(main)) {
            paths.add(main);
        }
        if (Files.exists(legacy)) {
            paths.add(legacy);
        }
        if (paths.isEmpty()) {
            return Collections.emptyList();
        }

        List<Map<String, String>> list = new ArrayList<Map<String, String>>();
        Set<String> dedup = new HashSet<String>();
        for (Path p : paths) {
            try (BufferedReader br = Files.newBufferedReader(p, StandardCharsets.UTF_8)) {
                String line;
                while ((line = br.readLine()) != null) {
                    String l = line.trim();
                    if (l.startsWith("\uFEFF")) {
                        l = l.substring(1).trim();
                    }
                    if (l.isEmpty()) {
                        continue;
                    }
                    try {
                        Map<String, String> m = objectMapper.readValue(l, new TypeReference<Map<String, String>>() {});
                        String qid = safe(m.get("questionId"));
                        String title = safe(m.get("title"));
                        String answer = safe(m.get("answerContent"));
                        if (isBlank(qid) || isBlank(answer)) {
                            continue;
                        }
                        String key = qid + "||" + title + "||" + answer;
                        if (!dedup.add(key)) {
                            continue;
                        }
                        Map<String, String> item = new LinkedHashMap<String, String>();
                        item.put("questionId", qid);
                        item.put("title", title);
                        item.put("answerContent", answer);
                        list.add(item);
                    } catch (Exception ignore) {
                        log.warn("解析 QA 行失败：{}", l);
                    }
                }
            } catch (Exception e) {
                log.warn("读取 QA 文件失败：{}", p, e);
            }
        }
        return list;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String safe(String s) {
        return s == null ? "" : s.trim();
    }
}

