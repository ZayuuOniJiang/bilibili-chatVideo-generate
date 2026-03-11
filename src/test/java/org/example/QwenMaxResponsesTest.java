package org.example;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.Date;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * 使用 RestTemplate 调用 DashScope 协议兼容 Responses API，
 * 模型固定为 qwen3-max，并通过日志打印完整响应，方便人工查看。
 */
@Slf4j
@SpringBootTest
public class QwenMaxResponsesTest {

    @Value("${dashscope.api-key}")
    private String apiKey;

    @Value("${dashscope.responses-url}")
    private String responsesUrl;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void callQwen3MaxAndLogResponse() throws Exception {
        assertNotNull(apiKey, "dashscope.api-key 未配置");
        assertNotNull(responsesUrl, "dashscope.responses-url 未配置");

        // 按官方示例：model + input（字符串），不启用 stream，便于在测试中一次性查看完整响应
        String requestJson = "{"
                + "\"model\": \"qwen3-max\","
                + "\"input\": \"你现在是一个专门用来返回文本的接口机器人。你要根据我接下来给你的摘抄自知乎的标题和文本展开角色A和角色B的讨论，其中角色A扮演熊出没中的熊二负责提问者，角色B扮演熊出没中的熊大担当理性的回答者。标题内容为：{有没有人科普一下，美国以色列打击伊朗对中华人民共和国是好事还是坏事？}，文本内容为：{不用专业术语，我说人话。1.加油贵中国约1/3的原油要从霍尔木兹海峡过。现在海峡被封锁了。国际油价已经涨了→国内油价会跟着涨→你加满一箱油，可能多掏几十块。2.外卖贵油价涨 → 物流成本涨 → 外卖配送费涨。你点的那份20块钱的饭，配送费可能从3块变5块。3.机票贵国际油价涨 → 航空煤油涨 → 机票燃油附加费涨。你计划五一去云南、去三亚、回老家，机票可能比去年贵几百。4.物价涨物流涨了、能源涨了、原材料涨了 → 超市里的东西跟着涨。你昨天买的牛奶，明天可能贵5毛。你上周买的纸巾，下周可能贵1块。单个看不多，加起来你每个月多花几百。5.工作可能会更难企业成本涨了，包括物流、能源、原材料成本 → 利润降了 → 招人少了、裁员多了。你找工作、换工作、谈加薪，可能都比去年难。6.但有人赚了，如果你买对了股票。 军工涨了，因为打仗要武器。油气涨了，因为油价涨。 黄金涨了，因为要避险。如果你刚好买了这些，你赚了。如果你买了科技、消费，你亏了。同一天，有人回本，有人跳楼。2026年才过两个月，世界已经乱成这样。接下来会怎样，谁也不知道。但我知道，2026年，注定是活在历史里的一年。}，接下来你的回答模板只能是{角色A：台词。角色B：台词。}这样的形式来返回文本。同时你可以根据输入的文本来扩展对话内容，尽量让最终输出的模板控制在1200字左右\""
                + "}";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        HttpEntity<String> entity = new HttpEntity<>(requestJson, headers);
        ResponseEntity<String> response = restTemplate.exchange(
                responsesUrl,
                HttpMethod.POST,
                entity,
                String.class
        );

        assertEquals(200, response.getStatusCodeValue(), "HTTP 状态码应为 200");
        String body = response.getBody();
        assertNotNull(body, "响应体不应为空");

        // 解析 JSON 并用日志美化输出
        JsonNode root = objectMapper.readTree(body);
        String pretty = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
        log.info("DashScope qwen3-max 响应：\n{}", pretty);

        // 从响应中提取 output[0].content[0].text
        JsonNode textNode = root
                .path("output")
                .path(0)
                .path("content")
                .path(0)
                .path("text");

        assertNotNull(textNode);
        String text = textNode.asText();

        // 使用当前时间作为文件名，例如 20260303_153045.txt
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String fileName = timestamp + ".txt";

        // 写入到 src/main/resources/contents 目录下
        Path dir = Paths.get("src/main/resources/contents");
        Files.createDirectories(dir);
        Path filePath = dir.resolve(fileName);

        Files.write(
                filePath,
                text.getBytes(StandardCharsets.UTF_8),
                StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING
        );

        log.info("对话文本已写入文件：{}", filePath.toAbsolutePath());
    }
}

