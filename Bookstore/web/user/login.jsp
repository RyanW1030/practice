<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%--
  ========================================================================
  【页面数据接口文档】
  ------------------------------------------------------------------------
  本页面文件: login.jsp
  页面描述: 登录页。根据前端选择的角色，直接向对应的 Servlet 发送请求。

  1. [交互逻辑]
     - 角色选择 "普通用户" -> 表单 action 变为 "userServlet?action=login"
     - 角色选择 "管理员"   -> 表单 action 变为 "adminServlet?action=login"

  2. [Request 属性] (回显与错误提示)
     - isLogin (Boolean): false 表示登录失败
     - msg (String): 具体错误信息
     - username (String): 回显刚才输入的账号
     - isRegister (String): "1" 表示注册成功跳转
  ========================================================================
--%>

<%
    // 1. 获取后端传回的状态 (用于显示 Alert)
    // 登录失败标记
    Object isLoginAttr = request.getAttribute("isLogin");
    boolean loginFailed = (isLoginAttr != null && isLoginAttr.equals(false));

    // 注册成功标记
    String isRegisterParam = request.getParameter("isRegister");
    boolean registerSuccess = "1".equals(isRegisterParam);

    // 错误信息
    String msg = (String) request.getAttribute("msg");
    if(msg == null) msg = "用户名或密码错误";
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>登录 - 麦田守望者书店</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=<%= System.currentTimeMillis() %>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-card">
        <div class="auth-header">
            <img src="${pageContext.request.contextPath}/static/img/smile.avif" alt="Logo" class="auth-logo">
            <h1 class="auth-title">欢迎回来</h1>
            <p class="auth-subtitle">登录麦田守望者书店</p>
        </div>

        <%-- 登录失败提示 --%>
        <% if(loginFailed) { %>
        <div class="alert-box alert-error">
            <i class="fas fa-exclamation-circle"></i> <%= msg %>
        </div>
        <% } %>

        <%-- 注册成功提示 --%>
        <% if(registerSuccess) { %>
        <div class="alert-box alert-success">
            <i class="fas fa-check-circle"></i> 注册成功，请登录
        </div>
        <% } %>

        <%-- 角色切换开关 --%>
        <div class="role-selector" onclick="toggleRole()">
            <div class="role-slider" id="role-slider"></div>
            <div class="role-option active" id="opt-user">普通用户</div>
            <div class="role-option" id="opt-admin">管理员</div>
        </div>

        <%--
           【核心修改】
           1. 给 form 添加 id="loginForm" 以便 JS 操作
           2. 默认 action 指向 userServlet
        --%>
        <form action="${pageContext.request.contextPath}/userServlet?action=login"
              method="post"
              id="loginForm"
              onsubmit="return validateLogin()">

            <%-- 隐藏域 role 依然保留，方便 Servlet 知道当前身份（如果需要） --%>
            <input type="hidden" name="role" id="role-input" value="user">

            <div class="form-group">
                <input type="text" name="username" class="form-control" placeholder="请输入用户名" required
                       value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>">
            </div>

            <div class="form-group">
                <input type="password" name="password" id="password" class="form-control" placeholder="请输入密码" required>
            </div>

            <button type="submit" class="btn-block">立即登录</button>
        </form>

        <div class="auth-footer-link" id="register-link-area">
            还没有账号？ <a href="register.jsp" class="link-highlight">去注册</a>
        </div>
        <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="auth-footer-link">
            <i class="fas fa-arrow-left"></i> 返回首页
        </a>
    </div>
</div>

<script>
    let currentRole = 'user';
    // 预定义提交路径
    const userAction = "${pageContext.request.contextPath}/userServlet?action=login";
    const adminAction = "${pageContext.request.contextPath}/adminServlet?action=login";

    // 切换登录角色 (UI + 逻辑)
    function toggleRole() {
        const slider = document.getElementById('role-slider');
        const roleInput = document.getElementById('role-input');
        const regLinkArea = document.getElementById('register-link-area');
        const opts = document.querySelectorAll('.role-option');
        const form = document.getElementById('loginForm'); // 获取表单

        if (currentRole === 'user') {
            // === 切换为管理员 ===
            currentRole = 'admin';
            slider.classList.add('right');
            opts[1].classList.add('active');
            opts[0].classList.remove('active');

            roleInput.value = 'admin';
            regLinkArea.style.display = 'none'; // 管理员没有注册入口

            // 【核心】修改表单提交地址 -> AdminServlet
            form.action = adminAction;

        } else {
            // === 切换为普通用户 ===
            currentRole = 'user';
            slider.classList.remove('right');
            opts[0].classList.add('active');
            opts[1].classList.remove('active');

            roleInput.value = 'user';
            regLinkArea.style.display = 'block';

            // 【核心】修改表单提交地址 -> UserServlet
            form.action = userAction;
        }
    }

    function validateLogin() {
        // 你之前的密码正则验证 (如果管理员密码格式不同，可以在这里加判断)
        const pwd = document.getElementById('password').value;
        const regex = /^[a-zA-Z0-9]{8}$/;
        if (!regex.test(pwd)) {
             // 如果想保留验证，取消注释即可
              alert("登录失败：密码必须为8位数字或字母。");
             return false;
        }
        return true;
    }
</script>
</body>
</html>