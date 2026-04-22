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
        .bg-upload-btn {
            margin-top: 0.55rem;
            width: 100%;
            border: 1px solid rgba(203,213,225,0.95);
            background: rgba(255,255,255,0.95);
            color: #0f172a;
            border-radius: 10px;
            font-size: 0.78rem;
            font-weight: 600;
            padding: 0.45rem 0.75rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        .bg-upload-btn:hover {
            background: #ffffff;
            border-color: rgba(148,163,184,0.9);
            transform: translateY(-1px);
        }
        .bg-upload-msg {
            margin-top: 0.45rem;
            line-height: 1.45;
            color: #334155;
            font-size: 0.72rem;
            min-height: 1rem;
            word-break: break-word;
        }
        .main {
            flex: 1;
            padding: 1.6rem 1.8rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        .main-header {
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
            display: flex;
            align-items: flex-start;
            justify-content: flex-start;
        }
        .card {
            background: var(--panel-bg);
            border-radius: 16px;
            padding: 1.5rem;
            max-width: 1100px;
            width: 100%;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--panel-border);
            backdrop-filter: blur(12px);
        }
        h1 {
            font-size: 1.28rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
        }
        .welcome {
            color: var(--text-sub);
            margin-bottom: 1.25rem;
            line-height: 1.6;
            font-size: 0.95rem;
        }
        .links {
            display: grid;
            grid-template-columns: repeat(2, minmax(220px, 1fr));
            gap: 0.75rem;
        }
        .links a {
            display: inline-block;
            padding: 0.8rem 0.95rem;
            background: rgba(255,255,255,0.92);
            color: #111827;
            font-weight: 600;
            text-decoration: none;
            border-radius: 10px;
            font-size: 0.88rem;
            border: 1px solid rgba(226,232,240,0.95);
            box-shadow: 0 0 0 rgba(15,23,42,0);
            transition: transform 0.18s ease-out, box-shadow 0.18s ease-out, background-color 0.18s ease-out, color 0.18s ease-out;
        }
        .links a:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(15,23,42,0.12);
            background: #f9fafb;
        }
        .status {
            margin-top: 1.3rem;
            padding: 0.75rem 0.9rem;
            background: rgba(255,255,255,0.78);
            border-radius: 12px;
            font-size: 0.84rem;
            color: #334155;
            border: 1px solid rgba(226,232,240,0.95);
        }
        .status span {
            opacity: 0.95;
        }
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
            .bg-upload-btn {
                width: auto;
                min-width: 140px;
            }
            .bg-upload-msg {
                display: none;
            }
            .main {
                padding: 1.25rem 1.25rem 1.75rem;
            }
            .links {
                grid-template-columns: 1fr;
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
                <a href="${pageContext.request.contextPath}/" class="nav-link nav-link-active">
                    <span>首页</span>
                </a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link">
                    <span>跑酷生成仪表盘</span>
                </a>
                <a href="${pageContext.request.contextPath}/zhihu" class="nav-link">
                    <span>QA 文本管理</span>
                </a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link">
                    <span>管理模板</span>
                </a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link">
                    <span>批量创建视频</span>
                </a>
                <a href="${pageContext.request.contextPath}/biliup-upload" class="nav-link">
                    <span>上传至B站视频</span>
                </a>
                <a href="${pageContext.request.contextPath}/video-manage" class="nav-link">
                    <span>视频管理</span>
                </a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link">
                    <span>接口与合成测试</span>
                </a>
            </div>
        </div>
        <div class="nav-footer">
            <div>当前环境：本地开发</div>
            <button type="button" id="bgUploadBtn" class="bg-upload-btn">上传替换背景图</button>
            <input type="file" id="bgFileInput" accept="image/*" style="display:none;" />
            <div id="bgUploadMsg" class="bg-upload-msg"></div>
        </div>
    </aside>
    <main class="main">
        <div class="main-header">
            <div class="main-title">欢迎使用 B 站 跑酷 + 角色问答 视频生成工具</div>
            <div class="main-subtitle">从知乎问题到成品对话跑酷视频，一站式生成与调试。</div>
        </div>
        <div class="main-content">
            <div class="card">
                <h1>${title}</h1>
                <p class="welcome"><c:out value="${welcome}"/></p>
                <div class="links">
                    <a href="${pageContext.request.contextPath}/bashboard">进入跑酷生成仪表盘</a>
                    <a href="${pageContext.request.contextPath}/zhihu">打开 QA 文本管理</a>
                    <a href="${pageContext.request.contextPath}/template-manage">打开模板管理</a>
                    <a href="${pageContext.request.contextPath}/batch-create">打开批量创建视频</a>
                    <a href="${pageContext.request.contextPath}/biliup-upload">打开上传至B站视频</a>
                    <a href="${pageContext.request.contextPath}/video-manage">打开视频管理</a>
                    <a href="${pageContext.request.contextPath}/test">查看 TTS / FFmpeg 测试页</a>
                    <a href="${pageContext.request.contextPath}/api/hello" target="_blank">接口测试 /api/hello</a>
                    <a href="${pageContext.request.contextPath}/api/error-test" target="_blank">异常测试 /api/error-test</a>
                </div>
                <div class="status">
                    <span>服务运行正常 · 你可以先在「接口测试」页面调好音色和指令，再在「跑酷生成仪表盘」完成整套视频生成。</span>
                </div>
            </div>
        </div>
    </main>
</div>
<script>
    (function () {
        var uploadBtn = document.getElementById('bgUploadBtn');
        var fileInput = document.getElementById('bgFileInput');
        var uploadMsg = document.getElementById('bgUploadMsg');
        var contextPath = '${pageContext.request.contextPath}';

        function setMsg(text, isError) {
            uploadMsg.textContent = text || '';
            uploadMsg.style.color = isError ? '#b91c1c' : '#334155';
        }

        function applyBackground(ts) {
            var bgUrl = contextPath + '/api/background/current?ts=' + ts;
            document.body.style.background =
                'url(' + bgUrl + ') center center / cover no-repeat fixed';
        }

        uploadBtn.addEventListener('click', function () {
            fileInput.value = '';
            fileInput.click();
        });

        fileInput.addEventListener('change', function () {
            if (!fileInput.files || !fileInput.files.length) {
                return;
            }
            var file = fileInput.files[0];
            var formData = new FormData();
            formData.append('file', file);

            uploadBtn.disabled = true;
            setMsg('正在上传背景图，请稍候...', false);

            fetch(contextPath + '/api/background/upload', {
                method: 'POST',
                body: formData
            })
                .then(function (response) { return response.json(); })
                .then(function (res) {
                    if (res && res.code === 200) {
                        var ts = Date.now();
                        applyBackground(ts);
                        setMsg('背景图替换成功。', false);
                    } else {
                        setMsg((res && res.message) ? res.message : '上传失败，请重试。', true);
                    }
                })
                .catch(function (err) {
                    setMsg('上传失败：' + (err && err.message ? err.message : err), true);
                })
                .finally(function () {
                    uploadBtn.disabled = false;
                });
        });
    })();
</script>
</body>
</html>
