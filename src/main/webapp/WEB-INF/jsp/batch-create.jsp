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
        .card{background:var(--panel-bg);border-radius:16px;border:1px solid var(--panel-border);box-shadow:var(--shadow-soft);backdrop-filter:blur(12px);padding:1.5rem 1.6rem;display:flex;flex-direction:column;flex:1;min-height:760px;}
        .card h2{font-size:1.02rem;color:var(--text-main);margin-bottom:0.75rem;} 
        .sub{color:var(--text-sub);font-size:0.9rem;margin-bottom:0.9rem;}
        label{display:block;margin-bottom:0.35rem;color:var(--text-sub);font-size:0.9rem;}
        textarea, select {
            width:100%;
            padding:0.5rem 0.75rem;
            margin-bottom:0.9rem;
            border-radius:8px;
            border:1px solid rgba(203,213,225,0.95);
            background:rgba(255,255,255,0.9);
            color:#0f172a;
        }
        textarea{min-height:140px;resize:vertical;}
        .btn{padding:0.45rem 0.9rem;background:rgba(255,255,255,0.95);color:#111827;border:1px solid rgba(203,213,225,0.95);border-radius:10px;font-size:0.84rem;font-weight:600;cursor:pointer;margin-right:0.45rem;margin-bottom:0.45rem;}
        .btn-danger{background:#fef2f2;color:#991b1b;border-color:#fecaca;}
        .msg{margin-top:0.5rem;font-size:0.85rem;display:none;} 
        .msg.err{color:#b91c1c;} 
        .msg.ok{color:#166534;}
        .list-box{border:1px solid rgba(203,213,225,0.95);border-radius:10px;padding:0.5rem 0.65rem;overflow:auto;flex:1;min-height:0;background:rgba(255,255,255,0.82);} 
        .list-item{padding:0.4rem 0;border-bottom:1px solid rgba(226,232,240,0.95);} 
        .list-item:last-child{border-bottom:none;}
        .table-wrap{margin-top:0.75rem;border:1px solid rgba(203,213,225,0.95);border-radius:10px;overflow:auto;flex:1;min-height:0;background:rgba(255,255,255,0.86);} 
        table{width:100%;border-collapse:collapse;min-width:980px;} 
        th,td{padding:0.55rem 0.65rem;border-bottom:1px solid rgba(226,232,240,0.95);text-align:left;color:#0f172a;font-size:0.86rem;} 
        th{position:sticky;top:0;background:rgba(248,250,252,0.95);color:#334155;z-index:2;}
        .modal-mask{position:fixed;inset:0;background:rgba(15,23,42,0.35);display:flex;align-items:center;justify-content:center;z-index:999;} 
        .modal{width:min(640px,92vw);max-height:88vh;overflow:auto;background:rgba(255,255,255,0.96);border:1px solid rgba(203,213,225,0.95);border-radius:14px;box-shadow:0 20px 50px rgba(15,23,42,0.22);padding:1rem 1.1rem;}
        .review-item{border:1px solid rgba(203,213,225,0.95);border-radius:10px;padding:0.6rem;margin-bottom:0.6rem;background:rgba(255,255,255,0.9);}
        .mono{font-family:Consolas, "Courier New", monospace;}
    </style>
</head>
<body>
<div id="setupModal" class="modal-mask">
    <div class="modal">
        <h3 style="margin-bottom:0.65rem;color:#0f172a;">首次进入，请先选择模板与批量模式</h3>
        <label>模板文件</label>
        <select id="templateSelect"></select>
        <label>批量模式</label>
        <select id="runModeSelect">
            <option value="auto">全自动</option>
            <option value="manual">人工审查</option>
        </select>
        <button type="button" class="btn" id="startInitBtn">确认并进入页面</button>
        <div id="setupMsg" class="msg"></div>
    </div>
</div>

<div id="reviewModal" class="modal-mask" style="display:none;">
    <div class="modal">
        <h3 style="margin-bottom:0.65rem;color:#0f172a;">人工审查脚本</h3>
        <p style="color:#475569;font-size:0.9rem;margin-bottom:0.7rem;">你可以编辑每条任务脚本，也可以一键恢复原脚本，然后提交进入视频生成。</p>
        <div id="reviewModalList"></div>
        <div>
            <button type="button" class="btn" id="confirmReviewBtn">提交审查脚本并开始生成</button>
            <button type="button" class="btn" id="closeReviewBtn">暂不提交</button>
        </div>
        <div id="reviewMsg" class="msg"></div>
    </div>
</div>

<div id="summaryModal" class="modal-mask" style="display:none;">
    <div class="modal" style="width:min(420px,90vw);">
        <h3 style="margin-bottom:0.75rem;color:#0f172a;">批次已完成</h3>
        <div id="summaryText" style="color:#334155;line-height:1.7;font-size:0.92rem;"></div>
        <div style="margin-top:0.8rem;">
            <button type="button" class="btn" id="summaryOkBtn">知道了</button>
        </div>
    </div>
</div>

<div class="app-layout">
    <aside class="sidebar">
        <div class="sidebar-header"><div class="sidebar-logo"></div><div class="sidebar-title">B 站 AI 对话视频</div></div>
        <div>
            <div class="nav-section-title">导航</div>
            <div class="nav-group">
                <a href="${pageContext.request.contextPath}/" class="nav-link"><span>首页</span></a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link"><span>仪表盘创作</span></a>
                <a href="${pageContext.request.contextPath}/zhihu" class="nav-link"><span>QA 文本管理</span></a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link"><span>管理模板</span></a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link nav-link-active"><span>批量创建视频</span></a>
                    <a href="${pageContext.request.contextPath}/biliup-upload" class="nav-link"><span>上传至B站视频</span></a>
                <a href="${pageContext.request.contextPath}/video-manage" class="nav-link"><span>视频管理</span></a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link"><span>接口测试</span></a>
            </div>
        </div>
        <div class="nav-footer">
            <div id="currentTplInfo">当前模板：未选择</div>
            <div id="currentModeInfo">批量模式：未选择</div>
        </div>
    </aside>
    <main class="main">
        <div class="main-header">
            <div class="main-title">批量创建视频页面</div>
            <div class="main-subtitle">支持全自动/人工审查模式，先选 QA，再并发创建视频。</div>
        </div>
        <div class="row">
            <div class="col" style="flex: 5 1 0;">
                <div class="card">
                    <h2>QA 选择区</h2>
                    <p class="sub">可多选、全选、反选。每个 QA 会生成一个批量任务。</p>
                    <div>
                        <button type="button" class="btn" id="loadQaBtn">加载 QA</button>
                        <button type="button" class="btn" id="selectAllBtn">全选</button>
                        <button type="button" class="btn" id="invertBtn">反选</button>
                    </div>
                    <div id="qaMsg" class="msg"></div>
                    <div class="list-box" id="qaListBox"></div>
                    <div style="margin-top:0.8rem;">
                        <button type="button" class="btn" id="createBatchBtn">开始批量创建</button>
                        <button type="button" class="btn btn-danger" id="cancelBatchBtn">取消当前批次</button>
                    </div>
                    <div id="batchMsg" class="msg"></div>
                </div>
            </div>
            <div class="col" style="flex: 7 1 0;">
                <div class="card">
                    <h2>任务进度与结果</h2>
                    <p class="sub">状态、进度、输出路径和错误信息会实时刷新。</p>
                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th>序号</th>
                                <th>标题</th>
                                <th>状态</th>
                                <th>进度</th>
                                <th>输出路径</th>
                                <th>错误信息</th>
                            </tr>
                            </thead>
                            <tbody id="progressBody"><tr><td colspan="6" style="color:#9ca3af;">尚未创建批次</td></tr></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
(function () {
    var setupModal = document.getElementById('setupModal');
    var templateSelect = document.getElementById('templateSelect');
    var runModeSelect = document.getElementById('runModeSelect');
    var setupMsg = document.getElementById('setupMsg');

    var reviewModal = document.getElementById('reviewModal');
    var reviewModalList = document.getElementById('reviewModalList');
    var reviewMsg = document.getElementById('reviewMsg');

    var summaryModal = document.getElementById('summaryModal');
    var summaryText = document.getElementById('summaryText');

    var qaListBox = document.getElementById('qaListBox');
    var qaMsg = document.getElementById('qaMsg');
    var batchMsg = document.getElementById('batchMsg');
    var progressBody = document.getElementById('progressBody');

    var currentTplInfo = document.getElementById('currentTplInfo');
    var currentModeInfo = document.getElementById('currentModeInfo');

    var currentBatchId = '';
    var pollTimer = null;
    var reviewRenderedBatchId = '';
    var reviewOriginalMap = {};
    var completedBatchNoticeShown = false;

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
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function statusText(s) {
        if (s === 'PENDING') { return '待开始'; }
        if (s === 'SCRIPT_GENERATING') { return '脚本生成中'; }
        if (s === 'SCRIPT_REVIEW_PENDING') { return '待人工审查'; }
        if (s === 'VIDEO_GENERATING') { return '视频生成中'; }
        if (s === 'SUCCESS') { return '成功'; }
        if (s === 'FAILED') { return '失败'; }
        if (s === 'CANCELLED') { return '已取消'; }
        return s || '';
    }

    function loadTemplates() {
        fetch('${pageContext.request.contextPath}/api/template/list')
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) { throw new Error(res.message || '读取模板失败'); }
                templateSelect.innerHTML = '';
                if (!res.data.length) {
                    templateSelect.innerHTML = '<option value="">暂无模板，请先去模板管理页面创建</option>';
                    return;
                }
                res.data.forEach(function (it) {
                    var op = document.createElement('option');
                    op.value = it.fileName || '';
                    op.textContent = (it.templateName || '(未命名模板)') + ' - ' + (it.fileName || '');
                    templateSelect.appendChild(op);
                });
            })
            .catch(function (e) {
                showMsg(setupMsg, e.message || e, true);
            });
    }

    function loadQa() {
        hideMsg(qaMsg);
        fetch('${pageContext.request.contextPath}/api/bashboard/qa/overview')
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) { throw new Error(res.message || '加载 QA 失败'); }
                renderQa(res.data);
            }).catch(function (e) {
                showMsg(qaMsg, e.message || e, true);
            });
    }

    function renderQa(items) {
        qaListBox.innerHTML = '';
        if (!items.length) {
            qaListBox.innerHTML = '<div style="color:#9ca3af;">暂无 QA 数据</div>';
            return;
        }
        items.forEach(function (it) {
            var div = document.createElement('div');
            div.className = 'list-item';
            var qid = it.questionId || '';
            div.innerHTML = '' +
                '<label style="margin-bottom:0;cursor:pointer;">' +
                '<input type="checkbox" class="qa-check" value="' + esc(qid) + '" style="margin-right:0.4rem;" />' +
                '<span style="font-weight:600;color:#0f172a;">' + esc(it.title || '') + '</span>' +
                '<span style="margin-left:0.45rem;color:#64748b;font-size:0.8rem;">QID: ' + esc(qid) + '</span>' +
                '</label>';
            qaListBox.appendChild(div);
        });
    }

    function selectedQaIds() {
        var list = [];
        qaListBox.querySelectorAll('.qa-check:checked').forEach(function (c) { list.push(c.value); });
        return list;
    }

    function startPolling() {
        stopPolling();
        pollTimer = setInterval(fetchProgress, 2000);
    }

    function stopPolling() {
        if (pollTimer) {
            clearInterval(pollTimer);
            pollTimer = null;
        }
    }

    function fetchProgress() {
        if (!currentBatchId) { return; }
        fetch('${pageContext.request.contextPath}/api/batch/progress?batchId=' + encodeURIComponent(currentBatchId))
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) { throw new Error(res.message || '读取进度失败'); }
                renderProgress(res.data);
                handleReviewModal(res.data);
                handleCompletion(res.data);
            }).catch(function (e) {
                showMsg(batchMsg, e.message || e, true);
                stopPolling();
            });
    }

    function renderProgress(data) {
        var tasks = data.tasks || [];
        progressBody.innerHTML = '';
        if (!tasks.length) {
            progressBody.innerHTML = '<tr><td colspan="6" style="color:#9ca3af;">暂无任务</td></tr>';
            return;
        }

        tasks.forEach(function (t, idx) {
            var tr = document.createElement('tr');
            tr.innerHTML = '' +
                '<td>' + (idx + 1) + '</td>' +
                '<td>' + esc(t.title || '') + '</td>' +
                '<td>' + esc(statusText(t.status || '')) + '</td>' +
                '<td>' + esc(t.progress) + '%</td>' +
                '<td class="mono">' + esc(t.outputPath || '') + '</td>' +
                '<td>' + esc(t.errorMessage || '') + '</td>';
            progressBody.appendChild(tr);
        });

        showMsg(batchMsg,
            '批次进度：' + (data.overallProgress || 0) + '%，成功 ' + (data.successCount || 0) + '，失败 ' + (data.failedCount || 0), false);
    }

    function handleReviewModal(data) {
        if ((data.runMode || '').toLowerCase() !== 'manual') {
            return;
        }
        var tasks = data.tasks || [];
        var needReview = tasks.filter(function (t) { return t.status === 'SCRIPT_REVIEW_PENDING'; });
        if (!needReview.length) {
            return;
        }

        if (reviewRenderedBatchId !== currentBatchId) {
            reviewOriginalMap = {};
            reviewRenderedBatchId = currentBatchId;
        }

        reviewModalList.innerHTML = '';
        needReview.forEach(function (t, idx) {
            reviewOriginalMap[t.taskId] = t.scriptDraft || '';
            var wrap = document.createElement('div');
            wrap.className = 'review-item';
            wrap.innerHTML = '' +
                '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.4rem;gap:0.8rem;">' +
                '<div style="font-size:0.9rem;font-weight:600;color:#0f172a;">任务 ' + (idx + 1) + '：' + esc(t.title || '') + '</div>' +
                '<button type="button" class="btn" data-restore-taskid="' + esc(t.taskId || '') + '">恢复原脚本</button>' +
                '</div>' +
                '<textarea class="review-script" data-taskid="' + esc(t.taskId || '') + '" style="min-height:160px;">' + esc(t.scriptDraft || '') + '</textarea>';
            reviewModalList.appendChild(wrap);
        });

        reviewModalList.querySelectorAll('button[data-restore-taskid]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var taskId = btn.getAttribute('data-restore-taskid') || '';
                var ta = reviewModalList.querySelector('textarea.review-script[data-taskid="' + taskId + '"]');
                if (ta) {
                    ta.value = reviewOriginalMap[taskId] || '';
                }
            });
        });

        reviewModal.style.display = 'flex';
    }

    function handleCompletion(data) {
        var tasks = data.tasks || [];
        if (!tasks.length || completedBatchNoticeShown) {
            return;
        }
        var done = tasks.every(function (t) {
            return t.status === 'SUCCESS' || t.status === 'FAILED' || t.status === 'CANCELLED';
        });
        if (!done) {
            return;
        }

        completedBatchNoticeShown = true;
        stopPolling();
        summaryText.innerHTML = '' +
            '批次 ID：<span class="mono">' + esc(data.batchId || '') + '</span><br/>' +
            '总任务数：' + esc(data.taskCount || 0) + '<br/>' +
            '成功：' + esc(data.successCount || 0) + '<br/>' +
            '失败：' + esc(data.failedCount || 0) + '<br/>' +
            '已取消：' + esc(data.cancelledCount || 0);
        summaryModal.style.display = 'flex';
    }

    document.getElementById('loadQaBtn').addEventListener('click', loadQa);
    document.getElementById('selectAllBtn').addEventListener('click', function(){
        qaListBox.querySelectorAll('.qa-check').forEach(function(c){ c.checked = true; });
    });
    document.getElementById('invertBtn').addEventListener('click', function(){
        qaListBox.querySelectorAll('.qa-check').forEach(function(c){ c.checked = !c.checked; });
    });

    document.getElementById('startInitBtn').addEventListener('click', function () {
        hideMsg(setupMsg);
        var fileName = (templateSelect.value || '').trim();
        if (!fileName) {
            showMsg(setupMsg, '请先选择模板。', true);
            return;
        }
        setupModal.style.display = 'none';
        currentTplInfo.textContent = '当前模板：' + fileName;
        currentModeInfo.textContent = '批量模式：' + (runModeSelect.value === 'manual' ? '人工审查' : '全自动');
        loadQa();
    });

    document.getElementById('createBatchBtn').addEventListener('click', function () {
        hideMsg(batchMsg);
        var fileName = (templateSelect.value || '').trim();
        if (!fileName) {
            showMsg(batchMsg, '请先选择模板。', true);
            return;
        }
        var ids = selectedQaIds();
        if (!ids.length) {
            showMsg(batchMsg, '请至少选择一条 QA。', true);
            return;
        }

        completedBatchNoticeShown = false;
        reviewRenderedBatchId = '';
        reviewOriginalMap = {};

        fetch('${pageContext.request.contextPath}/api/batch/create', {
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({
                templateFileName: fileName,
                runMode: runModeSelect.value,
                qaIds: ids
            })
        }).then(function(r){ return r.json(); })
            .then(function(res){
                if (res.code !== 200 || !res.data) { throw new Error(res.message || '创建批次失败'); }
                currentBatchId = res.data.batchId || '';
                showMsg(batchMsg, '批次已创建：' + currentBatchId, false);
                fetchProgress();
                startPolling();
            }).catch(function(e){ showMsg(batchMsg, e.message || e, true); });
    });

    document.getElementById('cancelBatchBtn').addEventListener('click', function () {
        if (!currentBatchId) {
            showMsg(batchMsg, '当前没有可取消的批次。', true);
            return;
        }
        fetch('${pageContext.request.contextPath}/api/batch/cancel?batchId=' + encodeURIComponent(currentBatchId), {
            method: 'POST'
        }).then(function(r){ return r.json(); })
            .then(function(res){
                if (res.code !== 200) { throw new Error(res.message || '取消失败'); }
                showMsg(batchMsg, '批次已取消（未执行任务会被取消）。', false);
                fetchProgress();
            }).catch(function(e){ showMsg(batchMsg, e.message || e, true); });
    });

    document.getElementById('confirmReviewBtn').addEventListener('click', function () {
        if (!currentBatchId) {
            showMsg(reviewMsg, '批次不存在。', true);
            return;
        }
        hideMsg(reviewMsg);
        var scripts = [];
        reviewModalList.querySelectorAll('textarea.review-script').forEach(function (ta) {
            scripts.push({
                taskId: ta.getAttribute('data-taskid') || '',
                templateText: ta.value || ''
            });
        });

        fetch('${pageContext.request.contextPath}/api/batch/review/confirm', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ batchId: currentBatchId, scripts: scripts })
        }).then(function(r){ return r.json(); })
            .then(function(res){
                if (res.code !== 200) { throw new Error(res.message || '提交失败'); }
                reviewModal.style.display = 'none';
                showMsg(batchMsg, '人工审查脚本已提交，任务开始生成视频。', false);
                fetchProgress();
                startPolling();
            }).catch(function(e){ showMsg(reviewMsg, e.message || e, true); });
    });

    document.getElementById('closeReviewBtn').addEventListener('click', function () {
        reviewModal.style.display = 'none';
    });

    document.getElementById('summaryOkBtn').addEventListener('click', function () {
        summaryModal.style.display = 'none';
    });

    loadTemplates();
})();
</script>
</body>
</html>
