<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --panel-bg: rgba(255,255,255,0.68);
            --panel-border: rgba(255,255,255,0.5);
            --text-main:#0f172a;
            --text-sub:#475569;
            --shadow-soft:0 18px 45px rgba(15,23,42,0.15);
        }
        body {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            min-height:100vh;
            color:var(--text-main);
            background: url('${pageContext.request.contextPath}/api/background/current') center center / cover no-repeat fixed;
        }
        .app-layout { display:flex; min-height:100vh; }
        .sidebar {
            width:240px;
            padding:1.5rem 1.1rem;
            background: rgba(236,244,255,0.72);
            border-right:1px solid rgba(255,255,255,0.55);
            display:flex;
            flex-direction:column;
            gap:1.5rem;
            backdrop-filter:blur(12px);
            box-shadow:8px 0 30px rgba(15,23,42,0.08);
            position:sticky;
            top:0;
            align-self:flex-start;
            height:100vh;
            overflow-y:auto;
        }
        .sidebar-header{display:flex;align-items:center;gap:0.75rem;}
        .sidebar-logo{width:32px;height:32px;border-radius:999px;background:radial-gradient(circle at 30% 30%, #38bdf8, #6366f1);}
        .sidebar-title{font-size:1rem;font-weight:700;color:#0f172a;}
        .nav-section-title{font-size:0.75rem;color:#475569;letter-spacing:0.08em;margin-bottom:0.25rem;}
        .nav-group{display:flex;flex-direction:column;gap:0.3rem;}
        .nav-link{display:flex;align-items:center;gap:0.5rem;padding:0.5rem 0.75rem;border-radius:10px;color:#1e293b;font-weight:600;text-decoration:none;font-size:0.88rem;transition:all 0.2s;}
        .nav-link:hover{background:rgba(255,255,255,0.65);transform:translateX(2px);}
        .nav-link-active{background:rgba(255,255,255,0.9);color:#111827;box-shadow:0 6px 18px rgba(15,23,42,0.12);}
        .nav-footer{margin-top:auto;font-size:0.75rem;color:#334155;line-height:1.5;}

        .main { flex:1; padding:1.6rem 1.8rem; display:flex; flex-direction:column; gap:1rem; }
        .main-header { background: var(--panel-bg); border:1px solid var(--panel-border); border-radius:14px; padding:1rem 1.25rem; backdrop-filter: blur(10px); box-shadow: var(--shadow-soft); }
        .main-title{font-size:1.25rem;font-weight:700;color:var(--text-main);}
        .main-subtitle{margin-top:0.35rem;color:var(--text-sub);font-size:0.9rem;}

        .row{display:flex;flex-wrap:wrap;gap:1rem;align-items:stretch;}
        .col{flex:1 1 420px;display:flex;}
        .card{background:var(--panel-bg);border-radius:16px;border:1px solid var(--panel-border);box-shadow:var(--shadow-soft);backdrop-filter:blur(12px);padding:1.2rem 1.25rem;display:flex;flex-direction:column;flex:1;min-height:560px;}
        .card h2{font-size:1.02rem;color:var(--text-main);margin-bottom:0.75rem;}
        .sub{color:var(--text-sub);font-size:0.9rem;margin-bottom:0.8rem;}

        .grid-2 { display:grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap:0.65rem; }
        label{display:block;margin-bottom:0.3rem;color:var(--text-sub);font-size:0.86rem;}
        input[type="text"], textarea, select {
            width:100%;
            padding:0.45rem 0.65rem;
            margin-bottom:0.7rem;
            border-radius:8px;
            border:1px solid rgba(203,213,225,0.95);
            background:rgba(255,255,255,0.9);
            color:#0f172a;
            font-size:0.9rem;
        }
        textarea { min-height: 74px; resize: vertical; }
        .btn{padding:0.42rem 0.85rem;background:rgba(255,255,255,0.95);color:#111827;border:1px solid rgba(203,213,225,0.95);border-radius:9px;font-size:0.83rem;font-weight:600;cursor:pointer;margin-right:0.35rem;margin-bottom:0.35rem;}
        .btn:hover{background:#f8fafc;}
        .msg{margin-top:0.4rem;font-size:0.83rem;display:none;}
        .msg.err{color:#b91c1c;}
        .msg.ok{color:#166534;}
        .mono{font-family:Consolas, "Courier New", monospace;}

        .log-box {
            margin-top:0.65rem;
            border:1px solid rgba(203,213,225,0.95);
            border-radius:10px;
            background:rgba(15,23,42,0.9);
            color:#e2e8f0;
            font-family:Consolas, "Courier New", monospace;
            font-size:0.82rem;
            line-height:1.6;
            padding:0.65rem;
            height:360px;
            overflow:auto;
            white-space:pre-wrap;
            word-break:break-word;
        }

        @media (max-width: 980px) {
            .app-layout { flex-direction:column; }
            .sidebar { width:100%; height:auto; position:static; }
            .grid-2 { grid-template-columns: repeat(1,minmax(0,1fr)); }
        }
    </style>
</head>
<body>
<div class="app-layout">
    <aside class="sidebar">
        <div class="sidebar-header"><div class="sidebar-logo"></div><div class="sidebar-title">B 站 · 跑酷对话视频</div></div>
        <div>
            <div class="nav-section-title">导航</div>
            <div class="nav-group">
                <a href="${pageContext.request.contextPath}/" class="nav-link"><span>首页</span></a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link"><span>跑酷生成仪表盘</span></a>
                <a href="${pageContext.request.contextPath}/zhihu" class="nav-link"><span>QA 文本管理</span></a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link"><span>管理模板</span></a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link"><span>批量创建视频</span></a>
                <a href="${pageContext.request.contextPath}/biliup-upload" class="nav-link nav-link-active"><span>上传至B站视频</span></a>
                <a href="${pageContext.request.contextPath}/video-manage" class="nav-link"><span>视频管理</span></a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link"><span>接口与合成测试</span></a>
            </div>
        </div>
        <div class="nav-footer">
            <div>先登录，再上传。</div>
            <div>登录凭据默认读取 workDir/cookie.json。</div>
        </div>
    </aside>

    <main class="main">
        <div class="main-header">
            <div class="main-title">上传至B站视频（biliup.exe）</div>
            <div class="main-subtitle">支持标题、封面、标签、分区设置；登录通过 PowerShell 执行 biliup login。</div>
        </div>

        <div class="row">
            <div class="col" style="flex: 5 1 0;">
                <div class="card">
                    <h2>登录与上传参数</h2>
                    <p class="sub">按顺序：环境配置 -> 打开登录终端 -> 刷新登录状态 -> 开始上传。</p>

                    <div class="grid-2">
                        <div>
                            <label>biliup.exe 路径</label>
                            <input type="text" id="exePath" class="mono" placeholder="例如：D:\\tools\\biliup\\biliup.exe" />
                        </div>
                        <div>
                            <label>工作目录（cookie.json 所在目录）</label>
                            <input type="text" id="workDir" class="mono" placeholder="例如：D:\\tools\\biliup" />
                        </div>
                    </div>
                    <div class="grid-2">
                        <div>
                            <label>登录模式</label>
                            <select id="loginMode">
                                <option value="interactive" selected>交互选择（与 ./biliup.exe login 一致）</option>
                                <option value="qrcode">扫码登录（qrcode）</option>
                                <option value="password">账号密码（password）</option>
                                <option value="sms">短信登录（sms）</option>
                            </select>
                        </div>
                        <div style="display:flex;align-items:flex-end;gap:0.35rem;">
                            <button type="button" class="btn" id="openLoginBtn">打开登录终端</button>
                            <button type="button" class="btn" id="checkLoginBtn">刷新登录状态</button>
                        </div>
                    </div>
                    <div id="loginStatusText" class="mono" style="font-size:0.82rem;color:#334155;margin-bottom:0.55rem;">登录状态：未检测</div>

                    <div class="grid-2">
                        <div>
                            <label>视频路径（本地绝对路径）</label>
                            <input type="text" id="videoPath" class="mono" placeholder="例如：D:\\video\\demo.mp4" />
                            <div>
                                <button type="button" class="btn" id="uploadVideoBtn">选择本地视频并上传</button>
                            </div>
                        </div>
                        <div>
                            <label>标题</label>
                            <input type="text" id="title" placeholder="例如：今天来聊聊这个问题" />
                        </div>
                    </div>

                    <label>简介</label>
                    <textarea id="description" placeholder="可选"></textarea>

                    <div class="grid-2">
                        <div>
                            <label>标签（英文逗号分隔）</label>
                            <input type="text" id="tags" placeholder="例如：知识科普,AI,跑酷" />
                        </div>
                        <div>
                            <label>分区ID（tid）</label>
                            <input type="text" id="partitionId" placeholder="例如：21" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div>
                            <label>封面路径（可选）</label>
                            <input type="text" id="coverPath" class="mono" placeholder="例如：D:\\cover\\cover.jpg" />
                            <div>
                                <button type="button" class="btn" id="uploadCoverBtn">选择本地封面并上传</button>
                            </div>
                        </div>
                        <div>
                            <label>额外参数（可选，原样拼接到命令末尾）</label>
                            <input type="text" id="extraArgs" class="mono" placeholder="例如：--dynamic \"这是一条动态\"" />
                        </div>
                    </div>

                    <div id="assetMsg" class="msg"></div>

                    <div>
                        <button type="button" class="btn" id="startUploadBtn">开始上传</button>
                        <button type="button" class="btn" id="refreshTaskBtn">刷新任务状态</button>
                    </div>
                    <div id="formMsg" class="msg"></div>
                </div>
            </div>

            <div class="col" style="flex: 7 1 0;">
                <div class="card">
                    <h2>上传任务日志</h2>
                    <p class="sub">命令执行输出会实时刷新；如参数语法与本地 biliup 版本不同，可通过额外参数快速调整。</p>
                    <div id="taskMeta" class="mono" style="font-size:0.82rem;color:#334155;">当前任务：无</div>
                    <div id="taskLog" class="log-box">等待执行...</div>
                </div>
            </div>
        </div>
    </main>
</div>

<input type="file" id="videoFileInput" accept="video/*" style="display:none;" />
<input type="file" id="coverFileInput" accept="image/*" style="display:none;" />

<script>
(function () {
    var contextPath = '${pageContext.request.contextPath}';
    var currentTaskId = '';
    var pollTimer = null;

    function byId(id) { return document.getElementById(id); }

    function showMsg(ele, text, isErr) {
        ele.textContent = text || '';
        ele.className = 'msg ' + (isErr ? 'err' : 'ok');
        ele.style.display = 'block';
    }

    function hideMsg(ele) { ele.style.display = 'none'; }

    function uploadAsset(file, assetType) {
        var fd = new FormData();
        fd.append('file', file);
        fd.append('assetType', assetType);
        return fetch(contextPath + '/api/biliup/upload-asset', {
            method: 'POST',
            body: fd
        }).then(function (r) { return r.json(); });
    }

    function esc(s) {
        return String(s || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/\"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function readConfig() {
        return {
            exePath: (byId('exePath').value || '').trim(),
            workDir: (byId('workDir').value || '').trim(),
            loginMode: (byId('loginMode').value || 'interactive').trim(),
            videoPath: (byId('videoPath').value || '').trim(),
            title: (byId('title').value || '').trim(),
            description: (byId('description').value || '').trim(),
            tags: (byId('tags').value || '').trim(),
            partitionId: (byId('partitionId').value || '').trim(),
            coverPath: (byId('coverPath').value || '').trim(),
            extraArgs: (byId('extraArgs').value || '').trim()
        };
    }

    function stopPolling() {
        if (pollTimer) {
            clearInterval(pollTimer);
            pollTimer = null;
        }
    }

    function startPolling() {
        stopPolling();
        pollTimer = setInterval(function () {
            if (!currentTaskId) {
                return;
            }
            fetchTask();
        }, 2000);
    }

    function loadDefaultConfig() {
        fetch(contextPath + '/api/biliup/default-config')
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    return;
                }
                if (!byId('exePath').value) {
                    byId('exePath').value = res.data.exePath || '';
                }
                if (!byId('workDir').value) {
                    byId('workDir').value = res.data.workDir || '';
                }
            });
    }

    function checkLoginStatus() {
        var cfg = readConfig();
        var qs = '?exePath=' + encodeURIComponent(cfg.exePath) + '&workDir=' + encodeURIComponent(cfg.workDir);
        fetch(contextPath + '/api/biliup/login-status' + qs)
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取登录状态失败');
                }
                var data = res.data;
                var text = '登录状态：' + (data.loggedIn ? '已登录' : '未登录')
                    + ' | exe存在=' + data.exeExists
                    + ' | workDir存在=' + data.workDirExists
                    + ' | cookie=' + (data.cookiePath || '');
                byId('loginStatusText').textContent = text;
            })
            .catch(function (e) {
                byId('loginStatusText').textContent = '登录状态检测失败：' + (e.message || e);
            });
    }

    function openLoginShell() {
        hideMsg(byId('formMsg'));
        var cfg = readConfig();
        fetch(contextPath + '/api/biliup/login-shell', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                exePath: cfg.exePath,
                workDir: cfg.workDir,
                loginMode: cfg.loginMode
            })
        }).then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200) {
                    throw new Error(res.message || '打开登录终端失败');
                }
                showMsg(byId('formMsg'), '已打开登录终端，请按终端提示完成登录。', false);
            })
            .catch(function (e) {
                showMsg(byId('formMsg'), e.message || e, true);
            });
    }

    function bindAssetUpload(btnId, inputId, assetType, targetId) {
        var btn = byId(btnId);
        var input = byId(inputId);
        var target = byId(targetId);
        var msg = byId('assetMsg');
        btn.addEventListener('click', function () {
            input.value = '';
            input.click();
        });
        input.addEventListener('change', function () {
            if (!input.files || !input.files.length) {
                return;
            }
            hideMsg(msg);
            var file = input.files[0];
            uploadAsset(file, assetType)
                .then(function (res) {
                    if (res.code !== 200 || !res.data) {
                        throw new Error(res.message || '上传失败');
                    }
                    target.value = res.data.path || '';
                    showMsg(msg, '上传成功，已回填路径：' + (res.data.path || ''), false);
                })
                .catch(function (e) {
                    showMsg(msg, e.message || e, true);
                })
                .finally(function () {
                    input.value = '';
                });
        });
    }

    function startUpload() {
        hideMsg(byId('formMsg'));
        var cfg = readConfig();
        if (!cfg.videoPath) {
            showMsg(byId('formMsg'), 'videoPath 不能为空', true);
            return;
        }

        fetch(contextPath + '/api/biliup/upload/start', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(cfg)
        }).then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '启动上传失败');
                }
                currentTaskId = res.data.taskId || '';
                byId('taskMeta').textContent = '任务ID：' + currentTaskId + ' | 状态：' + (res.data.status || '') + ' | 命令：' + (res.data.command || '');
                byId('taskLog').textContent = '任务已启动，正在拉取日志...';
                startPolling();
                showMsg(byId('formMsg'), '上传任务已启动。', false);
            })
            .catch(function (e) {
                showMsg(byId('formMsg'), e.message || e, true);
            });
    }

    function fetchTask() {
        if (!currentTaskId) {
            return;
        }
        fetch(contextPath + '/api/biliup/upload/task?taskId=' + encodeURIComponent(currentTaskId))
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取任务失败');
                }
                var d = res.data;
                byId('taskMeta').textContent = '任务ID：' + (d.taskId || '')
                    + ' | 状态：' + (d.status || '')
                    + ' | 退出码：' + (d.exitCode == null ? '-' : d.exitCode)
                    + ' | 命令：' + (d.command || '');

                var logs = d.logs || [];
                if (logs.length) {
                    byId('taskLog').textContent = logs.join('\n');
                    byId('taskLog').scrollTop = byId('taskLog').scrollHeight;
                }

                if (d.status === 'SUCCESS' || d.status === 'FAILED') {
                    stopPolling();
                    if (d.status === 'SUCCESS') {
                        showMsg(byId('formMsg'), '上传完成。', false);
                    } else {
                        showMsg(byId('formMsg'), '上传失败：' + (d.errorMessage || '请查看日志'), true);
                    }
                }
            })
            .catch(function (e) {
                stopPolling();
                showMsg(byId('formMsg'), e.message || e, true);
            });
    }

    byId('openLoginBtn').addEventListener('click', openLoginShell);
    byId('checkLoginBtn').addEventListener('click', checkLoginStatus);
    byId('startUploadBtn').addEventListener('click', startUpload);
    byId('refreshTaskBtn').addEventListener('click', fetchTask);
    bindAssetUpload('uploadVideoBtn', 'videoFileInput', 'video', 'videoPath');
    bindAssetUpload('uploadCoverBtn', 'coverFileInput', 'cover', 'coverPath');

    loadDefaultConfig();
    checkLoginStatus();
})();
</script>
</body>
</html>
