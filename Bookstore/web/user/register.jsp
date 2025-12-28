<%--
  ========================================================================
  【页面数据接口文档】 (Data Interface Documentation)
  ------------------------------------------------------------------------
  本页面文件: register.jsp
  页面描述: 用户注册页面，包含表单校验和错误提示。
            包含 POST 请求的自动封装逻辑 (Model 1 风格)。

  1. [Session 属性] 无

  2. [Request 属性] 无

  3. [Request 参数] (URL 参数)
     - 键名: "isRegister"
       类型: String
       值说明:
         "2" -> 用户名已存在 (注册失败)
         "0" -> 系统错误 (注册失败)
       来源: UserServlet (action=register)

  4. [数据流向]
     - 表单提交 -> UserServlet (action=register)
     - 注册成功 -> login.jsp?isRegister=1
     - 注册失败 -> register.jsp?isRegister=2 (重定向回本页)
  ========================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%
    // ==========================================
    // 1. 请求编码设置
    // ==========================================
    request.setCharacterEncoding("UTF-8");

    // ==========================================
    // 2. 自动封装与转发
    // ==========================================
    if ("POST".equalsIgnoreCase(request.getMethod())) {
%>
<jsp:useBean id="user" class="com.bookstore.bean.UserInfo" scope="request">
    <jsp:setProperty name="user" property="*"/>
</jsp:useBean>
<jsp:forward page="/userServlet?action=register"/>
<%
        return;
    }
%>

<%
    // 获取注册状态码 (错误提示用)
    String regStatus = request.getParameter("isRegister");
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>注册 - 麦田守望者书店</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=<%= System.currentTimeMillis() %>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-card">
        <div class="auth-header">
            <img src="${pageContext.request.contextPath}/static/img/smile.avif" alt="Logo" class="auth-logo">
            <h1 class="auth-title">加入我们</h1>
            <p class="auth-subtitle">注册成为麦田守望者会员</p>
        </div>

        <%-- 错误提示区域 --%>
        <% if("2".equals(regStatus)) { %>
        <div class="alert-box alert-error">
            <i class="fas fa-times-circle"></i> 注册失败：该用户名已被占用
        </div>
        <% } else if("0".equals(regStatus)) { %>
        <div class="alert-box alert-error">
            <i class="fas fa-exclamation-triangle"></i> 系统错误，请稍后再试
        </div>
        <% } %>

        <form action="" method="post" onsubmit="return validateRegister()">

            <div class="form-group">
                <input type="text" name="username" class="form-control" placeholder="设置用户名" required>
            </div>

            <div class="form-group">
                <input type="email" name="email" class="form-control" placeholder="电子邮箱" required>
            </div>

            <div class="form-group">
                <input type="password" name="password" id="reg-pwd" class="form-control" placeholder="设置密码 (8位数字或字母)" required>
                <div class="error-msg" id="err-pwd">密码格式错误：必须为8位数字或字母</div>
            </div>

            <div class="form-group">
                <input type="password" id="reg-confirm" class="form-control" placeholder="确认密码" required>
                <div class="error-msg" id="err-confirm">两次输入的密码不一致</div>
            </div>

            <button type="submit" class="btn-block">立即注册</button>
        </form>

        <div class="auth-footer-link">
            已有账号？ <a href="login.jsp" class="link-highlight">立即登录</a>
        </div>
        <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="auth-footer-link">
            <i class="fas fa-arrow-left"></i> 返回首页
        </a>
    </div>
</div>

<script>
    function validateRegister() {
        const pwd = document.getElementById('reg-pwd').value;
        const confirm = document.getElementById('reg-confirm').value;
        const errPwd = document.getElementById('err-pwd');
        const errConfirm = document.getElementById('err-confirm');
        const regex = /^[a-zA-Z0-9]{8}$/;

        let isValid = true;

        // 密码格式校验
        if (!regex.test(pwd)) {
            errPwd.classList.add('visible');
            isValid = false;
        } else {
            errPwd.classList.remove('visible');
        }

        // 密码一致性校验
        if (pwd !== confirm) {
            errConfirm.classList.add('visible');
            isValid = false;
        } else {
            errConfirm.classList.remove('visible');
        }

        return isValid;
    }
</script>
</body>
</html>