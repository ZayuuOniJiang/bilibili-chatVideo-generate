package org.example.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.pojo.Result;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 知乎相关调用：热榜 questionId 拉取 + 单问题最高赞回答抓取。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ZhihuService {

    private static final String ZHIHU_USER_AGENT =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                    + "(KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36";

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 从知乎问题回答接口中找出当前最高赞的回答。
     * 逻辑来源于 TestPageController.fetchZhihuTopAnswer。
     */
    public Result<Map<String, String>> fetchTopAnswer(String questionId, String cookie,
                                                      int pageSize, int maxPages) {
        if (questionId == null || questionId.trim().isEmpty()) {
            return Result.fail(400, "请输入知乎问题 ID（数字部分）");
        }
        if (cookie == null || cookie.trim().isEmpty()) {
            return Result.fail(400, "请粘贴你在知乎网页中复制的完整 Cookie");
        }

        try {
            String trimmedId = questionId.trim();
            String baseUrl = "https://www.zhihu.com/api/v4/questions/" + trimmedId + "/answers";

            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.USER_AGENT, ZHIHU_USER_AGENT);
            headers.set(HttpHeaders.COOKIE, cookie.trim());
            headers.set(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);

            JsonNode bestAnswer = null;
            long bestVote = -1;

            for (int i = 0; i < maxPages; i++) {
                int offset = i * pageSize;
                String url = baseUrl
                        + "?include=content,voteup_count,question.title"
                        + "&limit=" + pageSize
                        + "&offset=" + offset
                        + "&sort_by=default";

                ResponseEntity<String> response = restTemplate.exchange(
                        url,
                        HttpMethod.GET,
                        new HttpEntity<>(headers),
                        String.class
                );

                if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                    if (i == 0) {
                        return Result.fail(500, "调用知乎接口失败，HTTP " + response.getStatusCodeValue());
                    }
                    break;
                }

                JsonNode root = objectMapper.readTree(response.getBody());
                JsonNode dataNode = root.path("data");
                if (!dataNode.isArray() || dataNode.size() == 0) {
                    break;
                }

                for (JsonNode ans : dataNode) {
                    long voteCount = ans.path("voteup_count").asLong(0);
                    if (bestAnswer == null || voteCount > bestVote) {
                        bestVote = voteCount;
                        bestAnswer = ans;
                    }
                }

                JsonNode pagingNode = root.path("paging");
                if (pagingNode.isObject() && pagingNode.path("is_end").asBoolean(false)) {
                    break;
                }
            }

            if (bestAnswer == null) {
                return Result.fail(500, "未能找到最高赞回答");
            }

            String title = "";
            JsonNode questionNode = bestAnswer.path("question");
            if (!questionNode.isMissingNode() && !questionNode.isNull()) {
                title = questionNode.path("title").asText("");
            }
            if (title == null || title.trim().isEmpty()) {
                title = "问题 " + questionId.trim();
            }

            String content = bestAnswer.path("content").asText("");
            if (content == null || content.trim().isEmpty()) {
                return Result.fail(500, "最高赞回答内容为空");
            }

            // 去掉回答中的 <img ...> 标签，避免在前端和持久化文本中出现无用的图片占位
            content = stripImgTags(content);

            Map<String, String> result = new LinkedHashMap<>();
            result.put("questionId", questionId.trim());
            result.put("title", title.trim());
            result.put("answerContent", content);
            return Result.ok(result);
        } catch (Exception e) {
            log.warn("调用知乎回答接口失败, questionId={}", questionId, e);
            return Result.fail(500, "调用知乎接口失败：" + e.getMessage());
        }
    }

    /**
     * 调用知乎热榜接口，拉取前 limit 条热门问题的 questionId 与标题。
     */
    public Result<List<Map<String, String>>> fetchHotQuestions(String cookie, int limit) {
        if (cookie == null || cookie.trim().isEmpty()) {
            return Result.fail(400, "请粘贴你在知乎网页中复制的完整 Cookie");
        }
        if (limit <= 0) {
            limit = 10;
        }
        try {
            String url = "https://api.zhihu.com/topstory/hot-list?limit=" + limit + "&reverse_order=0";

            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.USER_AGENT, ZHIHU_USER_AGENT);
            headers.set(HttpHeaders.COOKIE, cookie.trim());
            headers.set(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);

            ResponseEntity<String> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    new HttpEntity<>(headers),
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                return Result.fail(500, "调用知乎热榜接口失败，HTTP " + response.getStatusCodeValue());
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode dataNode = root.path("data");
            if (!dataNode.isArray() || dataNode.size() == 0) {
                return Result.fail(500, "知乎热榜返回为空");
            }

            List<Map<String, String>> list = new ArrayList<>();
            for (JsonNode node : dataNode) {
                JsonNode target = node.path("target");
                if (target.isMissingNode() || target.isNull()) {
                    continue;
                }
                String qid = target.path("id").asText("");
                String title = target.path("title").asText("");
                if (qid == null || qid.trim().isEmpty()) {
                    continue;
                }
                Map<String, String> m = new LinkedHashMap<>();
                m.put("questionId", qid.trim());
                m.put("title", title == null ? "" : title.trim());
                list.add(m);
            }
            return Result.ok(list);
        } catch (Exception e) {
            log.warn("调用知乎热榜接口失败", e);
            return Result.fail(500, "调用知乎热榜接口失败：" + e.getMessage());
        }
    }

    /**
     * 删除 HTML 文本中的所有 <img ...> 标签（不保留任何占位），大小写不敏感。
     */
    private String stripImgTags(String html) {
        if (html == null || html.isEmpty()) {
            return html;
        }
        // (?i) 大小写不敏感；尽量只匹配单个 img 标签，不跨越多行文本
        return html.replaceAll("(?i)<img[^>]*>", "");
    }
}

