<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            min-height: 100vh;
            color: #e6edf3;
            background:
                    linear-gradient(135deg, rgba(5,10,25,0.9), rgba(10,20,50,0.9)),
                    url('${pageContext.request.contextPath}/static/bg-placeholder.jpg') center/cover no-repeat fixed;
        }
        .app-layout {
            display: flex;
            min-height: 100vh;
            backdrop-filter: blur(6px);
        }
        .sidebar {
            width: 230px;
            padding: 1.5rem 1.25rem;
            background: linear-gradient(190deg,
                    rgba(15,23,42,0.78),
                    rgba(15,23,42,0.55));
            border-right: 1px solid rgba(148,163,184,0.35);
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            backdrop-filter: blur(14px);
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
            color: #ffffff;
        }
        .nav-section-title {
            font-size: 0.75rem;
            color: #e5e7eb;
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
            border-radius: 999px;
            color: #ffffff;
            font-weight: 600;
            text-decoration: none;
            font-size: 0.88rem;
            transition: all 0.2s;
        }
        .nav-link span {
            flex: 1;
        }
        .nav-link:hover {
            background: linear-gradient(90deg, rgba(56,189,248,0.12), rgba(129,140,248,0.12));
            transform: translateX(2px);
        }
        .nav-link-active {
            background: linear-gradient(90deg, rgba(56,189,248,0.25), rgba(129,140,248,0.25));
            color: #f9fafb;
        }
        .nav-footer {
            margin-top: auto;
            font-size: 0.75rem;
            color: #64748b;
        }
        .main {
            flex: 1;
            padding: 1.75rem 2rem;
            display: flex;
            flex-direction: column;
        }
        .main-header {
            margin-bottom: 1.25rem;
        }
        .main-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: #ffffff;
        }
        .main-subtitle {
            margin-top: 0.35rem;
            font-size: 0.9rem;
            color: #9ca3af;
        }
        .main-content {
            flex: 1;
            max-width: 1040px;
        }
        .wrap {
            max-width: 100%;
            margin: 0;
        }
        h1 {
            font-size: 1.5rem;
            margin-bottom: 0.8rem;
            background: linear-gradient(90deg, #38bdf8, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .sub { color:#9ca3af;font-size:0.9rem;margin-bottom:1.3rem; }
        .card {
            background: rgba(15,23,42,0.82);
            border-radius: 16px;
            padding: 1.5rem 1.6rem;
            margin-bottom: 1.5rem;
            border: 1px solid rgba(148,163,184,0.35);
            box-shadow: 0 24px 80px rgba(15,23,42,0.9);
        }
        .card h2 { font-size: 1.02rem; color: #ffffff; font-weight: 600; margin-bottom: 0.75rem; }
        label { display:block;margin-bottom:0.35rem;color:#9ca3af;font-size:0.9rem; }
        input[type="text"], textarea, select {
            width: 100%;
            padding: 0.5rem 0.75rem;
            margin-bottom: 0.9rem;
            border-radius: 8px;
            border: 1px solid rgba(148,163,184,0.55);
            background: rgba(15,23,42,0.92);
            color: #e5e7eb;
            font-size: 0.95rem;
        }
        textarea { min-height: 80px; resize: vertical; }
        input[type="file"] {
            width: 100%;
            margin-bottom: 0.9rem;
            color:#e5e7eb;
        }
        .row { display:flex;flex-wrap:wrap;gap:1rem; }
        .col { flex:1 1 260px; }
        .btn {
            display:inline-block;
            padding:0.55rem 1.15rem;
            background:#ffffff;
            color:#111827;
            font-weight:600;
            border:1px solid rgba(209,213,219,0.9);
            border-radius:999px;
            cursor:pointer;
            font-size:0.88rem;
            box-shadow: 0 0 0 rgba(15,23,42,0);
            transition: transform 0.18s ease-out, box-shadow 0.18s ease-out, background-color 0.18s ease-out, color 0.18s ease-out;
        }
        .btn:hover {
            transform: scale(1.04);
            box-shadow: 0 14px 38px rgba(15,23,42,0.55);
            background:#f9fafb;
        }
        .btn:disabled { opacity:0.6;cursor:not-allowed;box-shadow:none; }
        .msg { margin-top:0.5rem;font-size:0.85rem;display:none; }
        .msg.err { color:#fca5a5; }
        .msg.ok { color:#4ade80; }
        #templateBox { width:100%;min-height:160px;resize:vertical; }
        .video-preview { margin-top:0.75rem; }
        #resultVideo { width:100%;max-height:360px;background:#000;display:none; }
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
                border-radius: 999px;
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
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link nav-link-active">
                    <span>跑酷生成仪表盘</span>
                </a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link">
                    <span>接口与合成测试</span>
                </a>
            </div>
        </div>
        <div class="nav-footer">
            <div>步骤指引：填写表单 → 生成模板 → 审核 → 合成视频</div>
        </div>
    </aside>
    <main class="main">
        <div class="main-header">
            <div class="main-title">知乎问答跑酷视频生成仪表盘</div>
            <div class="main-subtitle">从知乎标题与高赞回答出发，自动生成角色对话脚本与配音，并融合到跑酷视频中。</div>
        </div>
        <div class="main-content">
<div class="wrap">
    <div class="card">
        <h2>步骤一：填写四个自定义可选框</h2>
        <form id="pipelineForm" enctype="multipart/form-data">
            <div class="row">
                <div class="col">
                    <label>1. 跑酷视频（MP4，自定义上传）</label>
                    <input type="file" name="video" id="videoFile" accept="video/mp4,video/*" />
                </div>
                <div class="col">
                    <label>2. 音频训练素材（点击展开选择模式）</label>
                    <select name="mode" id="modeSelect">
                        <option value="single">单人视频模式（只上传一份音频）</option>
                        <option value="double">双人视频模式（上传两份音频）</option>
                    </select>
                    <div id="audioSingleBox">
                        <label>单人 / 角色A 训练音频（必填）</label>
                        <input type="file" name="audioRoleA" id="audioRoleA" accept="audio/*" />
                    </div>
                    <div id="audioDoubleBox" style="display:none;">
                        <label>角色B 训练音频（双人模式必填）</label>
                        <input type="file" name="audioRoleB" id="audioRoleB" accept="audio/*" />
                    </div>
                </div>
            </div>

            <div style="margin-top:0.75rem;">
                <label>指令控制（可选，自然语言描述整体语速、情感、音色等，将作为 instructions 传给 TTS 模型）</label>
                <input type="text" name="instruction" id="instructionInput"
                       placeholder="例如：语速较快，语气活泼，适合短视频解说" />
                <button type="button" class="btn" id="previewBtn" style="margin-top:0.5rem;">测试语音预览（基于角色A训练音频）</button>
                <div id="previewMsg" class="msg"></div>
                <audio id="previewAudio" controls style="display:none;width:100%;margin-top:0.5rem;"></audio>
            </div>

            <div style="margin-top:0.75rem;">
                <label>3. 知乎标题</label>
                <input type="text" name="title" id="titleInput" placeholder="请输入摘抄自知乎的问题标题，例如：有没有人科普一下..." />
            </div>
            <div>
                <label>4. 知乎高赞文本回答</label>
                <textarea name="content" id="contentInput" placeholder="请输入对应的高赞回答全文"></textarea>
            </div>

            <button type="button" class="btn" id="generateTemplateBtn">步骤一：生成角色对话模板</button>
            <div id="generateMsg" class="msg"></div>

            <hr style="margin:1.5rem 0;border-color:rgba(255,255,255,0.08);">

            <h2>步骤二：审阅 / 修改模板并确认生成视频</h2>
            <label>对话模板（支持手动修改，格式为「角色A：台词。」/「角色B：台词。」一行一句）</label>
            <textarea id="templateBox" name="templateText" placeholder="点击上方按钮后，这里会自动填充千问生成的模板文本"></textarea>
            <button type="button" class="btn" id="confirmGenerateBtn" style="margin-top:0.75rem;">步骤三-五：确认模板并生成视频</button>
            <div id="confirmMsg" class="msg"></div>
        </form>
    </div>

    <div class="card">
        <h2>结果预览</h2>
        <p class="sub">生成成功后，会在下方展示合成后的视频（服务器返回的是本地文件路径，通过单独接口进行读取 / 下载）。</p>
        <div class="video-preview">
            <video id="resultVideo" controls></video>
        </div>
    </div>
</div>
        </div>
    </main>
</div>

<script>
    (function () {
        var modeSelect = document.getElementById('modeSelect');
        var audioSingleBox = document.getElementById('audioSingleBox');
        var audioDoubleBox = document.getElementById('audioDoubleBox');

        modeSelect.addEventListener('change', function () {
            var v = modeSelect.value;
            if (v === 'double') {
                audioDoubleBox.style.display = 'block';
            } else {
                audioDoubleBox.style.display = 'none';
            }
        });
    })();

    (function () {
        var generateBtn = document.getElementById('generateTemplateBtn');
        var generateMsg = document.getElementById('generateMsg');
        var titleInput = document.getElementById('titleInput');
        var contentInput = document.getElementById('contentInput');
        var templateBox = document.getElementById('templateBox');

        function showMsg(el, text, isErr) {
            el.textContent = text;
            el.className = 'msg ' + (isErr ? 'err' : 'ok');
            el.style.display = 'block';
        }
        function hideMsg(el) {
            el.style.display = 'none';
        }

        generateBtn.addEventListener('click', function () {
            hideMsg(generateMsg);
            var title = (titleInput.value || '').trim();
            var content = (contentInput.value || '').trim();
            if (!title) {
                showMsg(generateMsg, '请先填写知乎标题。', true);
                return;
            }
            if (!content) {
                showMsg(generateMsg, '请先填写知乎高赞回答文本。', true);
                return;
            }
            generateBtn.disabled = true;
            showMsg(generateMsg, '正在调用千问生成模板，请稍候……', false);

            fetch('${pageContext.request.contextPath}/api/bashboard/generate-template', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: 'title=' + encodeURIComponent(title) + '&content=' + encodeURIComponent(content)
            })
                .then(function (r) { return r.json(); })
                .then(function (res) {
                    if (res.code === 200 && res.data) {
                        templateBox.value = res.data;
                        showMsg(generateMsg, '模板生成成功，可在下方编辑。', false);
                    } else {
                        showMsg(generateMsg, res.message || '模板生成失败。', true);
                    }
                })
                .catch(function (err) {
                    showMsg(generateMsg, '请求失败：' + (err.message || err), true);
                })
                .finally(function () {
                    generateBtn.disabled = false;
                });
        });
    })();

    (function () {
        var confirmBtn = document.getElementById('confirmGenerateBtn');
        var confirmMsg = document.getElementById('confirmMsg');
        var form = document.getElementById('pipelineForm');
        var modeSelect = document.getElementById('modeSelect');
        var videoFile = document.getElementById('videoFile');
        var audioRoleA = document.getElementById('audioRoleA');
        var audioRoleB = document.getElementById('audioRoleB');
        var titleInput = document.getElementById('titleInput');
        var templateBox = document.getElementById('templateBox');
        var resultVideo = document.getElementById('resultVideo');
        var instructionInput = document.getElementById('instructionInput');

        function showMsg(el, text, isErr) {
            el.textContent = text;
            el.className = 'msg ' + (isErr ? 'err' : 'ok');
            el.style.display = 'block';
        }
        function hideMsg(el) {
            el.style.display = 'none';
        }

        confirmBtn.addEventListener('click', function () {
            hideMsg(confirmMsg);
            resultVideo.style.display = 'none';
            resultVideo.removeAttribute('src');

            var title = (titleInput.value || '').trim();
            var templateText = (templateBox.value || '').trim();
            var mode = modeSelect.value;
            var instruction = instructionInput ? (instructionInput.value || '').trim() : '';
            if (!videoFile.files || videoFile.files.length === 0) {
                showMsg(confirmMsg, '请先上传一段跑酷视频（MP4）。', true);
                return;
            }
            if (!title) {
                showMsg(confirmMsg, '请先填写知乎标题。', true);
                return;
            }
            if (!templateText) {
                showMsg(confirmMsg, '模板内容为空，请先生成或填写模板。', true);
                return;
            }
            if (!audioRoleA.files || audioRoleA.files.length === 0) {
                showMsg(confirmMsg, '请上传角色A / 单人模式的训练音频。', true);
                return;
            }
            if (mode === 'double' && (!audioRoleB.files || audioRoleB.files.length === 0)) {
                showMsg(confirmMsg, '双人模式下必须上传角色B的训练音频。', true);
                return;
            }

            var fd = new FormData();
            fd.append('mode', mode);
            fd.append('title', title);
            fd.append('templateText', templateText);
            fd.append('video', videoFile.files[0]);
            fd.append('audioRoleA', audioRoleA.files[0]);
            if (mode === 'double' && audioRoleB.files && audioRoleB.files[0]) {
                fd.append('audioRoleB', audioRoleB.files[0]);
            }
            if (instruction) {
                fd.append('instruction', instruction);
            }

            confirmBtn.disabled = true;
            showMsg(confirmMsg, '正在生成 TTS 音频并进行视频合成，这可能需要较长时间，请耐心等待……', false);

            fetch('${pageContext.request.contextPath}/api/bashboard/confirm-and-generate', {
                method: 'POST',
                body: fd
            })
                .then(function (r) { return r.json(); })
                .then(function (res) {
                    if (res.code === 200 && res.data) {
                        showMsg(confirmMsg, '视频合成完成，后端返回的最终视频路径为：' + res.data + '（可在服务器上查看或扩展为下载接口）。', false);
                    } else {
                        showMsg(confirmMsg, res.message || '视频生成失败。', true);
                    }
                })
                .catch(function (err) {
                    showMsg(confirmMsg, '请求失败：' + (err.message || err), true);
                })
                .finally(function () {
                    confirmBtn.disabled = false;
                });
        });
    })();

    // 测试语音预览：基于当前角色A训练音频和指令，调用通用 /api/tts/generate 生成一条测试语音
    (function () {
        var previewBtn = document.getElementById('previewBtn');
        var previewMsg = document.getElementById('previewMsg');
        var previewAudio = document.getElementById('previewAudio');
        var audioRoleA = document.getElementById('audioRoleA');
        var instructionInput = document.getElementById('instructionInput');

        function showPreviewMsg(text, isErr) {
            previewMsg.textContent = text;
            previewMsg.className = 'msg ' + (isErr ? 'err' : 'ok');
            previewMsg.style.display = 'block';
        }
        function hidePreviewMsg() {
            previewMsg.style.display = 'none';
        }

        if (previewBtn) {
            previewBtn.addEventListener('click', function () {
                hidePreviewMsg();
                previewAudio.style.display = 'none';
                previewAudio.removeAttribute('src');

                if (!audioRoleA.files || audioRoleA.files.length === 0) {
                    showPreviewMsg('请先上传角色A / 单人模式的训练音频。', true);
                    return;
                }

                var fd = new FormData();
                fd.append('audio', audioRoleA.files[0]);
                fd.append('text', '这是一个测试语音预览，用于检查当前指令控制和角色A训练音频的效果。');
                if (instructionInput && instructionInput.value && instructionInput.value.trim().length > 0) {
                    fd.append('instruction', instructionInput.value.trim());
                }

                previewBtn.disabled = true;
                showPreviewMsg('正在生成测试语音预览，请稍候……', false);

                fetch('${pageContext.request.contextPath}/api/tts/generate', {
                    method: 'POST',
                    body: fd
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (res.code === 200 && res.data) {
                            previewAudio.src = res.data;
                            previewAudio.style.display = 'block';
                            showPreviewMsg('测试语音生成成功，可点击下方播放器试听。', false);
                        } else {
                            showPreviewMsg(res.message || '测试语音生成失败。', true);
                        }
                    })
                    .catch(function (err) {
                        showPreviewMsg('请求失败：' + (err.message || err), true);
                    })
                    .finally(function () {
                        previewBtn.disabled = false;
                    });
            });
        }
    })();
</script>
</body>
</html>

