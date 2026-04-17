# bilibili-chatVideo-generate

本地部署的 B站 MC 跑酷 + 角色问答 视频生成网站（Spring + JSP）----详细案例参考B站上的熊大熊二对话答辩视频。

## 技术栈

- Spring Boot 2.7、JSP + JSTL
- Lombok、Slf4j、Validation、DevTools

## 项目结构

- `controller`：控制器
- `service` / `service.impl`：业务接口与实现
- `pojo`：Result、ApiError 等（Lombok）
- `exception`：全局异常处理、BusinessException

## 配置信息

- 在application.yml文件中配置自己的信息
```yml
# 千问 / DashScope 配置
dashscope:
  api-key: {YOURKEY}
  # 兼容模式 Responses API
  base-url: https://dashscope.aliyuncs.com/api/v2/apps/protocols/compatible-mode/v1
  responses-url: ${dashscope.base-url}/responses
  model: qwen-turbo
  # TTS 声音复刻与合成（北京地域）
  api-v1: https://dashscope.aliyuncs.com/api/v1
  tts-customization-url: ${dashscope.api-v1}/services/audio/tts/customization
  tts-model: qwen3-tts-vc-2026-01-22
  # 多模态生成 / TTS 生成（DashScope 官方路径为 multimodal-generation）
  tts-generation-url: ${dashscope.api-v1}/services/aigc/multimodal-generation/generation
```
## 运行

```bash
cd bilibili-chatVideo-generate
mvn spring-boot:run
```

默认端口 **8081**（若 8081 被占用可在 `application.properties` 中修改）。

- 首页：http://localhost:8081/
- 接口测试：http://localhost:8081/api/hello

## 功能实现

- 1.用户上传模版跑酷视频。
- 2.用户设置视频是单人模式还是双人模式。
- 3.用户上传角色的音频文件
- 4.用户设置角色的人设，并分配提问者和解答者。
- 5.点击右侧的加载总览来查看知乎中的热门问题和最高赞回答(输入你知乎账号的cookie则会自动爬取当前知乎热门话题top10的问题和对应的最高赞回答，并留档在QA.TXT文件中)。
- 6.点击生成文本之后可以尝试自己编辑。
- 7.设置好视频格式，角色图片的位置，字幕的样式后即可导出视频。(可以为一个角色同时上传多个文件，这样就角色就可以在多个图片中轮询展示，让画面更有趣)
- 8.最终的视频会导出在Result目录中

## 效率

- 1.实测2分钟即可完成一个8分钟的视频。

## 开销

- 1.语音生成qwen3-tts-vc-2026-01-22 快照版 0.8元/万字符
- 2.文本生成qwen-turbo 0.3元/百万token

## 爬取知乎数据

- 1."https://www.zhihu.com/api/v4/questions/" + trimmedId + "/answers"
- 2."https://api.zhihu.com/topstory/hot-list?limit=" + limit + "&reverse_order=0";
----------------------------------------------------
