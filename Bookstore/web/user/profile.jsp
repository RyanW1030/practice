<%--
  ========================================================================
  【页面数据接口文档】 (Data Interface Documentation)
  ------------------------------------------------------------------------
  本页面文件: profile.jsp
  页面描述: 个人中心页面，整合了个人信息修改、密码修改(双重校验)、头像选择以及阅读偏好设置。

  1. [Session 属性] user
     - 键名: "user"
     - 类型: com.bookstore.bean.UserInfo
     - 来源: UserServlet (登录成功后存入，更新信息成功后需同步更新)
     - 作用:
       1. 校验登录状态 (未登录则重定向)。
       2. 回显基础信息 (用户名/余额/电话/邮箱/地址/头像)。
       3. 提供旧密码 (user.password) 用于前端逻辑：当用户未输入新密码时，提交此旧密码。

  2. [Request 属性] (来自 UserServlet?action=profile)
     - 键名: "allCategories"
       类型: List<com.bookstore.bean.Category>
       作用: 提供“阅读偏好”区域的所有可选项 (用于循环渲染 checkbox)。
     - 键名: "userPreferenceIds"
       类型: List<Integer> (或 Set<Integer>)
       作用: 包含当前用户已选的分类ID，用于判断 checkbox 是否应该被选中 (checked)。
     - 键名: "updateMsg" (可选)
       类型: String
       作用: 操作结果反馈 (如 "修改成功" 或 "修改失败")，用于触发页面底部的 Toast 弹窗。

  3. [Request 参数] 无直接依赖

  4. [数据流向]
     - 表单提交 -> UserServlet (action=update)
     - 提交参数详情:
       * id: 用户ID (hidden)
       * password: 最终密码 (hidden, name="password")。由 JS 逻辑控制：若新密码框为空则填入旧密码，否则填入新密码。
       * email: 电子邮箱
       * phone: 联系电话
       * address: 收货地址
       * avatar: 头像路径 (hidden, name="avatar")。由头像选择器更新。
       * preferences: 阅读偏好分类ID数组 (checkbox, name="preferences", 多值提交)。
  ========================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bookstore.bean.UserInfo" %>
<%@ page import="com.bookstore.bean.Category" %>
<%@ page import="java.util.*" %>
<%
    // ==========================================
    // 1. 后端数据接收与权限校验
    // ==========================================

    // [Session] 获取当前登录用户
    UserInfo user = (UserInfo) session.getAttribute("user");

    // 安全防御：未登录强制跳转
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    // [Request] 获取分类列表与用户偏好 (用于阅读偏好功能)
    List<Category> allCategories = (List<Category>) request.getAttribute("allCategories");
    List<Integer> userPreferenceIds = (List<Integer>) request.getAttribute("userPreferenceIds");

    // 防御性处理：防止空指针导致页面报错
    if (allCategories == null) allCategories = new ArrayList<>();
    if (userPreferenceIds == null) userPreferenceIds = new ArrayList<>();

    // 预置的头像资源列表 (修正了路径，去除了 /bookstore 前缀)
    List<String> avatarList = new ArrayList<>();
    avatarList.add("/static/img/avatar/Superman.jpg");
    avatarList.add("/static/img/avatar/Batman.jpg");
    avatarList.add("/static/img/avatar/Wonder Woman.jpg");
    avatarList.add("/static/img/avatar/Flash.jpg");
    avatarList.add("/static/img/avatar/Lantern.jpg");
    avatarList.add("/static/img/avatar/Cyborg.jpg");
    avatarList.add("/static/img/avatar/Hawkman.jpg");
    avatarList.add("/static/img/avatar/Manhunter.jpg");
    avatarList.add("/static/img/avatar/default.jpg");

    // [Request] 获取更新结果消息
    String updateMsg = (String) request.getAttribute("updateMsg");
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>个人中心 - 麦田守望者书店</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=<%= System.currentTimeMillis() %>">
</head>
<body class="profile-body">

<%-- 导航栏 --%>
<nav class="navbar">
    <div class="container">
        <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="logo">
            <i class="fas fa-book-open"></i> Bookstore
        </a>
        <div class="nav-menu">
            <div class="user-menu">
                <img src="${pageContext.request.contextPath}<%= (user.getAvatar() != null && !user.getAvatar().isEmpty()) ? user.getAvatar() : "/static/img/avatar/default.jpg" %>" class="user-avatar-small" id="navAvatar">
                <span class="user-name"><%= user.getUsername() %></span>
            </div>
            <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="nav-item">返回首页</a>
            <a href="${pageContext.request.contextPath}/cartServlet?action=Map&user_id=${user.id}" class="nav-item">购物车</a>
            <a href="${pageContext.request.contextPath}/userServlet?action=logout" class="nav-item" style="color:var(--accent-color)">退出</a>
        </div>
    </div>
</nav>

<%-- 个人中心主容器 --%>
<div class="profile-container">
    <div class="profile-header-bg"></div>

    <div class="profile-content">
        <%-- 头像与基本信息区 --%>
        <div style="display: flex; align-items: flex-end; gap: 20px; flex-wrap: wrap;">

            <%-- 头像 (点击可更换) --%>
            <div class="profile-avatar-wrapper" onclick="openAvatarModal()">
                <img src="${pageContext.request.contextPath}<%= (user.getAvatar() != null && !user.getAvatar().isEmpty()) ? user.getAvatar() : "/static/img/avatar/default.jpg" %>"
                     alt="Avatar" class="profile-avatar" id="currentProfileAvatar">
                <div class="avatar-overlay">
                    <i class="fas fa-camera" style="font-size: 24px; margin-bottom: 5px;"></i>
                    <span>更换头像</span>
                </div>
            </div>

            <%-- 姓名与余额 --%>
            <div class="profile-name-block">
                <div class="profile-title"><%= user.getUsername() %></div>
                <div class="profile-balance">
                    <i class="fas fa-wallet"></i> 账户余额: ¥<%= user.getBalance() %>
                </div>
            </div>
        </div>

        <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;">

        <%-- 信息编辑表单 --%>
        <form id="profileForm" action="${pageContext.request.contextPath}/userServlet?action=update" method="post" onsubmit="return validateAndSubmit()">
            <input type="hidden" name="id" value="<%= user.getId() %>">

            <%--
               ★ 隐藏域：真实密码提交字段
               Servlet 只认这个 name="password" 的字段。
               提交前 JS 会判断：如果用户没填新密码，就把旧密码填进去；否则填新密码。
            --%>
            <input type="hidden" name="password" id="realPasswordInput" value="<%= user.getPassword() %>">
            <%-- 暂存旧密码用于恢复 --%>
            <input type="hidden" id="oldPasswordBackup" value="<%= user.getPassword() %>">

            <%-- 隐藏域：头像路径 --%>
            <input type="hidden" name="avatar" id="avatarInput" value="<%= (user.getAvatar() != null) ? user.getAvatar() : "/static/img/avatar/default.jpg" %>">

            <div class="profile-form-grid">

                <%-- 第一行：用户名 & 电话 --%>
                <div class="profile-form-group">
                    <label>用户名</label>
                    <input type="text" class="profile-form-control" value="<%= user.getUsername() %>" readonly style="background-color: #f0f2f5; color: #888; cursor: not-allowed;">
                </div>
                <div class="profile-form-group">
                    <label>联系电话</label>
                    <input type="text" name="phone" class="profile-form-control" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" placeholder="请输入手机号">
                </div>

                <%-- 第二行：邮箱 & (空位) --%>
                <div class="profile-form-group">
                    <label>电子邮箱</label>
                    <input type="email" name="email" class="profile-form-control" value="<%= user.getEmail() != null ? user.getEmail() : "" %>" placeholder="绑定邮箱用于找回密码">
                </div>
                <%-- 空置单元格，为了对齐布局，或者你可以让邮箱占据整行 --%>
                <div class="profile-form-group"></div>

                <%--
                   ★ 第三行：修改密码区域 (双重确认)
                   注意：这两个 input 没有 name 属性，不会直接提交给后端，仅用于前端校验
                --%>
                <div class="profile-form-group password-group">
                    <label>新密码 <span style="color:#999; font-weight:400; font-size:12px;">(留空则不修改)</span></label>
                    <input type="password" id="newPass" class="profile-form-control" placeholder="请输入新密码">
                </div>

                <div class="profile-form-group password-group">
                    <label>确认新密码</label>
                    <input type="password" id="confirmPass" class="profile-form-control" placeholder="请再次输入新密码">
                    <div class="validation-error" id="pwdError"><i class="fas fa-exclamation-circle"></i> 两次输入的密码不一致</div>
                </div>

                <%-- 第四行：收货地址 (占据整行) --%>
                <div class="profile-form-group grid-full-width">
                    <label>默认收货地址</label>
                    <input type="text" name="address" class="profile-form-control" value="<%= user.getAddress() != null ? user.getAddress() : "" %>" placeholder="请输入详细收货地址">
                </div>

                <%-- 第五行：阅读偏好 (占据整行) --%>
                <div class="profile-preferences-block">
                    <div class="profile-preferences-title">
                        <i class="fas fa-heart" style="color: var(--accent-color);"></i> 阅读偏好设置
                        <span style="font-weight: 400; color: #999; font-size: 12px; margin-left: 5px;">(我们将根据您的选择推荐书籍)</span>
                    </div>

                    <div class="preference-tags-container">
                        <% if (allCategories.isEmpty()) { %>
                        <span style="color: #999; font-size: 13px;">暂无分类数据，请联系管理员。</span>
                        <% } else {
                            for (Category category : allCategories) {
                                // 判断当前分类是否在用户已选列表中
                                boolean isChecked = userPreferenceIds.contains(category.getId());
                        %>
                        <label class="preference-tag">
                            <%-- name="preferences" 使得 Servlet 可以通过 getParameterValues 接收数组 --%>
                            <input type="checkbox" name="preferences" value="<%= category.getId() %>" <%= isChecked ? "checked" : "" %>>
                            <span class="tag-visual"><%= category.getName() %></span>
                        </label>
                        <%   }
                        } %>
                    </div>
                </div>
            </div>

            <div class="profile-actions">
                <button type="submit" class="btn-save">
                    <i class="fas fa-save"></i> 保存所有修改
                </button>
            </div>
        </form>
    </div>
</div>

<%-- 头像选择弹窗 --%>
<div class="modal-overlay" id="avatarModal">
    <div class="modal-box" style="width: 450px;">
        <div class="modal-header">
            <h3 class="modal-title">选择头像</h3>
            <span class="modal-stock">挑选您喜欢的正义联盟成员</span>
        </div>

        <div class="avatar-grid">
            <% for(String path : avatarList) {
                boolean isSelected = path.equals(user.getAvatar());
                String selectedClass = isSelected ? "selected" : "";
            %>
            <div class="avatar-option <%= selectedClass %>" onclick="selectAvatar(this, '<%= path %>')">
                <img src="${pageContext.request.contextPath}<%= path %>">
            </div>
            <% } %>
        </div>

        <div class="modal-actions" style="margin-top: 20px;">
            <button class="btn-modal btn-cancel" onclick="closeAvatarModal()">取消</button>
            <button class="btn-modal btn-confirm" onclick="confirmAvatarChange()">确定更换</button>
        </div>
    </div>
</div>

<%-- Toast 提示 (用于显示修改成功/失败) --%>
<div id="toast-container">
    <i class="fas fa-info-circle"></i> <span id="toast-msg">操作成功</span>
</div>

<%-- 页脚 --%>
<footer>
    <div class="container">
        <p>&copy; 2025 麦田守望者书店 (The Catcher in the Rye Bookstore) | Course Design Project</p>
    </div>
</footer>

<script>
    // --- 核心校验逻辑：密码双重验证与赋值 ---
    function validateAndSubmit() {
        const newPass = document.getElementById('newPass').value.trim();
        const confirmPass = document.getElementById('confirmPass').value.trim();
        const errorMsg = document.getElementById('pwdError');
        const realPassInput = document.getElementById('realPasswordInput');
        const oldPassBackup = document.getElementById('oldPasswordBackup').value;

        // 1. 重置错误状态
        errorMsg.classList.remove('show');
        document.getElementById('confirmPass').classList.remove('error');

        // 2. 逻辑判断
        if (newPass === "") {
            // 情况A: 用户没填新密码 -> 将 hidden 域的值重置为旧密码
            realPassInput.value = oldPassBackup;
            return true;
        } else {
            // 情况B: 用户填了新密码 -> 校验一致性
            if (newPass !== confirmPass) {
                // 不一致 -> 阻止提交，显示错误
                errorMsg.classList.add('show');
                document.getElementById('confirmPass').classList.add('error');
                // 增加抖动动画提示用户
                document.getElementById('confirmPass').animate([
                    { transform: 'translateX(0)' },
                    { transform: 'translateX(-5px)' },
                    { transform: 'translateX(5px)' },
                    { transform: 'translateX(0)' }
                ], { duration: 200 });
                return false;
            } else {
                // 一致 -> 将 hidden 域的值更新为新密码
                realPassInput.value = newPass;
                return true;
            }
        }
    }

    // --- 头像逻辑 ---
    let tempAvatarPath = "";

    function openAvatarModal() {
        const modal = document.getElementById('avatarModal');
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('show'), 10);
    }

    function closeAvatarModal() {
        const modal = document.getElementById('avatarModal');
        modal.classList.remove('show');
        setTimeout(() => { modal.style.display = 'none'; }, 300);
    }

    function selectAvatar(element, path) {
        document.querySelectorAll('.avatar-option').forEach(el => el.classList.remove('selected'));
        element.classList.add('selected');
        tempAvatarPath = path;
    }

    function confirmAvatarChange() {
        if (tempAvatarPath) {
            document.getElementById('currentProfileAvatar').src = "${pageContext.request.contextPath}" + tempAvatarPath;
            document.getElementById('avatarInput').value = tempAvatarPath;
        }
        closeAvatarModal();
    }

    document.getElementById('avatarModal').addEventListener('click', function(e) {
        if (e.target === this) closeAvatarModal();
    });

    // --- 消息提示 (Toast) ---
    <% if(updateMsg != null && !updateMsg.isEmpty()) { %>
    window.onload = function() {
        const toast = document.getElementById("toast-container");
        const msgSpan = document.getElementById("toast-msg");
        msgSpan.innerText = "<%= updateMsg %>";

        if ("<%= updateMsg %>".includes("成功")) {
            toast.querySelector('i').className = "fas fa-check-circle";
            toast.querySelector('i').style.color = "#2ecc71";
        } else {
            toast.querySelector('i').className = "fas fa-times-circle";
            toast.querySelector('i').style.color = "#e74c3c";
        }

        toast.classList.add("show");
        setTimeout(() => { toast.classList.remove("show"); }, 3000);
    };
    <% } %>
</script>

</body>
</html>