<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

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
            position: sticky;
            top: 0;
            align-self: flex-start;
            height: 100vh;
            overflow-y: auto;
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
        }

        .main-header {
            margin-bottom: 1rem;
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

        .row {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .col {
            flex: 1 1 420px;
        }

        .row-equal {
            align-items: stretch;
        }

        .list-col,
        .right-col {
            display: flex;
            flex-direction: column;
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

        .row-equal .card {
            margin-bottom: 0;
        }

        .list-card {
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 760px;
        }

        .list-card .table-wrap {
            flex: 1;
            min-height: 0;
            max-height: none;
        }

        .right-stack {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            min-height: 760px;
        }

        .right-stack .card {
            flex: 1;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .card h2 {
            font-size: 1.02rem;
            color: var(--text-main);
            font-weight: 600;
            margin-bottom: 0.75rem;
        }

        .sub {
            color: var(--text-sub);
            font-size: 0.9rem;
            margin-bottom: 0.9rem;
        }

        label {
            display: block;
            margin-bottom: 0.35rem;
            color: var(--text-sub);
            font-size: 0.9rem;
        }

        input[type="text"], textarea, select {
            width: 100%;
            padding: 0.5rem 0.75rem;
            margin-bottom: 0.9rem;
            border-radius: 8px;
            border: 1px solid rgba(203,213,225,0.95);
            background: rgba(255,255,255,0.9);
            color: #0f172a;
            font-size: 0.95rem;
        }

        textarea {
            min-height: 180px;
            resize: vertical;
        }

        .btn {
            display: inline-block;
            padding: 0.55rem 1.15rem;
            background: rgba(255,255,255,0.95);
            color: #111827;
            font-weight: 600;
            border: 1px solid rgba(203,213,225,0.95);
            border-radius: 10px;
            cursor: pointer;
            font-size: 0.88rem;
            transition: transform 0.18s ease-out, box-shadow 0.18s ease-out, background-color 0.18s ease-out, color 0.18s ease-out;
            margin-right: 0.45rem;
            margin-bottom: 0.45rem;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(15,23,42,0.12);
            background: #f9fafb;
        }

        .btn-danger {
            background: #fef2f2;
            color: #991b1b;
            border-color: #fecaca;
        }

        .btn-danger:hover {
            background: #fee2e2;
        }

        .msg {
            margin-top: 0.5rem;
            font-size: 0.85rem;
            display: none;
        }

        .msg.err {
            color: #b91c1c;
        }

        .msg.ok {
            color: #166534;
        }

        .table-wrap {
            border: 1px solid rgba(203,213,225,0.95);
            border-radius: 10px;
            overflow: auto;
        }

        .list-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-bottom: 0.25rem;
        }

        .list-actions .btn {
            margin: 0;
            min-width: 120px;
            padding: 0.45rem 0.9rem;
        }

        .hot-list {
            margin-top: 0.75rem;
            border: 1px solid rgba(203,213,225,0.95);
            border-radius: 10px;
            padding: 0.5rem 0.65rem;
            overflow: auto;
            flex: 1;
            min-height: 180px;
            background: rgba(255,255,255,0.82);
        }

        .hot-item {
            border-bottom: 1px solid rgba(226,232,240,0.95);
            padding: 0.4rem 0;
        }

        .hot-item:last-child {
            border-bottom: none;
        }

        .hot-title {
            color: #0f172a;
            font-size: 0.88rem;
            cursor: pointer;
        }

        .hot-body {
            margin-top: 0.3rem;
            color: #334155;
            font-size: 0.82rem;
            line-height: 1.5;
            display: none;
            white-space: pre-wrap;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 760px;
        }

        th, td {
            padding: 0.55rem 0.65rem;
            border-bottom: 1px solid rgba(226,232,240,0.95);
            text-align: left;
            vertical-align: top;
            font-size: 0.86rem;
            color: #0f172a;
        }

        th {
            position: sticky;
            top: 0;
            background: rgba(248,250,252,0.95);
            z-index: 2;
            color: #334155;
        }

        .mono {
            font-family: Consolas, "Courier New", monospace;
        }

        .title-cell {
            max-width: 420px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .op-cell {
            white-space: nowrap;
        }

        .op-actions {
            display: flex;
            align-items: center;
            gap: 0.35rem;
            flex-wrap: nowrap;
        }

        .op-actions .btn {
            margin: 0;
            padding: 0.38rem 0.8rem;
            font-size: 0.82rem;
            line-height: 1.1;
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
                padding: 0.35rem 0.7rem;
                font-size: 0.8rem;
                border-radius: 8px;
            }

            .main {
                padding: 1.25rem 1.25rem 1.75rem;
            }

            table {
                min-width: 680px;
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
                <a href="${pageContext.request.contextPath}/" class="nav-link"><span>首页</span></a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link"><span>跑酷生成仪表盘</span></a>
                <a href="${pageContext.request.contextPath}/zhihu"
                   class="nav-link nav-link-active"><span>QA 文本管理</span></a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link"><span>管理模板</span></a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link"><span>批量创建视频</span></a>
                     <a href="${pageContext.request.contextPath}/biliup-upload" class="nav-link"><span>上传至B站视频</span></a>
                <a href="${pageContext.request.contextPath}/video-manage" class="nav-link"><span>视频管理</span></a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link"><span>接口与合成测试</span></a>
            </div>
        </div>
        <div class="nav-footer">
            <div>管理文件：runtime-data/QA.txt</div>
        </div>
    </aside>

    <main class="main">
        <div class="main-header">
            <div class="main-title">QA 文本管理页面</div>
            <div class="main-subtitle">支持对 runtime-data/QA.txt 进行增删改查，并支持按 index 与 title 模糊搜索。</div>
        </div>

        <div class="row row-equal">
            <div class="col list-col" style="flex: 7 1 0;">
                <div class="card list-card">
                    <h2>列表与检索</h2>
                    <p class="sub">输入关键词后点击“搜索”。关键词将匹配 index 和标题 title。</p>
                    <label>关键词（index / title 模糊搜索）</label>
                    <input type="text" id="keywordInput" placeholder="例如：12 或 代表建议"/>
                    <div class="list-actions">
                        <button type="button" class="btn" id="searchBtn">搜索</button>
                        <button type="button" class="btn" id="resetBtn">重置</button>
                        <button type="button" class="btn" id="refreshBtn">刷新列表</button>
                    </div>
                    <div id="listMsg" class="msg"></div>

                    <div class="table-wrap" style="margin-top:0.75rem;">
                        <table>
                            <thead>
                            <tr>
                                <th style="width:70px;">Index</th>
                                <th style="width:190px;">QuestionId</th>
                                <th>Title</th>
                                <th style="width:110px;">Bookmarked</th>
                                <th style="width:180px;">操作</th>
                            </tr>
                            </thead>
                            <tbody id="qaTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col right-col" style="flex: 5 1 0;">
                <div class="right-stack">
                    <div class="card">
                        <h2>编辑区</h2>
                        <p class="sub">可新增一条，也可先在左侧点“编辑”后更新指定 index。</p>

                        <label>Index（更新/删除时使用）</label>
                        <input type="text" id="formIndex" placeholder="例如：3"/>

                        <label>QuestionId</label>
                        <input type="text" id="formQuestionId" placeholder="例如：2015450640051040494"/>

                        <label>Title</label>
                        <input type="text" id="formTitle" placeholder="请输入标题"/>

                        <label>Bookmarked</label>
                        <select id="formBookmarked">
                            <option value="false" selected>false</option>
                            <option value="true">true</option>
                        </select>

                        <label>AnswerContent</label>
                        <textarea id="formAnswerContent" placeholder="请输入回答内容（可为 HTML）"></textarea>

                        <button type="button" class="btn" id="createBtn">新增</button>
                        <button type="button" class="btn" id="updateBtn">更新</button>
                        <button type="button" class="btn btn-danger" id="deleteBtn">删除</button>
                        <button type="button" class="btn" id="clearBtn">清空表单</button>

                        <div id="formMsg" class="msg"></div>
                    </div>

                    <div class="card">
                        <h2>知乎热榜抓取（questionId + 最高赞回答）</h2>
                        <p class="sub">输入知乎 Cookie 后抓取热榜前 10 条并写入
                            runtime-data/QA.txt；抓取成功后会自动刷新左侧列表。</p>
                        <label>知乎 Cookie（必填）</label>
                        <textarea id="zhihuHotCookie" placeholder="请粘贴你在知乎网页中复制的完整 Cookie"
                                  style="min-height:110px;"></textarea>
                        <button type="button" class="btn" id="fetchHotQaBtn">抓取知乎热榜前 10 条问答</button>
                        <div id="hotQaMsg" class="msg"></div>
                        <div id="hotQaList" class="hot-list"></div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    (function () {
        var keywordInput = document.getElementById('keywordInput');
        var searchBtn = document.getElementById('searchBtn');
        var resetBtn = document.getElementById('resetBtn');
        var refreshBtn = document.getElementById('refreshBtn');
        var qaTableBody = document.getElementById('qaTableBody');
        var listMsg = document.getElementById('listMsg');

        var formIndex = document.getElementById('formIndex');
        var formQuestionId = document.getElementById('formQuestionId');
        var formTitle = document.getElementById('formTitle');
        var formBookmarked = document.getElementById('formBookmarked');
        var formAnswerContent = document.getElementById('formAnswerContent');
        var formMsg = document.getElementById('formMsg');
        var hotBtn = document.getElementById('fetchHotQaBtn');
        var hotMsg = document.getElementById('hotQaMsg');
        var hotList = document.getElementById('hotQaList');
        var cookieInput = document.getElementById('zhihuHotCookie');

        var createBtn = document.getElementById('createBtn');
        var updateBtn = document.getElementById('updateBtn');
        var deleteBtn = document.getElementById('deleteBtn');
        var clearBtn = document.getElementById('clearBtn');

        function showMsg(el, text, isErr) {
            el.textContent = text;
            el.className = 'msg ' + (isErr ? 'err' : 'ok');
            el.style.display = 'block';
        }

        function hideMsg(el) {
            el.style.display = 'none';
        }

        function escapeHtml(str) {
            if (str == null) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function fillForm(item) {
            formIndex.value = item.index || '';
            formQuestionId.value = item.questionId || '';
            formTitle.value = item.title || '';
            formBookmarked.value = (String(item.bookmarked || 'false').toLowerCase() === 'true') ? 'true' : 'false';
            formAnswerContent.value = item.answerContent || '';
            showMsg(formMsg, '已加载 index=' + (item.index || '') + ' 到编辑区。', false);
        }

        function renderTable(items) {
            qaTableBody.innerHTML = '';
            if (!items || !items.length) {
                qaTableBody.innerHTML = '<tr><td colspan="5" style="color:#9ca3af;">暂无数据</td></tr>';
                return;
            }
            items.forEach(function (item) {
                var tr = document.createElement('tr');
                var titleText = item.title || '';
                tr.innerHTML = '' +
                    '<td class="mono">' + escapeHtml(item.index || '') + '</td>' +
                    '<td class="mono">' + escapeHtml(item.questionId || '') + '</td>' +
                    '<td class="title-cell" title="' + escapeHtml(titleText) + '">' + escapeHtml(titleText) + '</td>' +
                    '<td>' + escapeHtml(item.bookmarked || 'false') + '</td>' +
                    '<td class="op-cell">' +
                    '  <div class="op-actions">' +
                    '    <button type="button" class="btn" data-action="edit">编辑</button>' +
                    '    <button type="button" class="btn btn-danger" data-action="delete">删除</button>' +
                    '  </div>' +
                    '</td>';

                var editBtn = tr.querySelector('button[data-action="edit"]');
                var delBtn = tr.querySelector('button[data-action="delete"]');

                editBtn.addEventListener('click', function () {
                    fillForm(item);
                });
                delBtn.addEventListener('click', function () {
                    doDelete(item.index);
                });
                qaTableBody.appendChild(tr);
            });
        }

        function doFetchList() {
            hideMsg(listMsg);
            var keyword = (keywordInput.value || '').trim();
            var url = '${pageContext.request.contextPath}/api/zhihu/qa/list';
            if (keyword) {
                url += '?keyword=' + encodeURIComponent(keyword);
            }
            fetch(url, {method: 'GET'})
                .then(function (r) {
                    return r.json();
                })
                .then(function (res) {
                    if (res.code === 200 && res.data) {
                        renderTable(res.data);
                        showMsg(listMsg, '已加载 ' + res.data.length + ' 条记录。', false);
                    } else {
                        renderTable([]);
                        showMsg(listMsg, res.message || '加载失败。', true);
                    }
                })
                .catch(function (err) {
                    renderTable([]);
                    showMsg(listMsg, '请求失败：' + (err.message || err), true);
                });
        }

        function collectFormData() {
            return {
                index: (formIndex.value || '').trim(),
                questionId: (formQuestionId.value || '').trim(),
                title: (formTitle.value || '').trim(),
                bookmarked: (formBookmarked.value || 'false').trim(),
                answerContent: (formAnswerContent.value || '').trim()
            };
        }

        function toFormBody(obj) {
            var body = new URLSearchParams();
            Object.keys(obj).forEach(function (k) {
                if (obj[k] != null) {
                    body.append(k, obj[k]);
                }
            });
            return body;
        }

        function doCreate() {
            hideMsg(formMsg);
            var data = collectFormData();
            fetch('${pageContext.request.contextPath}/api/zhihu/qa/create', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
                body: toFormBody({
                    questionId: data.questionId,
                    title: data.title,
                    bookmarked: data.bookmarked,
                    answerContent: data.answerContent
                }).toString()
            })
                .then(function (r) {
                    return r.json();
                })
                .then(function (res) {
                    if (res.code === 200) {
                        showMsg(formMsg, '新增成功。', false);
                        doFetchList();
                    } else {
                        showMsg(formMsg, res.message || '新增失败。', true);
                    }
                })
                .catch(function (err) {
                    showMsg(formMsg, '请求失败：' + (err.message || err), true);
                });
        }

        function doUpdate() {
            hideMsg(formMsg);
            var data = collectFormData();
            if (!data.index) {
                showMsg(formMsg, '请先填写 index（或从左侧点击“编辑”自动带入）。', true);
                return;
            }
            fetch('${pageContext.request.contextPath}/api/zhihu/qa/update', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
                body: toFormBody(data).toString()
            })
                .then(function (r) {
                    return r.json();
                })
                .then(function (res) {
                    if (res.code === 200) {
                        showMsg(formMsg, '更新成功。', false);
                        doFetchList();
                    } else {
                        showMsg(formMsg, res.message || '更新失败。', true);
                    }
                })
                .catch(function (err) {
                    showMsg(formMsg, '请求失败：' + (err.message || err), true);
                });
        }

        function doDelete(index) {
            hideMsg(formMsg);
            if (!index) {
                index = (formIndex.value || '').trim();
            }
            if (!index) {
                showMsg(formMsg, '请先填写 index（或使用列表中的删除按钮）。', true);
                return;
            }
            if (!window.confirm('确认删除 index=' + index + ' 这条记录吗？')) {
                return;
            }
            fetch('${pageContext.request.contextPath}/api/zhihu/qa/delete', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
                body: toFormBody({index: index}).toString()
            })
                .then(function (r) {
                    return r.json();
                })
                .then(function (res) {
                    if (res.code === 200) {
                        showMsg(formMsg, '删除成功。', false);
                        doFetchList();
                    } else {
                        showMsg(formMsg, res.message || '删除失败。', true);
                    }
                })
                .catch(function (err) {
                    showMsg(formMsg, '请求失败：' + (err.message || err), true);
                });
        }

        function clearForm() {
            formIndex.value = '';
            formQuestionId.value = '';
            formTitle.value = '';
            formBookmarked.value = 'false';
            formAnswerContent.value = '';
            hideMsg(formMsg);
        }

        function renderHotList(items) {
            hotList.innerHTML = '';
            if (!items || !items.length) {
                hotList.innerHTML = '<div style="color:#9ca3af;font-size:0.84rem;">暂无新增数据。</div>';
                return;
            }
            items.forEach(function (item, idx) {
                var wrap = document.createElement('div');
                wrap.className = 'hot-item';
                var title = document.createElement('div');
                title.className = 'hot-title';
                title.textContent = (idx + 1) + '. ' + (item.title || ('问题 ' + (item.questionId || '')));

                var body = document.createElement('div');
                body.className = 'hot-body';
                var raw = item.answerContent || '';
                var tmp = document.createElement('div');
                tmp.innerHTML = raw;
                body.textContent = tmp.innerText || tmp.textContent || raw;

                title.addEventListener('click', function () {
                    body.style.display = body.style.display === 'none' ? 'block' : 'none';
                });

                wrap.appendChild(title);
                wrap.appendChild(body);
                hotList.appendChild(wrap);
            });
        }

        function doFetchHotQa() {
            hideMsg(hotMsg);
            hotList.innerHTML = '';
            var cookie = (cookieInput && cookieInput.value ? cookieInput.value.trim() : '');
            if (!cookie) {
                showMsg(hotMsg, '请先粘贴知乎 Cookie。', true);
                return;
            }
            hotBtn.disabled = true;
            showMsg(hotMsg, '正在抓取知乎热榜并写入 QA.txt，请稍候……', false);

            fetch('${pageContext.request.contextPath}/api/zhihu/hot-qa', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
                body: 'cookie=' + encodeURIComponent(cookie)
            })
                .then(function (r) {
                    return r.json();
                })
                .then(function (res) {
                    if (res.code === 200) {
                        renderHotList(res.data || []);
                        showMsg(hotMsg, '抓取完成，新增 ' + ((res.data && res.data.length) ? res.data.length : 0) + ' 条。', false);
                        doFetchList();
                    } else {
                        showMsg(hotMsg, res.message || '抓取失败。', true);
                    }
                })
                .catch(function (err) {
                    showMsg(hotMsg, '请求失败：' + (err.message || err), true);
                })
                .finally(function () {
                    hotBtn.disabled = false;
                });
        }

        searchBtn.addEventListener('click', doFetchList);
        refreshBtn.addEventListener('click', doFetchList);
        resetBtn.addEventListener('click', function () {
            keywordInput.value = '';
            doFetchList();
        });
        createBtn.addEventListener('click', doCreate);
        updateBtn.addEventListener('click', doUpdate);
        deleteBtn.addEventListener('click', function () {
            doDelete();
        });
        clearBtn.addEventListener('click', clearForm);
        if (hotBtn) {
            hotBtn.addEventListener('click', doFetchHotQa);
        }

        keywordInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                doFetchList();
            }
        });

        doFetchList();
    })();
</script>
</body>
</html>

