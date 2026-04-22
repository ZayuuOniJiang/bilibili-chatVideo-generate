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
            position: sticky;
            top: 0;
            align-self: flex-start;
            height: 100vh; /* 整个竖屏都保持导航栏风格 */
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
            width: 100%;
        }
        .wrap {
            max-width: 100%;
            margin: 0;
        }
        .dashboard-row {
            display: flex;
            flex-wrap: nowrap;
            gap: 1rem;
            align-items: stretch;
        }
        .left-pane {
            flex: 7 1 0;
            min-width: 0;
        }
        .right-pane {
            flex: 3 1 0;
            min-width: 320px;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            min-height: calc(100vh - 220px);
        }
        .right-pane .card {
            margin-bottom: 0;
        }
        .right-scroll-list {
            margin-top: 0.75rem;
            max-height: 290px;
            overflow: auto;
            padding-right: 0.25rem;
        }
        .card-fill {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .quick-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 0.65rem;
            margin-top: 0.65rem;
        }
        .quick-item {
            border: 1px solid rgba(226,232,240,0.95);
            background: rgba(255, 255, 255, 0.8);
            border-radius: 10px;
            padding: 0.6rem 0.7rem;
            font-size: 0.84rem;
            color: #334155;
        }
        .quick-title {
            color: #0f172a;
            font-weight: 600;
            margin-bottom: 0.25rem;
        }
        .progress-block {
            margin-top: 0.8rem;
        }
        .progress-track {
            width: 100%;
            height: 8px;
            background: rgba(148,163,184,0.28);
            border-radius: 999px;
            overflow: hidden;
            margin-top: 0.4rem;
        }
        .progress-value {
            width: 36%;
            height: 100%;
            background: linear-gradient(90deg, #38bdf8, #22d3ee);
        }
        .card-links {
            margin-top: 0.85rem;
            display: grid;
            gap: 0.5rem;
        }
        .card-link {
            text-decoration: none;
            color: #0c4a6e;
            font-size: 0.84rem;
            padding: 0.45rem 0.6rem;
            border: 1px solid rgba(186,230,253,0.9);
            border-radius: 8px;
            background: rgba(240,249,255,0.9);
            transition: all 0.2s;
        }
        .card-link:hover {
            background: rgba(224,242,254,0.92);
            transform: translateY(-1px);
        }
        h1 {
            font-size: 1.5rem;
            margin-bottom: 0.8rem;
            color: var(--text-main);
        }
        .sub { color:var(--text-sub);font-size:0.9rem;margin-bottom:1.3rem; }
        .card {
            background: var(--panel-bg);
            border-radius: 16px;
            padding: 1.5rem 1.6rem;
            margin-bottom: 1.5rem;
            border: 1px solid var(--panel-border);
            box-shadow: var(--shadow-soft);
            backdrop-filter: blur(12px);
        }
        .card h2 { font-size: 1.02rem; color: var(--text-main); font-weight: 600; margin-bottom: 0.75rem; }
        label { display:block;margin-bottom:0.35rem;color:var(--text-sub);font-size:0.9rem; }
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
        textarea { min-height: 80px; resize: vertical; }
        input[type="file"] {
            width: 100%;
            margin-bottom: 0.9rem;
            color:#334155;
        }
        .row { display:flex;flex-wrap:wrap;gap:1rem; }
        .col { flex:1 1 260px; }
        .btn {
            display:inline-block;
            padding:0.55rem 1.15rem;
            background:rgba(255,255,255,0.95);
            color:#111827;
            font-weight:600;
            border:1px solid rgba(203,213,225,0.95);
            border-radius:10px;
            cursor:pointer;
            font-size:0.88rem;
            box-shadow: 0 0 0 rgba(15,23,42,0);
            transition: transform 0.18s ease-out, box-shadow 0.18s ease-out, background-color 0.18s ease-out, color 0.18s ease-out;
        }
        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(15,23,42,0.12);
            background:#f9fafb;
        }
        .btn:disabled { opacity:0.6;cursor:not-allowed;box-shadow:none; }
        .msg { margin-top:0.5rem;font-size:0.85rem;display:none; }
        .msg.err { color:#b91c1c; }
        .msg.ok { color:#166534; }
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
                border-radius: 8px;
                padding: 0.35rem 0.7rem;
                font-size: 0.8rem;
            }
            .main {
                padding: 1.25rem 1.25rem 1.75rem;
            }
            .dashboard-row {
                flex-wrap: wrap;
            }
            .left-pane,
            .right-pane {
                flex: 1 1 100%;
                min-width: 0;
            }
            .right-pane {
                min-height: auto;
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
                <a href="${pageContext.request.contextPath}/zhihu" class="nav-link">
                    <span>QA 文本管理</span>
                </a>
                <a href="${pageContext.request.contextPath}/template-manage" class="nav-link">
                    <span>管理模板</span>
                </a>
                <a href="${pageContext.request.contextPath}/batch-create" class="nav-link">
                    <span>批量创建视频</span>
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
    <div class="dashboard-row">
        <div class="left-pane">
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
                <label>背景音乐音频（可选，将循环/截断以匹配视频总时长）</label>
                <input type="file" name="bgm" id="bgmFile" accept="audio/mpeg,audio/*" />
                <div style="margin-top:0.35rem;">
                    <label>背景音乐音量（0.0 - 1.0，1.0 为原始音量）</label>
                    <div style="display:flex;align-items:center;gap:0.5rem;">
                        <input type="range" id="bgmVolume" min="0" max="1" step="0.05" value="0.6" style="flex:1;" />
                        <span id="bgmVolumeText" style="font-size:0.85rem;color:#e5e7eb;">0.60</span>
                    </div>
                    <audio id="bgmPreview" controls style="display:none;width:100%;margin-top:0.35rem;"></audio>
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

            <div style="margin-top:0.75rem;margin-bottom:1.25rem;">
                <label>3. 知乎标题</label>
                <input type="text" name="title" id="titleInput" placeholder="请输入摘抄自知乎的问题标题，例如：有没有人科普一下..." />
            </div>
            <div>
                <label>4. 知乎高赞文本回答</label>
                <textarea name="content" id="contentInput" placeholder="请输入对应的高赞回答全文"></textarea>
            </div>
                <div class="input-group">
                    <label>角色A 人设（用于模板生成）</label>
                    <input type="text" id="promptRoleAPersona" placeholder="例如：雷军，擅长用通俗比喻提问" value="开放式提问者" />
                </div>
                <div class="input-group">
                    <label>角色B 人设（用于模板生成）</label>
                    <input type="text" id="promptRoleBPersona" placeholder="例如：技术专家，回答清晰有条理" value="理性解答者" />
                </div>
                <div class="input-group">
                    <label>模板目标字数（约）</label>
                    <input type="number" id="promptTargetWordCount" min="200" max="5000" value="1200" />
                </div>

            <div style="margin-top:0.75rem;">
                <label>
                    <input type="checkbox" id="exportPortrait" />
                    导出竖屏视频（最终分辨率 1080 × 1920，9:16）
                </label>
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
        </div>
        <div class="right-pane">
            <div class="card">
                <h2>知乎问答总览</h2>
                <p class="sub">从本地持久化文件中读取已抓取的问题与最高赞回答，点击问题可展开/收起详情。</p>
                <button type="button" class="btn" id="loadQaOverviewBtn">加载总览</button>
                <div id="qaOverviewMsg" class="msg"></div>
                <div id="qaOverviewList" class="right-scroll-list"></div>
            </div>

            <div class="card">
                <h2>知乎热榜抓取（questionId + 最高赞回答）</h2>
                <p class="sub">输入你在知乎网页中复制的 Cookie，后台会调用知乎热榜接口 <code>topstory/hot-list</code> 拉取前 10 个问题，并为每个问题抓取当前最高赞回答，同时写入本地 <code>runtime-data/QA.txt</code>（若历史数据在旧路径也会兼容读取）。</p>
                <label>知乎 Cookie（必填）</label>
                <textarea id="zhihuHotCookie" placeholder="请粘贴你在知乎网页中复制的完整 Cookie" style="width:100%;min-height:80px;"></textarea>
                <button type="button" class="btn" id="fetchHotQaBtn" style="margin-top:0.5rem;">抓取知乎热榜前 10 条问答</button>
                <div id="hotQaMsg" class="msg"></div>
                <div id="hotQaList" class="right-scroll-list"></div>
            </div>

            <div class="card card-fill">
                <div>
                    <h2>实时操作面板</h2>
                    <p class="sub">右侧区域已填充为可持续浏览的操作区，帮助你在长流程中减少来回滚动。</p>

                    <div class="quick-grid">
                        <div class="quick-item">
                            <div class="quick-title">当前建议</div>
                            先上传跑酷视频与角色A音频，再填写标题与高赞回答，模板质量会更稳定。
                        </div>
                        <div class="quick-item">
                            <div class="quick-title">双人模式提醒</div>
                            选择“双人视频模式”后，务必补齐角色B音频与角色B显示名称。
                        </div>
                        <div class="quick-item">
                            <div class="quick-title">字幕预检</div>
                            先在“示意字幕内容”里看换行和立绘位置，再发起最终合成，可减少返工。
                        </div>
                    </div>

                    <div class="progress-block">
                        <div class="quick-title">流程完成度（参考）</div>
                        <div style="font-size:0.82rem;color:#9ca3af;">已进入模板生成与参数校正阶段</div>
                        <div class="progress-track">
                            <div class="progress-value"></div>
                        </div>
                    </div>
                </div>

                <div class="card-links">
                    <a class="card-link" href="#" onclick="document.getElementById('generateTemplateBtn').scrollIntoView({behavior:'smooth', block:'center'});return false;">定位到「步骤一：生成模板」</a>
                    <a class="card-link" href="#" onclick="document.getElementById('confirmGenerateBtn').scrollIntoView({behavior:'smooth', block:'center'});return false;">定位到「步骤三-五：确认并生成」</a>
                    <a class="card-link" href="#" onclick="document.getElementById('subtitleSampleText').scrollIntoView({behavior:'smooth', block:'center'});return false;">定位到「字幕预览与参数区」</a>
                </div>
            </div>
        </div>
    </div>

    <div style="margin-top:1.5rem;clear:both;">
        <div class="row">
            <div class="col">
                <div class="card">
                    <h2>示意字幕内容 · 最终效果预览区域</h2>
                    <p class="sub">这里用前端模拟字幕在视频中的大致效果，方便你在生成视频前先观察字号、位置与换行。</p>
                    <label>示例字幕文本</label>
                    <textarea id="subtitleSampleText">角色A：今天天气真不错。
角色B：是啊，要不出去走走？</textarea>
                    <div style="margin-top:0.75rem;">
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
            </div>
            <div class="col">
                <div class="card">
                    <h2>字幕参数在线修改区域</h2>
                    <p class="sub">这里的参数会在你点击“确认模板并生成视频”时一并提交到后端，用于生成 ASS 字幕样式和角色立绘叠加。</p>
                    <label>角色A 立绘图片（可多选，多张图片将按台词轮流切换）</label>
                    <input type="file" id="roleAImages" name="roleAImages" accept="image/*" multiple />
                    <label>角色B 立绘图片（可多选，多张图片将按台词轮流切换）</label>
                    <input type="file" id="roleBImages" name="roleBImages" accept="image/*" multiple />
                    <label>角色A 显示名称（用于字幕前缀，例如“熊二”）</label>
                    <input type="text" id="roleALabel" value="角色A" />
                    <label>角色B 显示名称（用于字幕前缀，例如“熊大”，仅双人模式有效）</label>
                    <input type="text" id="roleBLabel" value="角色B" />
                    <label>角色A 立绘位置 X（相对屏幕宽度百分比，0-100）</label>
                    <input type="number" id="roleAImagePosXPercent" value="10" min="0" max="100" />
                    <label>角色A 立绘位置 Y（相对屏幕高度百分比，0-100）</label>
                    <input type="number" id="roleAImagePosYPercent" value="60" min="0" max="100" />
                    <label>角色A 立绘大小（相对屏幕宽度百分比，0-100）</label>
                    <input type="number" id="roleAImageSizePercent" value="30" min="5" max="100" />
                    <label><input type="checkbox" id="roleAImageFlip" /> 角色A 水平镜像翻转</label>
                    <label>角色B 立绘位置 X（相对屏幕宽度百分比，0-100）</label>
                    <input type="number" id="roleBImagePosXPercent" value="60" min="0" max="100" />
                    <label>角色B 立绘位置 Y（相对屏幕高度百分比，0-100）</label>
                    <input type="number" id="roleBImagePosYPercent" value="60" min="0" max="100" />
                    <label>角色B 立绘大小（相对屏幕宽度百分比，0-100）</label>
                    <input type="number" id="roleBImageSizePercent" value="30" min="5" max="100" />
                    <label><input type="checkbox" id="roleBImageFlip" /> 角色B 水平镜像翻转</label>
                    <label>预览分辨率</label>
                    <select id="subtitleResolutionPreset">
                        <option value="video" selected>跟随上传视频</option>
                        <option value="1920x1080">1920 × 1080（16:9）</option>
                        <option value="1280x720">1280 × 720（16:9）</option>
                        <option value="2560x1440">2560 × 1440（16:9）</option>
                        <option value="1080x1920">1080 × 1920（9:16 竖屏）</option>
                    </select>
                    <label>每行最多字数</label>
                    <input type="number" id="subtitleWrapLength" value="12" min="5" max="40" />
                    <label>字体名称</label>
                    <select id="subtitleFontName">
                        <option value="Microsoft YaHei" selected>微软雅黑（Microsoft YaHei）</option>
                        <option value="SimHei">黑体（SimHei）</option>
                        <option value="SimSun">宋体（SimSun）</option>
                        <option value="KaiTi">楷体（KaiTi）</option>
                        <option value="FangSong">仿宋（FangSong）</option>
                        <option value="DengXian">等线（DengXian）</option>
                        <option value="Arial">Arial</option>
                        <option value="Times New Roman">Times New Roman</option>
                    </select>
                    <label>字号（px）</label>
                    <input type="text" id="subtitleFontSize" value="85" />
                    <label>文字颜色（#RRGGBB）</label>
                    <input type="text" id="subtitlePrimaryColor" value="#00FFFF" />
                    <label>描边颜色（#RRGGBB）</label>
                    <input type="text" id="subtitleOutlineColor" value="#000000" />
                    <label>描边粗细（整数）</label>
                    <input type="text" id="subtitleOutline" value="2" />
                    <label>阴影大小（整数）</label>
                    <input type="text" id="subtitleShadow" value="1" />
                    <label>垂直偏移百分比（距底部高度，0-100）</label>
                    <input type="number" id="subtitleVerticalOffsetPercent" value="60" min="0" max="100" />
                </div>
            </div>
        </div>
    </div>

    <div class="card" style="margin-top:1.5rem;">
        <h2>结果预览</h2>
        <p class="sub">生成成功后，会在下方展示合成后的视频（服务器返回的是本地文件路径，通过单独接口进行读取 / 下载）。</p>
        <div class="video-preview">
            <video id="resultVideo" controls></video>
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
        var promptRoleAPersona = document.getElementById('promptRoleAPersona');
        var promptRoleBPersona = document.getElementById('promptRoleBPersona');
        var promptTargetWordCount = document.getElementById('promptTargetWordCount');

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
            var roleAPersona = promptRoleAPersona ? (promptRoleAPersona.value || '').trim() : '';
            var roleBPersona = promptRoleBPersona ? (promptRoleBPersona.value || '').trim() : '';
            var targetWordCount = promptTargetWordCount ? (promptTargetWordCount.value || '').trim() : '';
            if (!targetWordCount) {
                targetWordCount = '1200';
            }
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
                body: 'title=' + encodeURIComponent(title)
                    + '&content=' + encodeURIComponent(content)
                    + '&roleAPersona=' + encodeURIComponent(roleAPersona)
                    + '&roleBPersona=' + encodeURIComponent(roleBPersona)
                    + '&targetWordCount=' + encodeURIComponent(targetWordCount)
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
        var bgmFile = document.getElementById('bgmFile');
        var titleInput = document.getElementById('titleInput');
        var templateBox = document.getElementById('templateBox');
        var resultVideo = document.getElementById('resultVideo');
        var instructionInput = document.getElementById('instructionInput');
        var subtitleFontName = document.getElementById('subtitleFontName');
        var subtitleFontSize = document.getElementById('subtitleFontSize');
        var subtitlePrimaryColor = document.getElementById('subtitlePrimaryColor');
        var subtitleOutlineColor = document.getElementById('subtitleOutlineColor');
        var subtitleOutline = document.getElementById('subtitleOutline');
        var subtitleShadow = document.getElementById('subtitleShadow');
        var subtitleWrapLength = document.getElementById('subtitleWrapLength');
        var subtitleVerticalOffsetPercent = document.getElementById('subtitleVerticalOffsetPercent');
        var exportPortraitEl = document.getElementById('exportPortrait');
        var bgmVolumeEl = document.getElementById('bgmVolume');
        var roleALabelEl = document.getElementById('roleALabel');
        var roleBLabelEl = document.getElementById('roleBLabel');
        var roleAImagesInput = document.getElementById('roleAImages');
        var roleBImagesInput = document.getElementById('roleBImages');
        var roleAImagePosXEl = document.getElementById('roleAImagePosXPercent');
        var roleAImagePosYEl = document.getElementById('roleAImagePosYPercent');
        var roleAImageSizeEl = document.getElementById('roleAImageSizePercent');
        var roleAImageFlipEl = document.getElementById('roleAImageFlip');
        var roleBImagePosXEl = document.getElementById('roleBImagePosXPercent');
        var roleBImagePosYEl = document.getElementById('roleBImagePosYPercent');
        var roleBImageSizeEl = document.getElementById('roleBImageSizePercent');
        var roleBImageFlipEl = document.getElementById('roleBImageFlip');

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
            if (bgmFile && bgmFile.files && bgmFile.files[0]) {
                fd.append('bgm', bgmFile.files[0]);
            }
            if (instruction) {
                fd.append('instruction', instruction);
            }
            if (subtitleWrapLength) {
                fd.append('subtitleWrapLength', (subtitleWrapLength.value || '').trim());
            }
            if (subtitleFontName) {
                fd.append('subtitleFontName', (subtitleFontName.value || '').trim());
            }
            if (subtitleFontSize) {
                fd.append('subtitleFontSize', (subtitleFontSize.value || '').trim());
            }
            if (subtitlePrimaryColor) {
                fd.append('subtitlePrimaryColor', (subtitlePrimaryColor.value || '').trim());
            }
            if (subtitleOutlineColor) {
                fd.append('subtitleOutlineColor', (subtitleOutlineColor.value || '').trim());
            }
            if (subtitleOutline) {
                fd.append('subtitleOutline', (subtitleOutline.value || '').trim());
            }
            if (subtitleShadow) {
                fd.append('subtitleShadow', (subtitleShadow.value || '').trim());
            }
            if (subtitleVerticalOffsetPercent) {
                fd.append('subtitleVerticalOffsetPercent', (subtitleVerticalOffsetPercent.value || '').trim());
            }
            if (bgmVolumeEl) {
                fd.append('bgmVolume', (bgmVolumeEl.value || '').trim());
            }
            if (roleALabelEl) {
                fd.append('roleALabel', (roleALabelEl.value || '').trim());
            }
            if (roleBLabelEl) {
                fd.append('roleBLabel', (roleBLabelEl.value || '').trim());
            }
            if (roleAImagesInput && roleAImagesInput.files && roleAImagesInput.files.length > 0) {
                for (var i = 0; i < roleAImagesInput.files.length; i++) {
                    fd.append('roleAImages', roleAImagesInput.files[i]);
                }
            }
            if (roleBImagesInput && roleBImagesInput.files && roleBImagesInput.files.length > 0) {
                for (var j = 0; j < roleBImagesInput.files.length; j++) {
                    fd.append('roleBImages', roleBImagesInput.files[j]);
                }
            }
            if (roleAImagePosXEl) {
                fd.append('roleAImagePosXPercent', (roleAImagePosXEl.value || '').trim());
            }
            if (roleAImagePosYEl) {
                fd.append('roleAImagePosYPercent', (roleAImagePosYEl.value || '').trim());
            }
            if (roleAImageSizeEl) {
                fd.append('roleAImageSizePercent', (roleAImageSizeEl.value || '').trim());
            }
            if (roleAImageFlipEl) {
                fd.append('roleAImageFlip', roleAImageFlipEl.checked ? 'true' : 'false');
            }
            if (roleBImagePosXEl) {
                fd.append('roleBImagePosXPercent', (roleBImagePosXEl.value || '').trim());
            }
            if (roleBImagePosYEl) {
                fd.append('roleBImagePosYPercent', (roleBImagePosYEl.value || '').trim());
            }
            if (roleBImageSizeEl) {
                fd.append('roleBImageSizePercent', (roleBImageSizeEl.value || '').trim());
            }
            if (roleBImageFlipEl) {
                fd.append('roleBImageFlip', roleBImageFlipEl.checked ? 'true' : 'false');
            }
            if (exportPortraitEl && exportPortraitEl.checked) {
                fd.append('exportPortrait', 'true');
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

    // 字幕样式预览：纯前端模拟，与视频生成解耦
    (function () {
        var sampleTextEl = document.getElementById('subtitleSampleText');
        var previewEl = document.getElementById('subtitlePreview');
        var fontNameEl = document.getElementById('subtitleFontName');
        var fontSizeEl = document.getElementById('subtitleFontSize');
        var primaryColorEl = document.getElementById('subtitlePrimaryColor');
        var outlineColorEl = document.getElementById('subtitleOutlineColor');
        var outlineEl = document.getElementById('subtitleOutline');
        var shadowEl = document.getElementById('subtitleShadow');
        var wrapLengthEl = document.getElementById('subtitleWrapLength');
        var resolutionPresetEl = document.getElementById('subtitleResolutionPreset');
        var previewContainer = document.getElementById('subtitlePreviewContainer');
        var verticalOffsetEl = document.getElementById('subtitleVerticalOffsetPercent');
        var exportPortraitEl = document.getElementById('exportPortrait');
        var roleAImagesInput = document.getElementById('roleAImages');
        var roleBImagesInput = document.getElementById('roleBImages');
        var roleAImgPreview = document.getElementById('roleAImgPreview');
        var roleBImgPreview = document.getElementById('roleBImgPreview');
        var roleAImagePosXEl = document.getElementById('roleAImagePosXPercent');
        var roleAImagePosYEl = document.getElementById('roleAImagePosYPercent');
        var roleAImageSizeEl = document.getElementById('roleAImageSizePercent');
        var roleAImageFlipEl = document.getElementById('roleAImageFlip');
        var roleBImagePosXEl = document.getElementById('roleBImagePosXPercent');
        var roleBImagePosYEl = document.getElementById('roleBImagePosYPercent');
        var roleBImageSizeEl = document.getElementById('roleBImageSizePercent');
        var roleBImageFlipEl = document.getElementById('roleBImageFlip');

        if (!previewEl) {
            return;
        }

        function wrapByCharLimit(text, limit) {
            if (!text) return "";
            var lines = [];
            var current = "";
            var count = 0;
            for (var i = 0; i < text.length; i++) {
                var ch = text.charAt(i);
                if (ch === '\n' || ch === '\r') {
                    if (current.length > 0) {
                        lines.push(current);
                        current = "";
                        count = 0;
                    }
                    continue;
                }
                current += ch;
                count++;
                if (count >= limit) {
                    lines.push(current);
                    current = "";
                    count = 0;
                }
            }
            if (current.length > 0) {
                lines.push(current);
            }
            return lines.join("\n");
        }

        function applyPreview() {
            var text = (sampleTextEl.value || '').trim();
            if (!text) {
                text = '这里将展示字幕预览效果';
            }
            var wrapLen = parseInt((wrapLengthEl.value || '15').trim(), 10);
            if (isNaN(wrapLen) || wrapLen <= 0) {
                wrapLen = 15;
            }
            var wrapped = wrapByCharLimit(text, wrapLen);
            previewEl.textContent = wrapped;

            var fontName = (fontNameEl.value || 'Microsoft YaHei').trim();
            var fontSize = parseInt((fontSizeEl.value || '32').trim(), 10);
            if (isNaN(fontSize) || fontSize <= 0) {
                fontSize = 32;
            }
            var primaryColor = (primaryColorEl.value || '#FFFFFF').trim();
            var outlineColor = (outlineColorEl.value || '#000000').trim();
            var outline = parseInt((outlineEl.value || '2').trim(), 10);
            if (isNaN(outline) || outline < 0) {
                outline = 2;
            }
            var shadow = parseInt((shadowEl.value || '1').trim(), 10);
            if (isNaN(shadow) || shadow < 0) {
                shadow = 1;
            }
            previewEl.style.fontFamily = fontName + ", sans-serif";
            // 按分辨率比例缩放预览字体大小
            var previewWidth = previewContainer.clientWidth || 640;
            var playResX = 1920;
            if (resolutionPresetEl) {
                var val = resolutionPresetEl.value;
                if (val === 'video' && window.__subtitleVideoWidth) {
                    playResX = window.__subtitleVideoWidth;
                } else if (val && val.indexOf('x') > 0) {
                    var parts = val.split('x');
                    var pw = parseInt(parts[0], 10);
                    if (!isNaN(pw) && pw > 0) {
                        playResX = pw;
                    }
                }
            }
            var scale = previewWidth / playResX;
            var previewFontSize = fontSize * scale;
            previewEl.style.fontSize = previewFontSize + "px";
            previewEl.style.color = primaryColor;

            // 用 text-shadow 近似模拟描边 + 阴影
            var ts = [];
            var o = outline;
            if (o > 0) {
                ts.push("0 0 " + (o + 1) + "px " + outlineColor);
                ts.push(o + "px 0 " + outlineColor);
                ts.push("-" + o + "px 0 " + outlineColor);
                ts.push("0 " + o + "px " + outlineColor);
                ts.push("0 -" + o + "px " + outlineColor);
            }
            if (shadow > 0) {
                ts.push(shadow + "px " + shadow + "px " + outlineColor);
            }
            previewEl.style.textShadow = ts.join(", ");

            // 垂直偏移百分比：根据容器高度计算 bottom 像素
            var offsetPercent = parseInt((verticalOffsetEl && verticalOffsetEl.value ? verticalOffsetEl.value : '5').trim(), 10);
            if (isNaN(offsetPercent) || offsetPercent < 0) offsetPercent = 0;
            if (offsetPercent > 100) offsetPercent = 100;
            var previewHeight = previewContainer.clientHeight || 360;
            var bottomPx = previewHeight * (offsetPercent / 100.0);
            previewEl.style.bottom = bottomPx + "px";
            previewEl.style.top = "";
            previewEl.style.transform = "";

            // 角色立绘预览：按百分比控制位置和大小，支持镜像
            function applyRolePreview(imgInput, imgEl, posXEl, posYEl, sizeEl, flipEl) {
                if (!imgEl) return;
                if (!imgInput || !imgInput.files || imgInput.files.length === 0) {
                    imgEl.style.display = 'none';
                    imgEl.removeAttribute('src');
                    return;
                }
                if (!imgEl.src) {
                    var url = URL.createObjectURL(imgInput.files[0]);
                    imgEl.src = url;
                }
                imgEl.style.display = 'block';
                var x = parseFloat((posXEl && posXEl.value) ? posXEl.value : '10');
                var y = parseFloat((posYEl && posYEl.value) ? posYEl.value : '60');
                var size = parseFloat((sizeEl && sizeEl.value) ? sizeEl.value : '30');
                if (isNaN(x) || x < 0) x = 0;
                if (x > 100) x = 100;
                if (isNaN(y) || y < 0) y = 0;
                if (y > 100) y = 100;
                if (isNaN(size) || size <= 0) size = 30;
                if (size > 100) size = 100;
                imgEl.style.left = x + "%";
                imgEl.style.top = y + "%";
                // 按预览容器宽度的百分比控制立绘宽度，高度自适应，保持与后端按宽度百分比缩放策略一致
                imgEl.style.width = size + "%";
                imgEl.style.height = "auto";
                var flip = flipEl && flipEl.checked;
                imgEl.style.transform = flip ? "scaleX(-1)" : "scaleX(1)";
            }

            applyRolePreview(roleAImagesInput, roleAImgPreview, roleAImagePosXEl, roleAImagePosYEl, roleAImageSizeEl, roleAImageFlipEl);
            applyRolePreview(roleBImagesInput, roleBImgPreview, roleBImagePosXEl, roleBImagePosYEl, roleBImageSizeEl, roleBImageFlipEl);
        }

        ['input', 'change'].forEach(function (evt) {
            sampleTextEl.addEventListener(evt, applyPreview);
            fontNameEl.addEventListener(evt, applyPreview);
            fontSizeEl.addEventListener(evt, applyPreview);
            primaryColorEl.addEventListener(evt, applyPreview);
            outlineColorEl.addEventListener(evt, applyPreview);
            outlineEl.addEventListener(evt, applyPreview);
            shadowEl.addEventListener(evt, applyPreview);
            if (verticalOffsetEl) {
                verticalOffsetEl.addEventListener(evt, applyPreview);
            }
            wrapLengthEl.addEventListener(evt, applyPreview);
            if (roleAImagePosXEl) roleAImagePosXEl.addEventListener(evt, applyPreview);
            if (roleAImagePosYEl) roleAImagePosYEl.addEventListener(evt, applyPreview);
            if (roleAImageSizeEl) roleAImageSizeEl.addEventListener(evt, applyPreview);
            if (roleAImageFlipEl) roleAImageFlipEl.addEventListener(evt, applyPreview);
            if (roleBImagePosXEl) roleBImagePosXEl.addEventListener(evt, applyPreview);
            if (roleBImagePosYEl) roleBImagePosYEl.addEventListener(evt, applyPreview);
            if (roleBImageSizeEl) roleBImageSizeEl.addEventListener(evt, applyPreview);
            if (roleBImageFlipEl) roleBImageFlipEl.addEventListener(evt, applyPreview);
        });

        if (roleAImagesInput) {
            roleAImagesInput.addEventListener('change', function () {
                if (roleAImgPreview && roleAImagesInput.files && roleAImagesInput.files[0]) {
                    roleAImgPreview.src = URL.createObjectURL(roleAImagesInput.files[0]);
                    applyPreview();
                }
            });
        }
        if (roleBImagesInput) {
            roleBImagesInput.addEventListener('change', function () {
                if (roleBImgPreview && roleBImagesInput.files && roleBImagesInput.files[0]) {
                    roleBImgPreview.src = URL.createObjectURL(roleBImagesInput.files[0]);
                    applyPreview();
                }
            });
        }

        applyPreview();
    })();

    // 根据上传视频或预设分辨率调整字幕预览区域的宽高比例
    (function () {
        var videoFileInput = document.getElementById('videoFile');
        var previewContainer = document.getElementById('subtitlePreviewContainer');
        var resolutionPresetEl = document.getElementById('subtitleResolutionPreset');
        var exportPortraitEl = document.getElementById('exportPortrait');
        if (!videoFileInput || !previewContainer) {
            return;
        }
        var probeVideo = document.createElement('video');
        probeVideo.style.display = 'none';
        document.body.appendChild(probeVideo);
        var lastVideoWidth = 0;
        var lastVideoHeight = 0;

        function resizeByRatio(vw, vh) {
            if (!vw || !vh) return;
            // 在不改变宽高比的前提下，将预览区域限制在一个较小的矩形内
            var maxWidth = 640;
            var maxHeight = 360;
            var scale = Math.min(maxWidth / vw, maxHeight / vh);
            var width = Math.round(vw * scale);
            var height = Math.round(vh * scale);
            previewContainer.style.maxWidth = width + "px";
            previewContainer.style.height = height + "px";
        }

        function applyPresetResolution() {
            if (!resolutionPresetEl) return;
            var val = resolutionPresetEl.value;
            // 若勾选导出竖屏，则优先使用 1080x1920 预览比例
            if (exportPortraitEl && exportPortraitEl.checked) {
                val = "1080x1920";
            }
            if (val === 'video' && lastVideoWidth > 0 && lastVideoHeight > 0) {
                resizeByRatio(lastVideoWidth, lastVideoHeight);
                return;
            }
            var vw = 1920, vh = 1080; // 默认 16:9
            if (val && val.indexOf('x') > 0) {
                var parts = val.split('x');
                var pw = parseInt(parts[0], 10);
                var ph = parseInt(parts[1], 10);
                if (!isNaN(pw) && !isNaN(ph) && pw > 0 && ph > 0) {
                    vw = pw;
                    vh = ph;
                }
            }
            resizeByRatio(vw, vh);
        }

        videoFileInput.addEventListener('change', function (e) {
            var file = e.target.files && e.target.files[0];
            if (!file) return;
            var url = URL.createObjectURL(file);
            probeVideo.src = url;
            probeVideo.onloadedmetadata = function () {
                var vw = probeVideo.videoWidth;
                var vh = probeVideo.videoHeight;
                if (!vw || !vh) return;
                lastVideoWidth = vw;
                lastVideoHeight = vh;
                window.__subtitleVideoWidth = vw;
                window.__subtitleVideoHeight = vh;
                // 如果当前预设为“跟随上传视频”，则使用真实分辨率比例
                applyPresetResolution();
            };
        });

        if (resolutionPresetEl) {
            resolutionPresetEl.addEventListener('change', applyPresetResolution);
        }
        if (exportPortraitEl) {
            exportPortraitEl.addEventListener('change', applyPresetResolution);
        }

        // 初始按照默认预设（无视频时使用 1920x1080）
        applyPresetResolution();
    })();

    // 背景音乐音量调节与试听预览
    (function () {
        var bgmInput = document.getElementById('bgmFile');
        var bgmPreview = document.getElementById('bgmPreview');
        var bgmVolumeEl = document.getElementById('bgmVolume');
        var bgmVolumeText = document.getElementById('bgmVolumeText');

        if (!bgmInput || !bgmPreview || !bgmVolumeEl) {
            return;
        }

        function updateVolumeLabel() {
            var v = parseFloat(bgmVolumeEl.value || '0.6');
            if (isNaN(v) || v < 0) v = 0;
            if (v > 1) v = 1;
            bgmVolumeText.textContent = v.toFixed(2);
            bgmPreview.volume = v;
        }

        bgmInput.addEventListener('change', function (e) {
            var file = e.target.files && e.target.files[0];
            if (!file) {
                bgmPreview.style.display = 'none';
                bgmPreview.removeAttribute('src');
                return;
            }
            var url = URL.createObjectURL(file);
            bgmPreview.src = url;
            bgmPreview.style.display = 'block';
            updateVolumeLabel();
        });

        bgmVolumeEl.addEventListener('input', updateVolumeLabel);
        updateVolumeLabel();
    })();

    // 右侧：知乎 QA 总览 & 热榜抓取
    (function () {
        var overviewBtn = document.getElementById('loadQaOverviewBtn');
        var overviewMsg = document.getElementById('qaOverviewMsg');
        var overviewList = document.getElementById('qaOverviewList');
        var hotBtn = document.getElementById('fetchHotQaBtn');
        var hotMsg = document.getElementById('hotQaMsg');
        var hotList = document.getElementById('hotQaList');
        var cookieInput = document.getElementById('zhihuHotCookie');

        function showMsg(el, text, isErr) {
            el.textContent = text;
            el.className = 'msg ' + (isErr ? 'err' : 'ok');
            el.style.display = 'block';
        }
        function hideMsg(el) {
            el.style.display = 'none';
        }

        function renderQaList(container, items) {
            container.innerHTML = '';
            if (!items || !items.length) {
                var empty = document.createElement('div');
                empty.style.color = '#9ca3af';
                empty.style.fontSize = '0.85rem';
                empty.textContent = '暂无数据。';
                container.appendChild(empty);
                return;
            }
            items.forEach(function (item, idx) {
                var wrapper = document.createElement('div');
                wrapper.style.borderBottom = '1px solid rgba(148,163,184,0.25)';
                wrapper.style.padding = '0.35rem 0';

                var header = document.createElement('div');
                header.style.display = 'flex';
                header.style.alignItems = 'center';
                header.style.cursor = 'pointer';
                header.style.fontSize = '0.9rem';
                header.style.color = '#e5e7eb';
                header.style.gap = '0.35rem';

                var qid = item.questionId || '';
                var title = item.title || '';
                var bookmarked = String(item.bookmarked || 'false').toLowerCase() === 'true';

                // 书签小圆点按钮
                var bookmarkBtn = document.createElement('button');
                bookmarkBtn.type = 'button';
                bookmarkBtn.style.width = '10px';
                bookmarkBtn.style.height = '10px';
                bookmarkBtn.style.borderRadius = '999px';
                bookmarkBtn.style.border = '1px solid #6b7280';
                bookmarkBtn.style.backgroundColor = bookmarked ? '#22c55e' : 'transparent';
                bookmarkBtn.style.cursor = 'pointer';
                bookmarkBtn.style.flexShrink = '0';
                bookmarkBtn.dataset.questionId = qid;
                bookmarkBtn.dataset.title = title;
                bookmarkBtn.dataset.bookmarked = bookmarked ? 'true' : 'false';

                bookmarkBtn.addEventListener('click', function (ev) {
                    ev.stopPropagation();
                    var current = this.dataset.bookmarked === 'true';
                    var next = !current;
                    this.style.backgroundColor = next ? '#22c55e' : 'transparent';
                    this.dataset.bookmarked = next ? 'true' : 'false';

                    var body = new URLSearchParams();
                    body.append('questionId', qid);
                    body.append('title', title);
                    body.append('bookmarked', next ? 'true' : 'false');

                    fetch('${pageContext.request.contextPath}/api/bashboard/qa/bookmark', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                        },
                        body: body.toString()
                    }).catch(function () {
                        // 失败时静默，不打断用户操作
                    });
                });

                var indexSpan = document.createElement('span');
                indexSpan.textContent = (item.index != null ? item.index : (idx + 1)) + '. ';
                indexSpan.style.color = '#9ca3af';

                var titleSpan = document.createElement('span');
                titleSpan.textContent = item.title || ('问题 ' + (item.questionId || ''));

                header.appendChild(bookmarkBtn);
                header.appendChild(indexSpan);
                header.appendChild(titleSpan);

                var body = document.createElement('div');
                body.style.display = 'none';
                body.style.marginTop = '0.25rem';
                body.style.fontSize = '0.85rem';
                body.style.color = '#d1d5db';
                body.style.lineHeight = '1.5';
                body.style.maxHeight = '200px';
                body.style.overflow = 'auto';

                // 回答内容可能是 HTML，这里将其转成纯文本以便快速浏览
                var raw = item.answerContent || '';
                var tmp = document.createElement('div');
                tmp.innerHTML = raw;
                body.textContent = tmp.innerText || tmp.textContent || raw;

                header.addEventListener('click', function () {
                    body.style.display = body.style.display === 'none' ? 'block' : 'none';
                });

                wrapper.appendChild(header);
                wrapper.appendChild(body);
                container.appendChild(wrapper);
            });
        }

        if (overviewBtn) {
            overviewBtn.addEventListener('click', function () {
                hideMsg(overviewMsg);
                overviewList.innerHTML = '';
                overviewBtn.disabled = true;
                showMsg(overviewMsg, '正在从本地 QA.txt 加载问题总览……', false);

                fetch('${pageContext.request.contextPath}/api/bashboard/qa/overview', {
                    method: 'GET'
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (res.code === 200 && res.data) {
                            renderQaList(overviewList, res.data);
                            showMsg(overviewMsg, '加载完成。', false);
                        } else {
                            showMsg(overviewMsg, res.message || '加载失败。', true);
                        }
                    })
                    .catch(function (err) {
                        showMsg(overviewMsg, '请求失败：' + (err.message || err), true);
                    })
                    .finally(function () {
                        overviewBtn.disabled = false;
                    });
            });
        }

        if (hotBtn) {
            hotBtn.addEventListener('click', function () {
                hideMsg(hotMsg);
                hotList.innerHTML = '';
                var cookie = (cookieInput && cookieInput.value ? cookieInput.value.trim() : '');
                if (!cookie) {
                    showMsg(hotMsg, '请先粘贴知乎 Cookie。', true);
                    return;
                }
                hotBtn.disabled = true;
                showMsg(hotMsg, '正在调用知乎热榜接口并抓取前 10 个问题的最高赞回答，这可能需要数十秒，请耐心等待……', false);

                var body = new URLSearchParams();
                body.append('cookie', cookie);

                fetch('${pageContext.request.contextPath}/api/bashboard/zhihu/hot-qa', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: body.toString()
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (res.code === 200 && res.data) {
                            var items = res.data || [];
                            var added = items.length;
                            var total = 10; // 当前后端固定抓取前 10 条
                            var skipped = total - added;
                            renderQaList(hotList, items);
                            showMsg(
                                hotMsg,
                                '抓取完成，本次新增 ' + added + ' 条，跳过 ' + skipped + ' 条已存在问题，并已写入本地 QA.txt。',
                                false
                            );
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
            });
        }
    })();
</script>
</body>
</html>

