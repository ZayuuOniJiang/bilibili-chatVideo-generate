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
        .card{
            background:var(--panel-bg);
            border-radius:16px;
            border:1px solid var(--panel-border);
            box-shadow:var(--shadow-soft);
            backdrop-filter:blur(12px);
            padding:1.2rem 1.25rem;
            display:flex;
            flex-direction:column;
            flex:1;
            min-height:560px;
        }
        .batch-card {
            min-height:560px;
        }
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
        textarea { min-height:74px; resize:vertical; }
        .btn{padding:0.42rem 0.85rem;background:rgba(255,255,255,0.95);color:#111827;border:1px solid rgba(203,213,225,0.95);border-radius:9px;font-size:0.83rem;font-weight:600;cursor:pointer;margin-right:0.35rem;margin-bottom:0.35rem;}
        .btn:hover{background:#f8fafc;}
        .btn-danger { background:#fef2f2; color:#991b1b; border-color:#fecaca; }
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

        .table-wrap {
            border:1px solid rgba(203,213,225,0.95);
            border-radius:10px;
            overflow:auto;
            background:rgba(255,255,255,0.9);
            margin-top:0.6rem;
            flex:1;
            min-height:0;
        }
        table { width:100%; border-collapse: collapse; min-width:760px; }
        th, td {
            padding:0.45rem 0.55rem;
            border-bottom:1px solid rgba(226,232,240,0.95);
            text-align:left;
            color:#0f172a;
            font-size:0.82rem;
        }
        th { position: sticky; top:0; background: rgba(248,250,252,0.95); color:#334155; z-index:2; }

        .modal-mask {
            position: fixed;
            inset: 0;
            background: rgba(15,23,42,0.36);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 999;
        }
        .modal {
            width: min(760px, 92vw);
            max-height: 90vh;
            overflow: auto;
            background: rgba(255,255,255,0.97);
            border: 1px solid rgba(203,213,225,0.95);
            border-radius: 14px;
            box-shadow: 0 24px 60px rgba(15,23,42,0.24);
            padding: 1rem 1.1rem;
        }

        @media (max-width: 980px) {
            .app-layout { flex-direction:column; }
            .sidebar { width:100%; height:auto; position:static; }
            .grid-2 { grid-template-columns: repeat(1,minmax(0,1fr)); }
            .card, .batch-card { min-height:auto; }
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
            <div>支持单个上传和批量上传。</div>
        </div>
    </aside>

    <main class="main">
        <div class="main-header">
            <div class="main-title">上传至B站视频（biliup.exe）</div>
            <div class="main-subtitle">上方为单个视频提交，下方为批量视频提交。</div>
        </div>

        <div class="row">
            <div class="col" style="flex: 5 1 0;">
                <div class="card">
                    <h2>登录与上传参数</h2>
                    <p class="sub">单个视频提交：打开登录终端 -> 刷新登录状态 -> 选视频 -> 开始上传。</p>

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
                            <input type="text" id="videoPath" class="mono" placeholder="点击按钮上传后自动回填" />
                            <div><button type="button" class="btn" id="uploadVideoBtn">选择本地视频并上传</button></div>
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
                            <input type="text" id="coverPath" class="mono" placeholder="点击按钮上传后自动回填" />
                            <div><button type="button" class="btn" id="uploadCoverBtn">选择本地封面并上传</button></div>
                        </div>
                        <div>
                            <label>额外参数（可选）</label>
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
                    <p class="sub">单个上传日志窗口。</p>
                    <div id="taskMeta" class="mono" style="font-size:0.82rem;color:#334155;">当前任务：无</div>
                    <div id="taskLog" class="log-box">等待执行...</div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col" style="flex: 5 1 0;">
                <div class="card batch-card">
                    <h2>批量上传</h2>
                    <p class="sub">可选择视频管理中的 `_sub.mp4` 文件批量提交，默认标题为去除 `_sub` 的文件名。</p>

                    <div class="grid-2">
                        <div>
                            <label>统一模板：简介</label>
                            <textarea id="batchTemplateDesc" placeholder="批量统一简介"></textarea>
                        </div>
                        <div>
                            <label>统一模板：标签（英文逗号分隔）</label>
                            <input type="text" id="batchTemplateTags" placeholder="例如：知识科普,AI,跑酷" />
                            <label>统一模板：分区ID（tid）</label>
                            <input type="text" id="batchTemplateTid" placeholder="例如：21" />
                        </div>
                    </div>

                    <div>
                        <button type="button" class="btn" id="batchLoadVideosBtn">加载视频列表</button>
                        <button type="button" class="btn" id="batchSelectAllBtn">全选</button>
                        <button type="button" class="btn" id="batchInvertBtn">反选</button>
                        <button type="button" class="btn" id="batchSubmitBtn">批量开始上传</button>
                    </div>
                    <div id="batchMsg" class="msg"></div>

                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th style="width:60px;">选择</th>
                                <th style="width:70px;">Index</th>
                                <th>FileName</th>
                                <th>默认标题</th>
                                <th style="width:90px;">操作</th>
                            </tr>
                            </thead>
                            <tbody id="batchVideoBody"><tr><td colspan="5" style="color:#9ca3af;">点击“加载视频列表”获取数据</td></tr></tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col" style="flex: 7 1 0;">
                <div class="card batch-card">
                    <h2>上传任务日志</h2>
                    <p class="sub">批量上传任务状态及日志。</p>
                    <div class="table-wrap" style="max-height:250px;flex:unset;">
                        <table>
                            <thead>
                            <tr>
                                <th>标题</th>
                                <th>状态</th>
                                <th>退出码</th>
                                <th>错误</th>
                                <th>日志</th>
                            </tr>
                            </thead>
                            <tbody id="batchTaskBody"><tr><td colspan="5" style="color:#9ca3af;">尚未创建批量任务</td></tr></tbody>
                        </table>
                    </div>
                    <div id="batchTaskLogMeta" class="mono" style="font-size:0.82rem;color:#334155;margin-top:0.6rem;">当前日志：无</div>
                    <div id="batchTaskLog" class="log-box" style="height:220px;">等待选择任务日志...</div>
                </div>
            </div>
        </div>
    </main>
</div>

<div id="editModalMask" class="modal-mask">
    <div class="modal">
        <h3 style="margin-bottom:0.65rem;color:#0f172a;">编辑单视频上传参数</h3>
        <div class="grid-2">
            <div>
                <label>视频文件</label>
                <input type="text" id="editFileName" class="mono" readonly />
            </div>
            <div>
                <label>标题</label>
                <input type="text" id="editTitle" />
            </div>
        </div>
        <label>简介</label>
        <textarea id="editDesc"></textarea>
        <div class="grid-2">
            <div>
                <label>标签（英文逗号分隔）</label>
                <input type="text" id="editTags" />
            </div>
            <div>
                <label>分区ID（tid）</label>
                <input type="text" id="editTid" />
            </div>
        </div>
        <div class="grid-2">
            <div>
                <label>封面路径</label>
                <input type="text" id="editCoverPath" class="mono" />
                <div><button type="button" class="btn" id="editUploadCoverBtn">选择本地封面并上传</button></div>
            </div>
            <div>
                <label>额外参数</label>
                <input type="text" id="editExtraArgs" class="mono" placeholder="可选" />
            </div>
        </div>
        <div id="editModalMsg" class="msg"></div>
        <div style="margin-top:0.35rem;">
            <button type="button" class="btn" id="editSaveBtn">保存该视频配置</button>
            <button type="button" class="btn btn-danger" id="editCancelBtn">取消</button>
        </div>
    </div>
</div>

<input type="file" id="videoFileInput" accept="video/*" style="display:none;" />
<input type="file" id="coverFileInput" accept="image/*" style="display:none;" />
<input type="file" id="editCoverFileInput" accept="image/*" style="display:none;" />

<script>
(function () {
    var contextPath = '${pageContext.request.contextPath}';

    var currentTaskId = '';
    var singlePollTimer = null;
    var batchPollTimer = null;

    var batchVideos = [];
    var batchVideoOverrideMap = {};
    var batchTasks = [];
    var currentBatchLogTaskId = '';
    var editingVideoPath = '';

    function byId(id) { return document.getElementById(id); }

    function showMsg(ele, text, isErr) {
        ele.textContent = text || '';
        ele.className = 'msg ' + (isErr ? 'err' : 'ok');
        ele.style.display = 'block';
    }

    function hideMsg(ele) { ele.style.display = 'none'; }

    function esc(s) {
        return String(s || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/\"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function uploadAsset(file, assetType) {
        var fd = new FormData();
        fd.append('file', file);
        fd.append('assetType', assetType);
        return fetch(contextPath + '/api/biliup/upload-asset', {
            method: 'POST',
            body: fd
        }).then(function (r) { return r.json(); });
    }

    function openLoginShell() {
        hideMsg(byId('formMsg'));
        var loginMode = (byId('loginMode').value || 'interactive').trim();
        fetch(contextPath + '/api/biliup/login-shell', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ loginMode: loginMode })
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

    function checkLoginStatus() {
        fetch(contextPath + '/api/biliup/login-status')
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取登录状态失败');
                }
                var d = res.data;
                byId('loginStatusText').textContent = '登录状态：' + (d.loggedIn ? '已登录' : '未登录')
                    + ' | cookie=' + (d.cookiePath || '');
            })
            .catch(function (e) {
                byId('loginStatusText').textContent = '登录状态检测失败：' + (e.message || e);
            });
    }

    function bindSingleAssetUpload(btnId, inputId, assetType, targetId, msgId) {
        var btn = byId(btnId);
        var input = byId(inputId);
        var target = byId(targetId);
        var msg = byId(msgId);
        btn.addEventListener('click', function () {
            input.value = '';
            input.click();
        });
        input.addEventListener('change', function () {
            if (!input.files || !input.files.length) {
                return;
            }
            hideMsg(msg);
            uploadAsset(input.files[0], assetType)
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

    function readSingleConfig() {
        return {
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

    function startSingleUpload() {
        hideMsg(byId('formMsg'));
        var cfg = readSingleConfig();
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
                startSinglePolling();
                showMsg(byId('formMsg'), '上传任务已启动。', false);
            })
            .catch(function (e) {
                showMsg(byId('formMsg'), e.message || e, true);
            });
    }

    function refreshSingleTask() {
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
                    stopSinglePolling();
                    if (d.status === 'SUCCESS') {
                        showMsg(byId('formMsg'), '上传完成。', false);
                    } else {
                        showMsg(byId('formMsg'), '上传失败：' + (d.errorMessage || '请查看日志'), true);
                    }
                }
            })
            .catch(function (e) {
                stopSinglePolling();
                showMsg(byId('formMsg'), e.message || e, true);
            });
    }

    function startSinglePolling() {
        stopSinglePolling();
        singlePollTimer = setInterval(refreshSingleTask, 2000);
    }

    function stopSinglePolling() {
        if (singlePollTimer) {
            clearInterval(singlePollTimer);
            singlePollTimer = null;
        }
    }

    function defaultTitleFromFile(fileName) {
        var name = String(fileName || '');
        if (name.toLowerCase().endsWith('_sub.mp4')) {
            return name.substring(0, name.length - '_sub.mp4'.length);
        }
        if (name.toLowerCase().endsWith('.mp4')) {
            return name.substring(0, name.length - '.mp4'.length);
        }
        return name;
    }

    function loadBatchVideos() {
        hideMsg(byId('batchMsg'));
        fetch(contextPath + '/api/video/manage/list')
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取视频列表失败');
                }
                batchVideos = (res.data || []).map(function (it) {
                    return {
                        index: it.index || '',
                        fileName: it.fileName || '',
                        absolutePath: it.absolutePath || '',
                        defaultTitle: defaultTitleFromFile(it.fileName || ''),
                        selected: false
                    };
                });
                renderBatchVideoTable();
            })
            .catch(function (e) {
                showMsg(byId('batchMsg'), e.message || e, true);
            });
    }

    function renderBatchVideoTable() {
        var body = byId('batchVideoBody');
        body.innerHTML = '';
        if (!batchVideos.length) {
            body.innerHTML = '<tr><td colspan="5" style="color:#9ca3af;">暂无可上传视频</td></tr>';
            return;
        }
        batchVideos.forEach(function (v) {
            var tr = document.createElement('tr');
            tr.innerHTML = ''
                + '<td><input type="checkbox" data-batch-video="' + esc(v.absolutePath) + '" ' + (v.selected ? 'checked' : '') + ' /></td>'
                + '<td>' + esc(v.index) + '</td>'
                + '<td class="mono">' + esc(v.fileName) + '</td>'
                + '<td>' + esc(v.defaultTitle) + '</td>'
                + '<td><button type="button" class="btn" data-edit-video="' + esc(v.absolutePath) + '">编辑</button></td>';
            body.appendChild(tr);
        });

        body.querySelectorAll('input[data-batch-video]').forEach(function (cb) {
            cb.addEventListener('change', function () {
                var path = cb.getAttribute('data-batch-video') || '';
                batchVideos.forEach(function (v) {
                    if (v.absolutePath === path) {
                        v.selected = !!cb.checked;
                    }
                });
            });
        });

        body.querySelectorAll('button[data-edit-video]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var path = btn.getAttribute('data-edit-video') || '';
                openEditModal(path);
            });
        });
    }

    function getBatchTemplate() {
        return {
            description: (byId('batchTemplateDesc').value || '').trim(),
            tags: (byId('batchTemplateTags').value || '').trim(),
            partitionId: (byId('batchTemplateTid').value || '').trim(),
            coverPath: '',
            extraArgs: ''
        };
    }

    function applyBatchSelectAll() {
        batchVideos.forEach(function (v) { v.selected = true; });
        renderBatchVideoTable();
    }

    function applyBatchInvert() {
        batchVideos.forEach(function (v) { v.selected = !v.selected; });
        renderBatchVideoTable();
    }

    function openEditModal(videoPath) {
        editingVideoPath = videoPath;
        hideMsg(byId('editModalMsg'));

        var video = null;
        batchVideos.forEach(function (v) {
            if (v.absolutePath === videoPath) {
                video = v;
            }
        });
        if (!video) {
            return;
        }

        var template = getBatchTemplate();
        var override = batchVideoOverrideMap[videoPath] || {};

        byId('editFileName').value = video.fileName || '';
        byId('editTitle').value = override.title || video.defaultTitle || '';
        byId('editDesc').value = override.description != null ? override.description : template.description;
        byId('editTags').value = override.tags != null ? override.tags : template.tags;
        byId('editTid').value = override.partitionId != null ? override.partitionId : template.partitionId;
        byId('editCoverPath').value = override.coverPath || '';
        byId('editExtraArgs').value = override.extraArgs || '';

        byId('editModalMask').style.display = 'flex';
    }

    function closeEditModal() {
        byId('editModalMask').style.display = 'none';
        editingVideoPath = '';
    }

    function saveEditModal() {
        if (!editingVideoPath) {
            return;
        }
        batchVideoOverrideMap[editingVideoPath] = {
            title: (byId('editTitle').value || '').trim(),
            description: (byId('editDesc').value || '').trim(),
            tags: (byId('editTags').value || '').trim(),
            partitionId: (byId('editTid').value || '').trim(),
            coverPath: (byId('editCoverPath').value || '').trim(),
            extraArgs: (byId('editExtraArgs').value || '').trim()
        };
        showMsg(byId('editModalMsg'), '已保存该视频覆盖参数。', false);
        setTimeout(closeEditModal, 350);
    }

    function submitBatch() {
        hideMsg(byId('batchMsg'));
        var selected = batchVideos.filter(function (v) { return v.selected; });
        if (!selected.length) {
            showMsg(byId('batchMsg'), '请先选择至少一个视频。', true);
            return;
        }

        var template = getBatchTemplate();
        var requests = selected.map(function (v) {
            var override = batchVideoOverrideMap[v.absolutePath] || {};
            return {
                videoPath: v.absolutePath,
                title: override.title || v.defaultTitle,
                description: override.description != null ? override.description : template.description,
                tags: override.tags != null ? override.tags : template.tags,
                partitionId: override.partitionId != null ? override.partitionId : template.partitionId,
                coverPath: override.coverPath || template.coverPath,
                extraArgs: override.extraArgs || template.extraArgs
            };
        });

        var submitOne = function (req) {
            return fetch(contextPath + '/api/biliup/upload/start', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(function (r) { return r.json(); })
                .then(function (res) {
                    if (res.code !== 200 || !res.data) {
                        return {
                            title: req.title,
                            videoPath: req.videoPath,
                            status: 'FAILED',
                            exitCode: null,
                            errorMessage: res.message || '提交失败',
                            taskId: ''
                        };
                    }
                    return {
                        title: req.title,
                        videoPath: req.videoPath,
                        status: 'PENDING',
                        exitCode: null,
                        errorMessage: '',
                        taskId: res.data.taskId || ''
                    };
                })
                .catch(function (e) {
                    return {
                        title: req.title,
                        videoPath: req.videoPath,
                        status: 'FAILED',
                        exitCode: null,
                        errorMessage: e.message || String(e),
                        taskId: ''
                    };
                });
        };

        Promise.all(requests.map(submitOne)).then(function (rows) {
            batchTasks = rows;
            renderBatchTaskTable();
            startBatchPolling();
            showMsg(byId('batchMsg'), '批量提交完成，已创建任务：' + rows.filter(function (x) { return !!x.taskId; }).length, false);
        });
    }

    function renderBatchTaskTable() {
        var body = byId('batchTaskBody');
        body.innerHTML = '';
        if (!batchTasks.length) {
            body.innerHTML = '<tr><td colspan="5" style="color:#9ca3af;">尚未创建批量任务</td></tr>';
            return;
        }
        batchTasks.forEach(function (t, idx) {
            var tr = document.createElement('tr');
            tr.innerHTML = ''
                + '<td>' + esc(t.title || '') + '</td>'
                + '<td>' + esc(t.status || '') + '</td>'
                + '<td>' + esc(t.exitCode == null ? '-' : t.exitCode) + '</td>'
                + '<td>' + esc(t.errorMessage || '') + '</td>'
                + '<td>' + (t.taskId ? ('<button type="button" class="btn" data-log-task="' + esc(t.taskId) + '">查看</button>') : '-') + '</td>';
            body.appendChild(tr);
        });

        body.querySelectorAll('button[data-log-task]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                currentBatchLogTaskId = btn.getAttribute('data-log-task') || '';
                refreshBatchLogByTaskId(currentBatchLogTaskId);
            });
        });
    }

    function refreshBatchTaskStatus() {
        var active = batchTasks.filter(function (t) {
            return !!t.taskId && t.status !== 'SUCCESS' && t.status !== 'FAILED';
        });
        if (!active.length) {
            stopBatchPolling();
            return;
        }

        Promise.all(active.map(function (t) {
            return fetch(contextPath + '/api/biliup/upload/task?taskId=' + encodeURIComponent(t.taskId))
                .then(function (r) { return r.json(); })
                .then(function (res) {
                    if (res.code !== 200 || !res.data) {
                        return;
                    }
                    var d = res.data;
                    t.status = d.status || t.status;
                    t.exitCode = d.exitCode;
                    t.errorMessage = d.errorMessage || '';
                    t.logs = d.logs || [];
                });
        })).then(function () {
            renderBatchTaskTable();
            if (currentBatchLogTaskId) {
                refreshBatchLogByTaskId(currentBatchLogTaskId);
            }
        });
    }

    function refreshBatchLogByTaskId(taskId) {
        if (!taskId) {
            return;
        }
        fetch(contextPath + '/api/biliup/upload/task?taskId=' + encodeURIComponent(taskId))
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取日志失败');
                }
                var d = res.data;
                byId('batchTaskLogMeta').textContent = '当前日志任务：' + taskId + ' | 状态：' + (d.status || '') + ' | 退出码：' + (d.exitCode == null ? '-' : d.exitCode);
                var logs = d.logs || [];
                byId('batchTaskLog').textContent = logs.length ? logs.join('\n') : '暂无日志输出';
                byId('batchTaskLog').scrollTop = byId('batchTaskLog').scrollHeight;
            })
            .catch(function (e) {
                byId('batchTaskLogMeta').textContent = '当前日志任务：' + taskId + ' | 读取失败';
                byId('batchTaskLog').textContent = String(e.message || e);
            });
    }

    function startBatchPolling() {
        stopBatchPolling();
        batchPollTimer = setInterval(refreshBatchTaskStatus, 2200);
    }

    function stopBatchPolling() {
        if (batchPollTimer) {
            clearInterval(batchPollTimer);
            batchPollTimer = null;
        }
    }

    byId('openLoginBtn').addEventListener('click', openLoginShell);
    byId('checkLoginBtn').addEventListener('click', checkLoginStatus);
    byId('startUploadBtn').addEventListener('click', startSingleUpload);
    byId('refreshTaskBtn').addEventListener('click', refreshSingleTask);

    bindSingleAssetUpload('uploadVideoBtn', 'videoFileInput', 'video', 'videoPath', 'assetMsg');
    bindSingleAssetUpload('uploadCoverBtn', 'coverFileInput', 'cover', 'coverPath', 'assetMsg');

    byId('batchLoadVideosBtn').addEventListener('click', loadBatchVideos);
    byId('batchSelectAllBtn').addEventListener('click', applyBatchSelectAll);
    byId('batchInvertBtn').addEventListener('click', applyBatchInvert);
    byId('batchSubmitBtn').addEventListener('click', submitBatch);

    byId('editCancelBtn').addEventListener('click', closeEditModal);
    byId('editSaveBtn').addEventListener('click', saveEditModal);
    bindSingleAssetUpload('editUploadCoverBtn', 'editCoverFileInput', 'cover', 'editCoverPath', 'editModalMsg');

    checkLoginStatus();
})();
</script>
</body>
</html>
