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
            --panel-bg: rgba(255, 255, 255, 0.68);
            --panel-border: rgba(255,255,255,0.5);
            --text-main:#0f172a;
            --text-sub:#475569;
            --shadow-soft: 0 18px 45px rgba(15, 23, 42, 0.15);
        }
        body {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            min-height:100vh;
            color:var(--text-main);
            background: url('${pageContext.request.contextPath}/api/background/current') center center / cover no-repeat fixed;
        }
        .app-layout { display:flex; min-height:100vh; background: transparent; }
        .sidebar {
            width:240px;
            padding:1.5rem 1.1rem;
            background: rgba(236, 244, 255, 0.72);
            border-right:1px solid rgba(255,255,255,0.55);
            display:flex;
            flex-direction:column;
            gap:1.5rem;
            backdrop-filter: blur(12px);
            box-shadow: 8px 0 30px rgba(15, 23, 42, 0.08);
            position:sticky;
            top:0;
            align-self:flex-start;
            height:100vh;
            overflow-y:auto;
        }
        .sidebar-header { display:flex; align-items:center; gap:0.75rem; }
        .sidebar-logo { width:32px; height:32px; border-radius:999px; background: radial-gradient(circle at 30% 30%, #38bdf8, #6366f1); }
        .sidebar-title { font-size:1rem; font-weight:700; color:#0f172a; }
        .nav-section-title { font-size:0.75rem; color:#475569; letter-spacing:0.08em; margin-bottom:0.25rem; }
        .nav-group { display:flex; flex-direction:column; gap:0.3rem; }
        .nav-link { display:flex; align-items:center; gap:0.5rem; padding:0.5rem 0.75rem; border-radius:10px; color:#1e293b; font-weight:600; text-decoration:none; font-size:0.88rem; transition:all 0.2s; }
        .nav-link:hover { background: rgba(255,255,255,0.65); transform: translateX(2px); }
        .nav-link-active { background: rgba(255,255,255,0.9); color:#111827; box-shadow: 0 6px 18px rgba(15, 23, 42, 0.12); }
        .nav-footer { margin-top:auto; font-size:0.75rem; color:#334155; line-height:1.5; }
        .main { flex:1; padding:1.6rem 1.8rem; display:flex; flex-direction:column; gap:1rem; }
        .main-header { background: var(--panel-bg); border: 1px solid var(--panel-border); border-radius:14px; padding:1rem 1.25rem; backdrop-filter: blur(10px); box-shadow: var(--shadow-soft); }
        .main-title { font-size:1.25rem; font-weight:700; color:var(--text-main); }
        .main-subtitle { margin-top:0.35rem; color:var(--text-sub); font-size:0.9rem; }
        .row { display:flex; flex-wrap:wrap; gap:1rem; align-items:stretch; }
        .col { flex:1 1 420px; display:flex; }
        .card {
            background: var(--panel-bg);
            border-radius:16px;
            border:1px solid var(--panel-border);
            box-shadow: var(--shadow-soft);
            backdrop-filter: blur(12px);
            padding:1.2rem 1.25rem;
            display:flex;
            flex-direction:column;
            flex:1;
            min-height:760px;
        }
        .card h2 { font-size:1.02rem; color:var(--text-main); margin-bottom:0.75rem; }
        .section-title {
            font-size:0.94rem;
            color:#0f172a;
            font-weight:700;
            margin-top:0.45rem;
            margin-bottom:0.55rem;
            padding-bottom:0.3rem;
            border-bottom:1px dashed rgba(148,163,184,0.45);
        }
        .sub { color:var(--text-sub); font-size:0.9rem; margin-bottom:0.7rem; }
        label { display:block; margin-bottom:0.32rem; color:var(--text-sub); font-size:0.86rem; }
        input[type="text"], input[type="number"], textarea, select {
            width:100%;
            padding:0.45rem 0.65rem;
            margin-bottom:0.7rem;
            border-radius:8px;
            border:1px solid rgba(203,213,225,0.95);
            background: rgba(255,255,255,0.9);
            color:#0f172a;
            font-size:0.9rem;
        }
        textarea { min-height:80px; resize:vertical; }
        .btn {
            padding:0.42rem 0.85rem;
            background:rgba(255,255,255,0.95);
            color:#111827;
            border:1px solid rgba(203,213,225,0.95);
            border-radius:9px;
            font-size:0.83rem;
            font-weight:600;
            cursor:pointer;
            margin-right:0.35rem;
            margin-bottom:0.35rem;
        }
        .btn:hover { background:#f8fafc; }
        .btn-danger { background:#fef2f2; color:#991b1b; border-color:#fecaca; }
        .msg { margin-top:0.4rem; font-size:0.83rem; display:none; }
        .msg.err { color:#b91c1c; }
        .msg.ok { color:#166534; }
        .table-wrap {
            margin-top:0.65rem;
            border:1px solid rgba(203,213,225,0.95);
            border-radius:10px;
            overflow:auto;
            flex:1;
            min-height:0;
            background: rgba(255,255,255,0.86);
        }
        table { width:100%; border-collapse: collapse; min-width:640px; }
        th, td { padding:0.5rem 0.6rem; border-bottom:1px solid rgba(226,232,240,0.95); text-align:left; color:#0f172a; font-size:0.82rem; }
        th { position:sticky; top:0; background: rgba(248,250,252,0.95); color:#334155; z-index:2; }
        .mono { font-family: Consolas, "Courier New", monospace; }
        .grid-2 { display:grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap:0.65rem; }
        .grid-3 { display:grid; grid-template-columns: repeat(3,minmax(0,1fr)); gap:0.65rem; }
        .field-box { background:rgba(255,255,255,0.75); border:1px solid rgba(226,232,240,0.9); border-radius:10px; padding:0.55rem; }
        .field-actions { margin-top:-0.2rem; margin-bottom:0.55rem; }
        .preview-wrap {
            margin-top:0.55rem;
            border:1px solid rgba(203,213,225,0.95);
            border-radius:10px;
            padding:0.7rem;
            background:rgba(255,255,255,0.86);
        }
        @media (max-width: 1200px) {
            .grid-3 { grid-template-columns: repeat(2,minmax(0,1fr)); }
        }
        @media (max-width: 900px) {
            .app-layout { flex-direction: column; }
            .sidebar {
                width:100%;
                height:auto;
                position:static;
            }
            .grid-2, .grid-3 { grid-template-columns: repeat(1,minmax(0,1fr)); }
        }
    </style>
</head>
<body>
<div class="app-layout">
    <aside class="sidebar">
        <div class="sidebar-header"><div class="sidebar-logo"></div><div class="sidebar-title">B 站 AI 对话视频</div></div>
        <div>
            <div class="nav-section-title">导航</div>
            <div class="nav-group">
                <a href="${pageContext.request.contextPath}/" class="nav-link"><span>首页</span></a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link"><span>仪表盘创作</span></a>
                <a href="${pageContext.request.contextPath}/zhihu" class="nav-link"><span>QA 文本管理</span></a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link nav-link-active"><span>管理模板</span></a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link"><span>批量创建视频</span></a>
                <a href="${pageContext.request.contextPath}/video-manage" class="nav-link"><span>视频管理</span></a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link"><span>接口测试</span></a>
            </div>
        </div>
        <div class="nav-footer">
            <div>模板目录：runtime-data/style</div>
            <div>素材目录：runtime-data/videos、runtime-data/sounds、runtime-data/images</div>
        </div>
    </aside>

    <main class="main">
        <div class="main-header">
            <div class="main-title">模板管理页面</div>
            <div class="main-subtitle">模板改为可输入/可选择编辑；素材路径支持按钮上传到 runtime-data 后自动回填。</div>
        </div>

        <div class="row">
            <div class="col" style="flex: 3 1 0;">
                <div class="card">
                    <h2>模板列表</h2>
                    <p class="sub">点击加载会把模板内容完整填充到右侧表单。</p>
                    <div>
                        <button type="button" id="refreshBtn" class="btn">刷新列表</button>
                    </div>
                    <div id="listMsg" class="msg"></div>
                    <div class="table-wrap">
                        <table>
                            <thead><tr><th>模板名</th><th>文件名</th><th>更新时间</th><th>操作</th></tr></thead>
                            <tbody id="tplTableBody"><tr><td colspan="4" style="color:#9ca3af;">加载中...</td></tr></tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col" style="flex: 7 1 0;">
                <div class="card" style="overflow:auto;">
                    <h2>模板编辑区</h2>
                    <p class="sub">每个参数都可直接编辑，素材路径可通过按钮上传并自动填写。</p>

                    <label>当前文件名（更新/删除时使用）</label>
                    <input type="text" id="fileNameInput" placeholder="例如：双人科普_20260422_101500.json" />

                    <div class="section-title">基础参数</div>
                    <div class="grid-2">
                        <div class="field-box">
                            <label>模板名称</label>
                            <input type="text" id="templateName" />
                        </div>
                        <div class="field-box">
                            <label>模式</label>
                            <select id="mode">
                                <option value="single">single（单人）</option>
                                <option value="double">double（双人）</option>
                            </select>
                        </div>
                        <div class="field-box">
                            <label>角色A 人设</label>
                            <input type="text" id="roleAPersona" />
                        </div>
                        <div class="field-box">
                            <label>角色B 人设</label>
                            <input type="text" id="roleBPersona" />
                        </div>
                        <div class="field-box">
                            <label>目标字数</label>
                            <input type="number" id="targetWordCount" min="100" max="5000" />
                        </div>
                        <div class="field-box">
                            <label>背景音乐音量（0-1）</label>
                            <input type="number" id="bgmVolume" min="0" max="1" step="0.05" />
                        </div>
                    </div>
                    <div class="field-box" style="margin-top:0.65rem;">
                        <label>指令控制</label>
                        <textarea id="instruction" style="min-height:64px;"></textarea>
                        <label><input type="checkbox" id="exportPortrait" /> 导出竖屏（1080x1920）</label>
                    </div>

                    <div class="section-title">素材路径（点击按钮上传并自动填入路径）</div>
                    <div class="grid-2">
                        <div class="field-box">
                            <label>跑酷视频路径（videoPath）</label>
                            <input type="text" id="videoPath" />
                            <div class="field-actions"><button type="button" class="btn" id="uploadVideoBtn">上传视频并填入</button></div>
                        </div>
                        <div class="field-box">
                            <label>角色A 训练音频路径（audioRoleAPath）</label>
                            <input type="text" id="audioRoleAPath" />
                            <div class="field-actions"><button type="button" class="btn" id="uploadAudioRoleABtn">上传音频并填入</button></div>
                        </div>
                        <div class="field-box">
                            <label>角色B 训练音频路径（audioRoleBPath）</label>
                            <input type="text" id="audioRoleBPath" />
                            <div class="field-actions"><button type="button" class="btn" id="uploadAudioRoleBBtn">上传音频并填入</button></div>
                        </div>
                        <div class="field-box">
                            <label>背景音乐路径（bgmPath）</label>
                            <input type="text" id="bgmPath" />
                            <div class="field-actions"><button type="button" class="btn" id="uploadBgmBtn">上传 BGM 并填入</button></div>
                        </div>
                    </div>

                    <div class="grid-2" style="margin-top:0.65rem;">
                        <div class="field-box">
                            <label>角色A 立绘路径列表（每行一个）</label>
                            <textarea id="roleAImagePaths" style="min-height:84px;"></textarea>
                            <div class="field-actions"><button type="button" class="btn" id="uploadRoleAImagesBtn">上传角色A立绘并追加</button></div>
                        </div>
                        <div class="field-box">
                            <label>角色B 立绘路径列表（每行一个）</label>
                            <textarea id="roleBImagePaths" style="min-height:84px;"></textarea>
                            <div class="field-actions"><button type="button" class="btn" id="uploadRoleBImagesBtn">上传角色B立绘并追加</button></div>
                        </div>
                    </div>
                    <div id="assetMsg" class="msg"></div>

                    <div class="section-title">字幕预览与样式参数（效果模仿 bashboard）</div>
                    <div class="preview-wrap">
                        <div class="grid-2">
                            <div>
                                <label>示例字幕文本</label>
                                <textarea id="subtitleSampleText" style="min-height:96px;">角色A：今天天气真不错。
角色B：是啊，要不出去走走？</textarea>
                            </div>
                            <div>
                                <label>预览区域</label>
                                <div id="subtitlePreviewContainer" style="position:relative;width:100%;max-width:640px;height:200px;background:#ffffff;border-radius:12px;overflow:hidden;border:1px solid rgba(148,163,184,0.4);">
                                    <img id="roleAImgPreview" style="position:absolute;display:none;transform-origin:bottom left;" />
                                    <img id="roleBImgPreview" style="position:absolute;display:none;transform-origin:bottom left;" />
                                    <div id="subtitlePreview"
                                         style="position:absolute;left:5%;right:5%;bottom:20px;color:#000000;font-size:32px;font-family:'Microsoft YaHei',sans-serif;text-align:center;text-shadow:0 0 2px #000,0 0 4px #000;white-space:pre-wrap;line-height:1.4;">
                                        角色A：今天天气真不错。
角色B：是啊，要不出去走走？
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="grid-3" style="margin-top:0.65rem;">
                            <div class="field-box">
                                <label>角色A 显示名称</label>
                                <input type="text" id="roleALabel" />
                            </div>
                            <div class="field-box">
                                <label>角色B 显示名称</label>
                                <input type="text" id="roleBLabel" />
                            </div>
                            <div class="field-box">
                                <label>预览分辨率</label>
                                <select id="subtitleResolutionPreset">
                                    <option value="1920x1080" selected>1920 × 1080（16:9）</option>
                                    <option value="1280x720">1280 × 720（16:9）</option>
                                    <option value="2560x1440">2560 × 1440（16:9）</option>
                                    <option value="1080x1920">1080 × 1920（9:16）</option>
                                </select>
                            </div>
                        </div>

                        <div class="grid-3" style="margin-top:0.65rem;">
                            <div class="field-box"><label>角色A X(%)</label><input type="number" id="roleAImagePosXPercent" min="0" max="100" /></div>
                            <div class="field-box"><label>角色A Y(%)</label><input type="number" id="roleAImagePosYPercent" min="0" max="100" /></div>
                            <div class="field-box"><label>角色A 大小(%)</label><input type="number" id="roleAImageSizePercent" min="5" max="100" /></div>
                            <div class="field-box"><label><input type="checkbox" id="roleAImageFlip" /> 角色A 镜像</label></div>
                            <div class="field-box"><label>角色B X(%)</label><input type="number" id="roleBImagePosXPercent" min="0" max="100" /></div>
                            <div class="field-box"><label>角色B Y(%)</label><input type="number" id="roleBImagePosYPercent" min="0" max="100" /></div>
                            <div class="field-box"><label>角色B 大小(%)</label><input type="number" id="roleBImageSizePercent" min="5" max="100" /></div>
                            <div class="field-box"><label><input type="checkbox" id="roleBImageFlip" /> 角色B 镜像</label></div>
                        </div>

                        <div class="grid-3" style="margin-top:0.65rem;">
                            <div class="field-box"><label>每行最多字数</label><input type="number" id="subtitleWrapLength" min="5" max="40" /></div>
                            <div class="field-box">
                                <label>字体名称（下拉可点击）</label>
                                <select id="subtitleFontName">
                                    <option value="Microsoft YaHei">微软雅黑（Microsoft YaHei）</option>
                                    <option value="SimHei">黑体（SimHei）</option>
                                    <option value="SimSun">宋体（SimSun）</option>
                                    <option value="KaiTi">楷体（KaiTi）</option>
                                    <option value="FangSong">仿宋（FangSong）</option>
                                    <option value="DengXian">等线（DengXian）</option>
                                    <option value="Arial">Arial</option>
                                    <option value="Times New Roman">Times New Roman</option>
                                </select>
                            </div>
                            <div class="field-box"><label>字号</label><input type="text" id="subtitleFontSize" /></div>
                            <div class="field-box"><label>文字颜色</label><input type="text" id="subtitlePrimaryColor" /></div>
                            <div class="field-box"><label>描边颜色</label><input type="text" id="subtitleOutlineColor" /></div>
                            <div class="field-box"><label>描边粗细</label><input type="text" id="subtitleOutline" /></div>
                            <div class="field-box"><label>阴影大小</label><input type="text" id="subtitleShadow" /></div>
                            <div class="field-box"><label>垂直偏移(%)</label><input type="number" id="subtitleVerticalOffsetPercent" min="0" max="100" /></div>
                        </div>
                    </div>

                    <div style="margin-top:0.8rem;">
                        <button type="button" id="newBtn" class="btn">新建模板</button>
                        <button type="button" id="updateBtn" class="btn">更新当前模板</button>
                        <button type="button" id="deleteBtn" class="btn btn-danger">删除当前模板</button>
                        <button type="button" id="resetBtn" class="btn">重置默认值</button>
                    </div>
                    <div id="editMsg" class="msg"></div>
                </div>
            </div>
        </div>
    </main>
</div>

<input type="file" id="uploadVideoInput" accept="video/*" style="display:none;" />
<input type="file" id="uploadAudioRoleAInput" accept="audio/*" style="display:none;" />
<input type="file" id="uploadAudioRoleBInput" accept="audio/*" style="display:none;" />
<input type="file" id="uploadBgmInput" accept="audio/*" style="display:none;" />
<input type="file" id="uploadRoleAImagesInput" accept="image/*" multiple style="display:none;" />
<input type="file" id="uploadRoleBImagesInput" accept="image/*" multiple style="display:none;" />

<script>
(function () {
    var tableBody = document.getElementById('tplTableBody');
    var listMsg = document.getElementById('listMsg');
    var editMsg = document.getElementById('editMsg');
    var assetMsg = document.getElementById('assetMsg');

    var roleAPreviewUrl = '';
    var roleBPreviewUrl = '';

    var defaultTemplate = {
        templateName: '默认模板',
        videoPath: 'runtime-data/videos/parkour.mp4',
        mode: 'double',
        audioRoleAPath: 'runtime-data/sounds/roleA_train.wav',
        audioRoleBPath: 'runtime-data/sounds/roleB_train.wav',
        bgmPath: 'runtime-data/sounds/bgm.mp3',
        bgmVolume: 0.6,
        instruction: '语速中等，节奏轻快',
        roleAPersona: '开放式提问者',
        roleBPersona: '理性解答者',
        targetWordCount: 1200,
        exportPortrait: false,
        roleAImagePaths: [],
        roleBImagePaths: [],
        roleALabel: '角色A',
        roleBLabel: '角色B',
        roleAImagePosXPercent: '10',
        roleAImagePosYPercent: '60',
        roleAImageSizePercent: '30',
        roleAImageFlip: false,
        roleBImagePosXPercent: '60',
        roleBImagePosYPercent: '60',
        roleBImageSizePercent: '30',
        roleBImageFlip: false,
        subtitleWrapLength: '15',
        subtitleFontName: 'Microsoft YaHei',
        subtitleFontSize: '32',
        subtitlePrimaryColor: '#FFFFFF',
        subtitleOutlineColor: '#000000',
        subtitleOutline: '2',
        subtitleShadow: '1',
        subtitleVerticalOffsetPercent: '5'
    };

    function byId(id) { return document.getElementById(id); }

    function showMsg(ele, text, isErr) {
        ele.textContent = text || '';
        ele.className = 'msg ' + (isErr ? 'err' : 'ok');
        ele.style.display = 'block';
    }

    function hideMsg(ele) {
        ele.style.display = 'none';
    }

    function escapeHtml(s) {
        return String(s || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function toLines(arr) {
        if (!arr || !arr.length) {
            return '';
        }
        return arr.join('\n');
    }

    function parseLines(v) {
        return String(v || '')
            .split(/\r?\n/)
            .map(function (x) { return x.trim(); })
            .filter(function (x) { return !!x; });
    }

    function fillForm(cfg) {
        byId('templateName').value = cfg.templateName || '';
        byId('videoPath').value = cfg.videoPath || '';
        byId('mode').value = cfg.mode || 'single';
        byId('audioRoleAPath').value = cfg.audioRoleAPath || '';
        byId('audioRoleBPath').value = cfg.audioRoleBPath || '';
        byId('bgmPath').value = cfg.bgmPath || '';
        byId('bgmVolume').value = cfg.bgmVolume == null ? 0.6 : cfg.bgmVolume;
        byId('instruction').value = cfg.instruction || '';

        byId('roleAPersona').value = cfg.roleAPersona || '';
        byId('roleBPersona').value = cfg.roleBPersona || '';
        byId('targetWordCount').value = cfg.targetWordCount == null ? 1200 : cfg.targetWordCount;
        byId('exportPortrait').checked = !!cfg.exportPortrait;

        byId('roleAImagePaths').value = toLines(cfg.roleAImagePaths);
        byId('roleBImagePaths').value = toLines(cfg.roleBImagePaths);

        byId('roleALabel').value = cfg.roleALabel || '';
        byId('roleBLabel').value = cfg.roleBLabel || '';

        byId('roleAImagePosXPercent').value = cfg.roleAImagePosXPercent || '10';
        byId('roleAImagePosYPercent').value = cfg.roleAImagePosYPercent || '60';
        byId('roleAImageSizePercent').value = cfg.roleAImageSizePercent || '30';
        byId('roleAImageFlip').checked = !!cfg.roleAImageFlip;

        byId('roleBImagePosXPercent').value = cfg.roleBImagePosXPercent || '60';
        byId('roleBImagePosYPercent').value = cfg.roleBImagePosYPercent || '60';
        byId('roleBImageSizePercent').value = cfg.roleBImageSizePercent || '30';
        byId('roleBImageFlip').checked = !!cfg.roleBImageFlip;

        byId('subtitleWrapLength').value = cfg.subtitleWrapLength || '15';
        byId('subtitleFontName').value = cfg.subtitleFontName || 'Microsoft YaHei';
        byId('subtitleFontSize').value = cfg.subtitleFontSize || '32';
        byId('subtitlePrimaryColor').value = cfg.subtitlePrimaryColor || '#FFFFFF';
        byId('subtitleOutlineColor').value = cfg.subtitleOutlineColor || '#000000';
        byId('subtitleOutline').value = cfg.subtitleOutline || '2';
        byId('subtitleShadow').value = cfg.subtitleShadow || '1';
        byId('subtitleVerticalOffsetPercent').value = cfg.subtitleVerticalOffsetPercent || '5';

        applyPreview();
    }

    function collectConfig() {
        return {
            templateName: (byId('templateName').value || '').trim(),
            videoPath: (byId('videoPath').value || '').trim(),
            mode: (byId('mode').value || 'single').trim(),
            audioRoleAPath: (byId('audioRoleAPath').value || '').trim(),
            audioRoleBPath: (byId('audioRoleBPath').value || '').trim(),
            bgmPath: (byId('bgmPath').value || '').trim(),
            bgmVolume: parseFloat(byId('bgmVolume').value || '0.6'),
            instruction: (byId('instruction').value || '').trim(),
            roleAPersona: (byId('roleAPersona').value || '').trim(),
            roleBPersona: (byId('roleBPersona').value || '').trim(),
            targetWordCount: parseInt(byId('targetWordCount').value || '1200', 10),
            exportPortrait: !!byId('exportPortrait').checked,
            roleAImagePaths: parseLines(byId('roleAImagePaths').value || ''),
            roleBImagePaths: parseLines(byId('roleBImagePaths').value || ''),
            roleALabel: (byId('roleALabel').value || '').trim(),
            roleBLabel: (byId('roleBLabel').value || '').trim(),
            roleAImagePosXPercent: (byId('roleAImagePosXPercent').value || '').trim(),
            roleAImagePosYPercent: (byId('roleAImagePosYPercent').value || '').trim(),
            roleAImageSizePercent: (byId('roleAImageSizePercent').value || '').trim(),
            roleAImageFlip: !!byId('roleAImageFlip').checked,
            roleBImagePosXPercent: (byId('roleBImagePosXPercent').value || '').trim(),
            roleBImagePosYPercent: (byId('roleBImagePosYPercent').value || '').trim(),
            roleBImageSizePercent: (byId('roleBImageSizePercent').value || '').trim(),
            roleBImageFlip: !!byId('roleBImageFlip').checked,
            subtitleWrapLength: (byId('subtitleWrapLength').value || '').trim(),
            subtitleFontName: (byId('subtitleFontName').value || '').trim(),
            subtitleFontSize: (byId('subtitleFontSize').value || '').trim(),
            subtitlePrimaryColor: (byId('subtitlePrimaryColor').value || '').trim(),
            subtitleOutlineColor: (byId('subtitleOutlineColor').value || '').trim(),
            subtitleOutline: (byId('subtitleOutline').value || '').trim(),
            subtitleShadow: (byId('subtitleShadow').value || '').trim(),
            subtitleVerticalOffsetPercent: (byId('subtitleVerticalOffsetPercent').value || '').trim()
        };
    }

    function loadList() {
        hideMsg(listMsg);
        fetch('${pageContext.request.contextPath}/api/template/list')
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取模板失败');
                }
                renderList(res.data);
            })
            .catch(function (e) {
                tableBody.innerHTML = '<tr><td colspan="4" style="color:#b91c1c;">' + escapeHtml(e.message || e) + '</td></tr>';
            });
    }

    function renderList(items) {
        tableBody.innerHTML = '';
        if (!items.length) {
            tableBody.innerHTML = '<tr><td colspan="4" style="color:#9ca3af;">暂无模板</td></tr>';
            return;
        }
        items.forEach(function (it) {
            var tr = document.createElement('tr');
            var fileName = it.fileName || '';
            tr.innerHTML = '' +
                '<td>' + escapeHtml(it.templateName || '') + '</td>' +
                '<td class="mono">' + escapeHtml(fileName) + '</td>' +
                '<td class="mono">' + escapeHtml(it.updatedAt || '') + '</td>' +
                '<td><button type="button" class="btn" data-act="load">加载</button></td>';
            tr.querySelector('button[data-act="load"]').addEventListener('click', function () {
                loadDetail(fileName);
            });
            tableBody.appendChild(tr);
        });
    }

    function loadDetail(fileName) {
        fetch('${pageContext.request.contextPath}/api/template/detail?fileName=' + encodeURIComponent(fileName))
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200 || !res.data) {
                    throw new Error(res.message || '读取模板失败');
                }
                byId('fileNameInput').value = fileName;
                fillForm(res.data);
                showMsg(editMsg, '模板已加载。', false);
            })
            .catch(function (e) {
                showMsg(editMsg, e.message || e, true);
            });
    }

    function uploadAsset(file, category) {
        var fd = new FormData();
        fd.append('file', file);
        fd.append('category', category);
        return fetch('${pageContext.request.contextPath}/api/template/upload-asset', {
            method: 'POST',
            body: fd
        }).then(function (r) { return r.json(); });
    }

    function bindSingleUpload(btnId, inputId, category, targetInputId) {
        var btn = byId(btnId);
        var input = byId(inputId);
        var target = byId(targetInputId);
        btn.addEventListener('click', function () { input.click(); });
        input.addEventListener('change', function () {
            if (!input.files || !input.files.length) {
                return;
            }
            hideMsg(assetMsg);
            var file = input.files[0];
            uploadAsset(file, category)
                .then(function (res) {
                    if (res.code !== 200 || !res.data) {
                        throw new Error(res.message || '上传失败');
                    }
                    target.value = res.data.path || '';
                    showMsg(assetMsg, '素材上传成功并已填入路径：' + (res.data.path || ''), false);
                })
                .catch(function (e) {
                    showMsg(assetMsg, e.message || e, true);
                })
                .finally(function () {
                    input.value = '';
                });
        });
    }

    function appendLines(textareaId, lines) {
        var el = byId(textareaId);
        var current = parseLines(el.value || '');
        lines.forEach(function (x) {
            if (current.indexOf(x) < 0) {
                current.push(x);
            }
        });
        el.value = current.join('\n');
    }

    function bindMultiImageUpload(btnId, inputId, category, targetTextareaId, roleKey) {
        var btn = byId(btnId);
        var input = byId(inputId);
        btn.addEventListener('click', function () { input.click(); });
        input.addEventListener('change', function () {
            if (!input.files || !input.files.length) {
                return;
            }
            hideMsg(assetMsg);
            var files = Array.prototype.slice.call(input.files);
            Promise.all(files.map(function (f) { return uploadAsset(f, category); }))
                .then(function (results) {
                    var paths = [];
                    results.forEach(function (res) {
                        if (res.code !== 200 || !res.data || !res.data.path) {
                            throw new Error(res.message || '上传失败');
                        }
                        paths.push(res.data.path);
                    });
                    appendLines(targetTextareaId, paths);
                    if (files[0]) {
                        var url = URL.createObjectURL(files[0]);
                        if (roleKey === 'a') {
                            roleAPreviewUrl = url;
                        } else {
                            roleBPreviewUrl = url;
                        }
                    }
                    applyPreview();
                    showMsg(assetMsg, '图片已上传并追加路径，共 ' + paths.length + ' 个。', false);
                })
                .catch(function (e) {
                    showMsg(assetMsg, e.message || e, true);
                })
                .finally(function () {
                    input.value = '';
                });
        });
    }

    function wrapByCharLimit(text, limit) {
        if (!text) return '';
        var lines = [];
        var current = '';
        var count = 0;
        for (var i = 0; i < text.length; i++) {
            var ch = text.charAt(i);
            if (ch === '\n' || ch === '\r') {
                if (current.length > 0) {
                    lines.push(current);
                    current = '';
                    count = 0;
                }
                continue;
            }
            current += ch;
            count++;
            if (count >= limit) {
                lines.push(current);
                current = '';
                count = 0;
            }
        }
        if (current.length > 0) {
            lines.push(current);
        }
        return lines.join('\n');
    }

    function applyRolePreview(url, imgEl, posXId, posYId, sizeId, flipId) {
        if (!imgEl || !url) {
            if (imgEl) {
                imgEl.style.display = 'none';
                imgEl.removeAttribute('src');
            }
            return;
        }
        imgEl.src = url;
        imgEl.style.display = 'block';
        var x = parseFloat(byId(posXId).value || '10');
        var y = parseFloat(byId(posYId).value || '60');
        var size = parseFloat(byId(sizeId).value || '30');
        if (isNaN(x) || x < 0) x = 0;
        if (x > 100) x = 100;
        if (isNaN(y) || y < 0) y = 0;
        if (y > 100) y = 100;
        if (isNaN(size) || size <= 0) size = 30;
        if (size > 100) size = 100;
        imgEl.style.left = x + '%';
        imgEl.style.top = y + '%';
        imgEl.style.width = size + '%';
        imgEl.style.height = 'auto';
        imgEl.style.transform = byId(flipId).checked ? 'scaleX(-1)' : 'scaleX(1)';
    }

    function applyPreview() {
        var sampleTextEl = byId('subtitleSampleText');
        var previewEl = byId('subtitlePreview');
        var container = byId('subtitlePreviewContainer');

        var text = (sampleTextEl.value || '').trim();
        if (!text) {
            text = '这里将展示字幕预览效果';
        }
        var wrapLen = parseInt((byId('subtitleWrapLength').value || '15').trim(), 10);
        if (isNaN(wrapLen) || wrapLen <= 0) {
            wrapLen = 15;
        }
        previewEl.textContent = wrapByCharLimit(text, wrapLen);

        var fontName = (byId('subtitleFontName').value || 'Microsoft YaHei').trim();
        var fontSize = parseInt((byId('subtitleFontSize').value || '32').trim(), 10);
        if (isNaN(fontSize) || fontSize <= 0) {
            fontSize = 32;
        }
        var primaryColor = (byId('subtitlePrimaryColor').value || '#FFFFFF').trim();
        var outlineColor = (byId('subtitleOutlineColor').value || '#000000').trim();
        var outline = parseInt((byId('subtitleOutline').value || '2').trim(), 10);
        if (isNaN(outline) || outline < 0) {
            outline = 2;
        }
        var shadow = parseInt((byId('subtitleShadow').value || '1').trim(), 10);
        if (isNaN(shadow) || shadow < 0) {
            shadow = 1;
        }

        var preset = byId('subtitleResolutionPreset').value;
        var playResX = 1920;
        var playResY = 1080;
        if (byId('exportPortrait').checked) {
            playResX = 1080;
            playResY = 1920;
        } else if (preset && preset.indexOf('x') > 0) {
            var parts = preset.split('x');
            var px = parseInt(parts[0], 10);
            var py = parseInt(parts[1], 10);
            if (!isNaN(px) && px > 0 && !isNaN(py) && py > 0) {
                playResX = px;
                playResY = py;
            }
        }

        var maxWidth = 640;
        var maxHeight = 360;
        var scaleBox = Math.min(maxWidth / playResX, maxHeight / playResY);
        container.style.maxWidth = Math.round(playResX * scaleBox) + 'px';
        container.style.height = Math.round(playResY * scaleBox) + 'px';

        var previewWidth = container.clientWidth || 640;
        var scale = previewWidth / playResX;

        previewEl.style.fontFamily = fontName + ', sans-serif';
        previewEl.style.fontSize = (fontSize * scale) + 'px';
        previewEl.style.color = primaryColor;

        var ts = [];
        if (outline > 0) {
            ts.push('0 0 ' + (outline + 1) + 'px ' + outlineColor);
            ts.push(outline + 'px 0 ' + outlineColor);
            ts.push('-' + outline + 'px 0 ' + outlineColor);
            ts.push('0 ' + outline + 'px ' + outlineColor);
            ts.push('0 -' + outline + 'px ' + outlineColor);
        }
        if (shadow > 0) {
            ts.push(shadow + 'px ' + shadow + 'px ' + outlineColor);
        }
        previewEl.style.textShadow = ts.join(', ');

        var offsetPercent = parseInt((byId('subtitleVerticalOffsetPercent').value || '5').trim(), 10);
        if (isNaN(offsetPercent) || offsetPercent < 0) offsetPercent = 0;
        if (offsetPercent > 100) offsetPercent = 100;
        var previewHeight = container.clientHeight || 360;
        previewEl.style.bottom = (previewHeight * (offsetPercent / 100.0)) + 'px';

        applyRolePreview(roleAPreviewUrl, byId('roleAImgPreview'), 'roleAImagePosXPercent', 'roleAImagePosYPercent', 'roleAImageSizePercent', 'roleAImageFlip');
        applyRolePreview(roleBPreviewUrl, byId('roleBImgPreview'), 'roleBImagePosXPercent', 'roleBImagePosYPercent', 'roleBImageSizePercent', 'roleBImageFlip');
    }

    function bindPreviewListeners() {
        [
            'subtitleSampleText', 'subtitleWrapLength', 'subtitleFontName', 'subtitleFontSize',
            'subtitlePrimaryColor', 'subtitleOutlineColor', 'subtitleOutline', 'subtitleShadow',
            'subtitleVerticalOffsetPercent', 'subtitleResolutionPreset', 'exportPortrait',
            'roleAImagePosXPercent', 'roleAImagePosYPercent', 'roleAImageSizePercent', 'roleAImageFlip',
            'roleBImagePosXPercent', 'roleBImagePosYPercent', 'roleBImageSizePercent', 'roleBImageFlip'
        ].forEach(function (id) {
            var el = byId(id);
            if (!el) {
                return;
            }
            el.addEventListener('input', applyPreview);
            el.addEventListener('change', applyPreview);
        });
    }

    byId('refreshBtn').addEventListener('click', loadList);

    byId('newBtn').addEventListener('click', function () {
        hideMsg(editMsg);
        var payload = collectConfig();
        fetch('${pageContext.request.contextPath}/api/template/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        }).then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200) {
                    throw new Error(res.message || '新建失败');
                }
                byId('fileNameInput').value = (res.data && res.data.fileName) ? res.data.fileName : '';
                showMsg(editMsg, '模板新建成功。', false);
                loadList();
            }).catch(function (e) {
                showMsg(editMsg, e.message || e, true);
            });
    });

    byId('updateBtn').addEventListener('click', function () {
        hideMsg(editMsg);
        var fileName = (byId('fileNameInput').value || '').trim();
        if (!fileName) {
            showMsg(editMsg, '请先填写文件名。', true);
            return;
        }
        var payload = collectConfig();
        fetch('${pageContext.request.contextPath}/api/template/update?fileName=' + encodeURIComponent(fileName), {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        }).then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200) {
                    throw new Error(res.message || '更新失败');
                }
                showMsg(editMsg, '模板更新成功。', false);
                loadList();
            }).catch(function (e) {
                showMsg(editMsg, e.message || e, true);
            });
    });

    byId('deleteBtn').addEventListener('click', function () {
        hideMsg(editMsg);
        var fileName = (byId('fileNameInput').value || '').trim();
        if (!fileName) {
            showMsg(editMsg, '请先填写文件名。', true);
            return;
        }
        if (!confirm('确认删除模板文件：' + fileName + ' ?')) {
            return;
        }
        fetch('${pageContext.request.contextPath}/api/template/delete?fileName=' + encodeURIComponent(fileName), {
            method: 'POST'
        }).then(function (r) { return r.json(); })
            .then(function (res) {
                if (res.code !== 200) {
                    throw new Error(res.message || '删除失败');
                }
                byId('fileNameInput').value = '';
                fillForm(defaultTemplate);
                showMsg(editMsg, '模板删除成功。', false);
                loadList();
            }).catch(function (e) {
                showMsg(editMsg, e.message || e, true);
            });
    });

    byId('resetBtn').addEventListener('click', function () {
        fillForm(defaultTemplate);
        byId('fileNameInput').value = '';
        showMsg(editMsg, '已恢复默认值。', false);
    });

    bindSingleUpload('uploadVideoBtn', 'uploadVideoInput', 'video', 'videoPath');
    bindSingleUpload('uploadAudioRoleABtn', 'uploadAudioRoleAInput', 'audioRoleA', 'audioRoleAPath');
    bindSingleUpload('uploadAudioRoleBBtn', 'uploadAudioRoleBInput', 'audioRoleB', 'audioRoleBPath');
    bindSingleUpload('uploadBgmBtn', 'uploadBgmInput', 'bgm', 'bgmPath');
    bindMultiImageUpload('uploadRoleAImagesBtn', 'uploadRoleAImagesInput', 'roleAImage', 'roleAImagePaths', 'a');
    bindMultiImageUpload('uploadRoleBImagesBtn', 'uploadRoleBImagesInput', 'roleBImage', 'roleBImagePaths', 'b');

    bindPreviewListeners();
    fillForm(defaultTemplate);
    loadList();
})();
</script>
</body>
</html>
