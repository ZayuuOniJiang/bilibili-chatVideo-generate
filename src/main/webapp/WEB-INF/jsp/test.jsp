<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>接口功能测试 - /test</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --panel-bg: rgba(255, 255, 255, 0.68);
            --panel-border: rgba(255, 255, 255, 0.5);
            --text-main: #0f172a;
            --text-sub: #475569;
            --shadow-soft: 0 18px 45px rgba(15, 23, 42, 0.15);
        }
        body {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            min-height: 100vh;
            color: var(--text-main);
            background: url('${pageContext.request.contextPath}/api/background/current') center center / cover no-repeat fixed;
        }
        .app-layout {
            display: flex;
            min-height: 100vh;
            background: transparent;
        }
        .sidebar {
            width: 240px;
            padding: 1.5rem 1.1rem;
            background: rgba(236, 244, 255, 0.72);
            border-right: 1px solid rgba(255,255,255,0.55);
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            backdrop-filter: blur(12px);
            box-shadow: 8px 0 30px rgba(15, 23, 42, 0.08);
        }
        .sidebar-header {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .sidebar-logo {
            width: 32px;
            height: 32px;
            border-radius: 999px;
            background: radial-gradient(circle at 30% 30%, #38bdf8, #6366f1);
        }
        .sidebar-title {
            font-size: 1rem;
            font-weight: 700;
            letter-spacing: 0.03em;
            color: #0f172a;
        }
        .nav-section-title {
            font-size: 0.75rem;
            color: #475569;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 0.25rem;
        }
        .nav-group {
            display: flex;
            flex-direction: column;
            gap: 0.3rem;
        }
        .nav-link {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.75rem;
            border-radius: 10px;
            color: #1e293b;
            font-weight: 600;
            text-decoration: none;
            font-size: 0.88rem;
            transition: all 0.2s;
        }
        .nav-link span {
            flex: 1;
        }
        .nav-link:hover {
            background: rgba(255,255,255,0.65);
            transform: translateX(2px);
        }
        .nav-link-active {
            background: rgba(255,255,255,0.9);
            color: #111827;
            box-shadow: 0 6px 18px rgba(15, 23, 42, 0.12);
        }
        .nav-footer {
            margin-top: auto;
            font-size: 0.75rem;
            color: #334155;
        }
        .main {
            flex: 1;
            padding: 1.6rem 1.8rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        .main-header {
            margin-bottom: 0;
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            border-radius: 14px;
            padding: 1rem 1.25rem;
            backdrop-filter: blur(10px);
            box-shadow: var(--shadow-soft);
        }
        .main-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-main);
        }
        .main-subtitle {
            margin-top: 0.35rem;
            font-size: 0.9rem;
            color: var(--text-sub);
        }
        .main-content {
            flex: 1;
            max-width: 800px;
        }
        .wrap { max-width: 100%; margin: 0; }
        h1 {
            font-size: 1.5rem;
            margin-bottom: 1.2rem;
            color: var(--text-main);
            font-weight: 700;
        }
        .card {
            background: var(--panel-bg);
            border-radius: 16px;
            padding: 1.5rem 1.6rem;
            margin-bottom: 1.5rem;
            border: 1px solid var(--panel-border);
            box-shadow: var(--shadow-soft);
            backdrop-filter: blur(12px);
        }
        .card h2 { font-size: 1rem; color: var(--text-main); font-weight: 600; margin-bottom: 1rem; }
        label { display: block; margin-bottom: 0.35rem; color: var(--text-sub); font-size: 0.9rem; }
        input[type="file"], textarea, select {
            width: 100%;
            padding: 0.5rem 0.75rem;
            margin-bottom: 1rem;
            border-radius: 8px;
            border: 1px solid rgba(203,213,225,0.95);
            background: rgba(255,255,255,0.9);
            color: #0f172a;
            font-size: 0.95rem;
        }
        textarea { min-height: 80px; resize: vertical; }
        select { cursor: pointer; }
        .btn {
            display: inline-block;
            padding: 0.6rem 1.2rem;
            background: rgba(255,255,255,0.95);
            color: #111827;
            font-weight: 600;
            border: 1px solid rgba(203,213,225,0.95);
            border-radius: 10px;
            cursor: pointer;
            font-size: 0.9rem;
            box-shadow: 0 0 0 rgba(15,23,42,0);
            transition: transform 0.18s ease-out, box-shadow 0.18s ease-out, background-color 0.18s ease-out, color 0.18s ease-out;
        }
        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(15,23,42,0.12);
            background: #f9fafb;
        }
        .btn:disabled { opacity: 0.6; cursor: not-allowed; box-shadow:none; }
        .msg { margin-top: 1rem; font-size: 0.9rem; }
        .msg.err { color: #b91c1c; }
        .msg.ok { color: #166534; }
        #resultAudio { margin-top: 1rem; width: 100%; }
        @media (max-width: 900px) {
            .app-layout {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                flex-direction: row;
                align-items: center;
                justify-content: space-between;
                padding: 0.75rem 1rem;
            }
            .nav-group {
                flex-direction: row;
                flex-wrap: wrap;
            }
            .nav-link {
                border-radius: 8px;
                padding: 0.35rem 0.7rem;
                font-size: 0.8rem;
            }
            .main {
                padding: 1.25rem 1.25rem 1.75rem;
            }
        }
    </style>
</head>
<body>
<div class="app-layout">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-logo"></div>
            <div class="sidebar-title">B 站 · 跑酷对话视频</div>
        </div>
        <div>
            <div class="nav-section-title">导航</div>
            <div class="nav-group">
                <a href="${pageContext.request.contextPath}/" class="nav-link">
                    <span>首页</span>
                </a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link">
                    <span>跑酷生成仪表盘</span>
                </a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link">
                    <span>管理模板</span>
                </a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link">
                    <span>批量创建视频</span>
                </a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link nav-link-active">
                    <span>接口与合成测试</span>
                </a>
            </div>
        </div>
        <div class="nav-footer">
            <div>TTS / FFmpeg 功能联调与验证页面</div>
        </div>
    </aside>
    <main class="main">
        <div class="main-header">
            <div class="main-title">接口功能测试</div>
            <div class="main-subtitle">在将流程接入仪表盘前，用这里测试 TTS 指令控制和音视频合成功能。</div>
        </div>
        <div class="main-content">
            <div class="wrap">
                <h1>接口功能测试</h1>

                <div class="card">
                    <h2>Qwen3-TTS：自定义音频 + 文本 → 合成语音</h2>
                    <p style="color:#8b949e;font-size:0.85rem;margin-bottom:1rem;">上传一段音频用于复刻音色，输入要合成的文本，选择风格（会作为 instructions 写入请求体），点击生成后播放返回的音频。</p>
                    <form id="ttsForm">
                        <label>复刻用音频（必填）</label>
                        <input type="file" name="audio" accept="audio/*" required />
                        <label>要合成的文本（必填）</label>
                        <textarea name="text" placeholder="例如：今天天气怎么样？" required></textarea>
                        <label>指令控制（可选，自然语言描述语速、情感、音色等，将作为 instructions 传给 TTS 模型）</label>
                        <input type="text" name="instruction" placeholder="例如：语速较快，带有明显的上扬语调，适合介绍时尚产品" />
                        <button type="submit" class="btn" id="submitBtn">生成语音</button>
                        <button type="button" class="btn" id="previewBtn" style="margin-left:0.75rem;">测试语音预览</button>
                    </form>
                    <div id="ttsMsg" class="msg" style="display:none;"></div>
                    <audio id="resultAudio" controls style="display:none;"></audio>
                </div>

                <div class="card">
                    <h2>FFmpeg：将音频插入到视频指定时间</h2>
                    <p style="color:#8b949e;font-size:0.85rem;margin-bottom:1rem;">
                        上传一个 MP4 视频和一段音频，在网页中预览视频，选择插入开始时间，将音频叠加到视频原有音轨上（不会删除原音频）。
                    </p>
                    <form id="mergeForm">
                        <label>视频文件（MP4，必选）</label>
                        <input type="file" name="video" id="videoFile" accept="video/mp4,video/*" required />

                        <label>要插入的音频文件（MP3 / 音频，必选）</label>
                        <input type="file" name="audio" id="audioFile" accept="audio/mpeg,audio/*" required />

                        <label>插入开始时间（秒，可用下方按钮从当前播放时间填入）</label>
                        <input type="number" step="0.1" min="0" name="startTime" id="startTimeInput"
                               placeholder="例如：10 或 12.5" required />

                        <button type="button" class="btn" id="useCurrentTimeBtn" style="margin-bottom:0.75rem;">
                            使用当前视频播放时间
                        </button>

                        <div style="margin-bottom:0.75rem;">
                            <label style="margin-bottom:0.35rem;">视频预览</label>
                            <video id="videoPreview" controls style="width:100%;max-height:320px;background:#000;"></video>
                        </div>

                        <button type="submit" class="btn" id="mergeSubmitBtn">开始合成视频</button>
                    </form>
                    <div id="mergeMsg" class="msg" style="display:none;"></div>
                    <div style="margin-top:0.75rem;">
                        <label style="margin-bottom:0.35rem;">合成后视频预览</label>
                        <video id="resultVideo" controls style="width:100%;max-height:320px;background:#000;display:none;"></video>
                    </div>
                </div>

                <div class="card">
                    <h2>FFmpeg：循环/截断音频以匹配视频时长</h2>
                    <p style="color:#8b949e;font-size:0.85rem;margin-bottom:1rem;">
                        上传一个 MP4 视频和一段音频，后台会自动重复播放或在末尾截断音频，使音频总时长与视频时长一致，
                        然后将该音频作为唯一音轨插入视频（不会对音频进行变速处理）。
                    </p>
                    <form id="loopForm">
                        <label>视频文件（MP4，必选）</label>
                        <input type="file" name="video" id="loopVideoFile" accept="video/mp4,video/*" required />

                        <label>背景音频文件（MP3 / 音频，必选）</label>
                        <input type="file" name="audio" id="loopAudioFile" accept="audio/mpeg,audio/*" required />

                        <button type="submit" class="btn" id="loopSubmitBtn">开始生成匹配时长的视频</button>
                    </form>
                    <div id="loopMsg" class="msg" style="display:none;"></div>
                    <div style="margin-top:0.75rem;">
                        <label style="margin-bottom:0.35rem;">合成后视频预览</label>
                        <video id="loopResultVideo" controls style="width:100%;max-height:320px;background:#000;display:none;"></video>
                    </div>
                </div>

                <div class="card">
                    <h2>知乎：按问题 ID 拉取最高赞回答</h2>
                    <p style="color:#8b949e;font-size:0.85rem;margin-bottom:1rem;">
                        在浏览器中打开知乎问题页面，复制地址栏中的问题数字 ID 和当前页面的 Cookie，这里将通过后端 RestTemplate
                        调用 <code>https://www.zhihu.com/api/v4/questions/&lt;questionId&gt;/answers?include=content</code> 接口，
                        返回该问题标题和当前最高赞的回答文本。
                    </p>
                    <form id="zhihuForm">
                        <label>知乎问题 ID（数字，可修改切换不同问题）</label>
                        <input type="number" id="zhihuQuestionId" name="questionId"
                               value="2011946515493512924"
                               placeholder="例如：2011946515493512924" required />

                        <label>知乎 Cookie（请从浏览器开发者工具中复制完整 Cookie）</label>
                        <textarea id="zhihuCookie" name="cookie"
                                  placeholder="在已登录知乎的页面中复制当前请求使用的 Cookie 粘贴到这里"
                                  required></textarea>

                        <button type="submit" class="btn" id="zhihuSubmitBtn">获取问题标题和最高赞回答</button>
                    </form>
                    <div id="zhihuMsg" class="msg" style="display:none;"></div>
                    <div id="zhihuResult" style="margin-top:1rem;display:none;">
                        <div style="margin-bottom:0.5rem;font-size:0.95rem;color:#9ca3af;">知乎问题标题：</div>
                        <div id="zhihuTitle"
                             style="margin-bottom:0.9rem;font-size:1rem;font-weight:600;color:#e5e7eb;word-break:break-all;"></div>
                        <div style="margin-bottom:0.5rem;font-size:0.95rem;color:#9ca3af;">最高赞回答文本：</div>
                        <div id="zhihuAnswer"
                             style="white-space:pre-wrap;font-size:0.95rem;color:#e5e7eb;line-height:1.6;"></div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
    <script>
        (function() {
            var form = document.getElementById('ttsForm');
            var submitBtn = document.getElementById('submitBtn');
            var msgEl = document.getElementById('ttsMsg');
            var audioEl = document.getElementById('resultAudio');
            var previewBtn = document.getElementById('previewBtn');

            function showMsg(text, isErr) {
                msgEl.textContent = text;
                msgEl.className = 'msg ' + (isErr ? 'err' : 'ok');
                msgEl.style.display = 'block';
            }
            function hideMsg() {
                msgEl.style.display = 'none';
            }

            form.addEventListener('submit', function(e) {
                e.preventDefault();
                var fd = new FormData(form);
                submitBtn.disabled = true;
                hideMsg();
                audioEl.style.display = 'none';
                audioEl.removeAttribute('src');

                fetch('${pageContext.request.contextPath}/api/tts/generate', {
                    method: 'POST',
                    body: fd
                })
                .then(function(r) { return r.json(); })
                .then(function(res) {
                    if (res.code === 200 && res.data) {
                        audioEl.src = res.data;
                        audioEl.style.display = 'block';
                        showMsg('生成成功，可点击播放。');
                    } else {
                        showMsg(res.message || '生成失败', true);
                    }
                })
                .catch(function(err) {
                    showMsg('请求失败: ' + (err.message || err), true);
                })
                .finally(function() {
                    submitBtn.disabled = false;
                });
            });

            // 测试语音预览：使用当前训练音频和指令，固定一段测试文本进行快速试听
            previewBtn.addEventListener('click', function () {
                hideMsg();
                audioEl.style.display = 'none';
                audioEl.removeAttribute('src');

                var audioInput = form.querySelector('input[name="audio"]');
                var instructionInput = form.querySelector('input[name="instruction"]');
                if (!audioInput.files || audioInput.files.length === 0) {
                    showMsg('请先上传用于复刻的音频文件。', true);
                    return;
                }

                var fd = new FormData();
                fd.append('audio', audioInput.files[0]);
                fd.append('text', '这是一个测试语音预览，用于检查当前的指令控制和训练音频效果。');
                if (instructionInput && instructionInput.value && instructionInput.value.trim().length > 0) {
                    fd.append('instruction', instructionInput.value.trim());
                }

                previewBtn.disabled = true;
                showMsg('正在生成测试语音预览，请稍候……', false);

                fetch('${pageContext.request.contextPath}/api/tts/generate', {
                    method: 'POST',
                    body: fd
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (res.code === 200 && res.data) {
                            audioEl.src = res.data;
                            audioEl.style.display = 'block';
                            showMsg('测试语音生成成功，可点击播放试听。', false);
                        } else {
                            showMsg(res.message || '测试语音生成失败', true);
                        }
                    })
                    .catch(function (err) {
                        showMsg('请求失败: ' + (err.message || err), true);
                    })
                    .finally(function () {
                        previewBtn.disabled = false;
                    });
            });
        })();

        (function() {
            var mergeForm = document.getElementById('mergeForm');
            var mergeSubmitBtn = document.getElementById('mergeSubmitBtn');
            var mergeMsgEl = document.getElementById('mergeMsg');
            var videoInput = document.getElementById('videoFile');
            var startTimeInput = document.getElementById('startTimeInput');
            var useCurrentTimeBtn = document.getElementById('useCurrentTimeBtn');
            var videoPreview = document.getElementById('videoPreview');
            var resultVideo = document.getElementById('resultVideo');

            function showMergeMsg(text, isErr) {
                mergeMsgEl.textContent = text;
                mergeMsgEl.className = 'msg ' + (isErr ? 'err' : 'ok');
                mergeMsgEl.style.display = 'block';
            }
            function hideMergeMsg() {
                mergeMsgEl.style.display = 'none';
            }

            // 选择视频时预览
            videoInput.addEventListener('change', function (e) {
                var file = e.target.files && e.target.files[0];
                if (!file) {
                    videoPreview.removeAttribute('src');
                    videoPreview.load();
                    return;
                }
                var url = URL.createObjectURL(file);
                videoPreview.src = url;
                videoPreview.load();
            });

            // 使用当前播放时间填入开始时间
            useCurrentTimeBtn.addEventListener('click', function () {
                if (!videoPreview || isNaN(videoPreview.currentTime)) {
                    showMergeMsg('请先选择并加载视频，确保可以播放。', true);
                    return;
                }
                var t = videoPreview.currentTime || 0;
                startTimeInput.value = t.toFixed(2);
                showMergeMsg('已使用当前播放时间 ' + t.toFixed(2) + ' 秒 作为插入开始时间。', false);
            });

            mergeForm.addEventListener('submit', function (e) {
                e.preventDefault();
                hideMergeMsg();
                resultVideo.style.display = 'none';
                resultVideo.removeAttribute('src');

                var fd = new FormData(mergeForm);
                mergeSubmitBtn.disabled = true;

                fetch('${pageContext.request.contextPath}/api/video/merge-audio', {
                    method: 'POST',
                    body: fd
                })
                    .then(function (r) {
                        if (!r.ok) {
                            return r.text().then(function (txt) {
                                throw new Error(txt || ('HTTP ' + r.status));
                            });
                        }
                        return r.blob();
                    })
                    .then(function (blob) {
                        var url = URL.createObjectURL(blob);
                        resultVideo.src = url;
                        resultVideo.style.display = 'block';
                        showMergeMsg('视频合成成功，可在下方预览或右键另存为。', false);
                    })
                    .catch(function (err) {
                        showMergeMsg('视频合成失败: ' + (err.message || err), true);
                    })
                    .finally(function () {
                        mergeSubmitBtn.disabled = false;
                    });
            });
        })();

        (function () {
            var form = document.getElementById('zhihuForm');
            if (!form) {
                return;
            }
            var submitBtn = document.getElementById('zhihuSubmitBtn');
            var msgEl = document.getElementById('zhihuMsg');
            var resultBox = document.getElementById('zhihuResult');
            var titleEl = document.getElementById('zhihuTitle');
            var answerEl = document.getElementById('zhihuAnswer');

            function showMsg(text, isErr) {
                msgEl.textContent = text;
                msgEl.className = 'msg ' + (isErr ? 'err' : 'ok');
                msgEl.style.display = 'block';
            }

            function hideMsg() {
                msgEl.style.display = 'none';
            }

            form.addEventListener('submit', function (e) {
                e.preventDefault();
                hideMsg();
                resultBox.style.display = 'none';
                titleEl.textContent = '';
                answerEl.textContent = '';

                var questionId = document.getElementById('zhihuQuestionId').value.trim();
                var cookie = document.getElementById('zhihuCookie').value.trim();
                if (!questionId) {
                    showMsg('请填写知乎问题 ID。', true);
                    return;
                }
                if (!cookie) {
                    showMsg('请粘贴知乎 Cookie。', true);
                    return;
                }

                var body = new URLSearchParams();
                body.append('questionId', questionId);
                body.append('cookie', cookie);

                submitBtn.disabled = true;
                showMsg('正在请求知乎接口，请稍候……', false);

                fetch('${pageContext.request.contextPath}/api/zhihu/answers', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: body.toString()
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (res.code === 200 && res.data) {
                            var title = res.data.title || '';
                            var html = res.data.answerContent || '';

                            var tmp = document.createElement('div');
                            tmp.innerHTML = html;
                            var text = tmp.innerText || tmp.textContent || '';

                            titleEl.textContent = title;
                            answerEl.textContent = text;
                            resultBox.style.display = 'block';
                            showMsg('获取成功。', false);
                        } else {
                            showMsg(res.message || '获取失败', true);
                        }
                    })
                    .catch(function (err) {
                        showMsg('请求失败: ' + (err.message || err), true);
                    })
                    .finally(function () {
                        submitBtn.disabled = false;
                    });
            });
        })();

        (function () {
            var loopForm = document.getElementById('loopForm');
            var loopSubmitBtn = document.getElementById('loopSubmitBtn');
            var loopMsgEl = document.getElementById('loopMsg');
            var loopResultVideo = document.getElementById('loopResultVideo');

            function showLoopMsg(text, isErr) {
                loopMsgEl.textContent = text;
                loopMsgEl.className = 'msg ' + (isErr ? 'err' : 'ok');
                loopMsgEl.style.display = 'block';
            }

            function hideLoopMsg() {
                loopMsgEl.style.display = 'none';
            }

            loopForm.addEventListener('submit', function (e) {
                e.preventDefault();
                hideLoopMsg();
                loopResultVideo.style.display = 'none';
                loopResultVideo.removeAttribute('src');

                var fd = new FormData(loopForm);
                loopSubmitBtn.disabled = true;
                showLoopMsg('正在生成匹配时长的视频，请稍候……', false);

                fetch('${pageContext.request.contextPath}/api/video/loop-audio', {
                    method: 'POST',
                    body: fd
                })
                    .then(function (r) {
                        if (!r.ok) {
                            return r.text().then(function (txt) {
                                throw new Error(txt || ('HTTP ' + r.status));
                            });
                        }
                        return r.blob();
                    })
                    .then(function (blob) {
                        var url = URL.createObjectURL(blob);
                        loopResultVideo.src = url;
                        loopResultVideo.style.display = 'block';
                        showLoopMsg('视频生成成功，可在下方预览或右键另存为。', false);
                    })
                    .catch(function (err) {
                        showLoopMsg('视频生成失败: ' + (err.message || err), true);
                    })
                    .finally(function () {
                        loopSubmitBtn.disabled = false;
                    });
            });
        })();
    </script>
</body>
</html>

