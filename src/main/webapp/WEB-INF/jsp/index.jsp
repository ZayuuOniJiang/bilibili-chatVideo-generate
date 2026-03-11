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
            display: flex;
            align-items: flex-start;
            justify-content: center;
        }
        .card {
            background: rgba(15,23,42,0.78);
            border-radius: 16px;
            padding: 2rem;
            max-width: 600px;
            width: 100%;
            box-shadow: 0 24px 80px rgba(15,23,42,0.9);
            border: 1px solid rgba(148,163,184,0.35);
        }
        h1 {
            font-size: 1.4rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
        }
        .welcome {
            color: #9ca3af;
            margin-bottom: 1.25rem;
            line-height: 1.6;
            font-size: 0.95rem;
        }
        .links {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }
        .links a {
            display: inline-block;
            padding: 0.55rem 1.1rem;
            background: #ffffff;
            color: #111827;
            font-weight: 600;
            text-decoration: none;
            border-radius: 999px;
            font-size: 0.85rem;
            border: 1px solid rgba(209,213,219,0.9);
            box-shadow: 0 0 0 rgba(15,23,42,0);
            transition: transform 0.18s ease-out, box-shadow 0.18s ease-out, background-color 0.18s ease-out, color 0.18s ease-out;
        }
        .links a:hover {
            transform: scale(1.04);
            box-shadow: 0 14px 38px rgba(15,23,42,0.55);
            background: #f9fafb;
        }
        .status {
            margin-top: 1.3rem;
            padding: 0.75rem 0.9rem;
            background: rgba(22,163,74,0.14);
            border-radius: 12px;
            font-size: 0.82rem;
            color: #bbf7d0;
            border: 1px solid rgba(74,222,128,0.45);
        }
        .status span {
            opacity: 0.85;
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
                <a href="${pageContext.request.contextPath}/" class="nav-link nav-link-active">
                    <span>首页</span>
                </a>
                <a href="${pageContext.request.contextPath}/bashboard" class="nav-link">
                    <span>跑酷生成仪表盘</span>
                </a>
                <a href="${pageContext.request.contextPath}/test" class="nav-link">
                    <span>接口与合成测试</span>
                </a>
            </div>
        </div>
        <div class="nav-footer">
            <div>当前环境：本地开发</div>
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
</body>
</html>
