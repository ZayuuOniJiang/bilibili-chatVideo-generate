# bilibili-chatVideo-generate

本地部署的 B站 MC 跑酷 + 角色问答 视频生成网站（Spring + JSP）。

## 技术栈

- Spring Boot 2.7、JSP + JSTL
- Lombok、Slf4j、Validation、DevTools

## 项目结构

- `controller`：控制器
- `service` / `service.impl`：业务接口与实现
- `pojo`：Result、ApiError 等（Lombok）
- `exception`：全局异常处理、BusinessException

## 运行

```bash
cd bilibili-chatVideo-generate
mvn spring-boot:run
```

默认端口 **8081**（若 8080 被占用可在 `application.properties` 中修改）。

- 首页：http://localhost:8081/
- 接口测试：http://localhost:8081/api/hello
- 异常测试：http://localhost:8081/api/error-test
R
## 功能实现

- 在首页有四个自定义可选框
- 第一个选中resources目录中的已存在的跑酷视频.mp4
- 第二个选项框用来输入音频训练素材。可以通过点击展开来选择单人视频模式和双人视频模式，单人视频模式必须上传一份音频素材，双人视频模式则必须输入两份音频素材
- 第三个选项框负责输入摘抄自知乎的标题
- 第四个选项用来输入摘抄自知乎的高赞文本回答
----------------------------------------------------
## 操作流程

- 操作一：首先将文本和标题交给输入好prompt提示词的千问模型中，输出的模板是{角色A：台词。/换行 角色B台词。/换行}
- 操作二：将输出的模板在前端页面中进行展示，同时用户在查看模板的过程中可以进行文本的修改，审查完毕后点击"确认"按钮后即可将模板文本存储为"知乎问题".txt并存储到resources目录中的contents文件夹中
- 操作三：读取contents目录中的"知乎问题".txt文件，将对应角色的第n句话进行提取，然后将台词和对应的角色训练素材打包传输给千问TTS的模型API中，生成的音频文件为阿里的oss地址，你可以通过okhttp3来下载这个音频文件存储到sounds文件夹并命名为"角色A/B"+"知乎问题"+"num(指角色的第几句话)"通过插件来查看这个音频文件的时长,然后将合成的音频文件插入提前准备好的resources目录中的视频中，要求角色间对话间隔1.5s
- 操作四：不断轮询操作三，类似于角色A第一句话的音频时长为5s，那么通过ffmpeg将音频插入视频的0-5s中。接下来角色B的第一句话时长为3s，那么在视频的6.5s-9.5s中插入音频。以此不断循环直到文本全部读完。
- 操作五：记录文本读完的最终时间，最后通过ffmpeg剪辑视频将视频在文本读完后进行结束
