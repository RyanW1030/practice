<%--
  ========================================================================
  【页面数据接口文档】 (Data Interface Documentation)
  ------------------------------------------------------------------------
  本页面文件: detail.jsp
  页面描述: 书籍详情页面，展示单一书籍的详细信息，提供购买入口。

  1. [Session 属性] user
     - 键名: "user"
     - 类型: com.bookstore.bean.UserInfo
     - 来源: UserServlet
     - 作用: 判断登录状态，用于“加入购物车”和“立即购买”操作前的校验。

  2. [Request 属性] (来自 PageServlet action=Detail)
     - 键名: "book"
       类型: com.bookstore.bean.Book
       作用: 核心数据，展示书名、作者、价格、库存、简介等。
     - 键名: "category"
       类型: String
       作用: 展示书籍所属分类名称（面包屑导航、元数据展示）。

  3. [Request 参数] 无直接依赖
     - 依赖: 页面内部 JS 逻辑依赖 user.id (从 Session 取)。

  4. [数据流向]
     - 加入购物车 -> CartServlet (action=add)
     - 立即购买 -> CartServlet (action=add&isBuyNow=true)
  ========================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bookstore.bean.Book" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%
    // ==========================================
    // 1. 后端数据接收
    // ==========================================
    UserInfo user = (UserInfo) session.getAttribute("user");
    boolean isLogin = (user != null);

    Book book = (Book) request.getAttribute("book");
    String categoryName = (String) request.getAttribute("category");

    // 防御性编程：如果数据缺失，返回列表页
    if (book == null) {
        response.sendRedirect(request.getContextPath() + "/pageServlet?action=List");
        return;
    }
    if (categoryName == null) {
        categoryName = "全部书籍";
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= book.getName() %> - 书籍详情</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=<%= System.currentTimeMillis() %>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet">
</head>
<body>

<nav class="navbar">
    <div class="container">
        <div class="nav-menu">
            <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="logo">
                <i class="fas fa-book-open"></i> 麦田守望者
            </a>
            <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="nav-item">首页</a>
            <div class="nav-item">
                书籍分类 <i class="fas fa-chevron-down" style="font-size: 12px;"></i>
                <div class="dropdown-content">
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=1">数据结构与算法</a>
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=2">计算机网络</a>
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=3">数据库</a>
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=4">计算机组成原理</a>
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=5">人工智能</a>
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=6">Java</a>
                    <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=7">C语言</a>
                </div>
            </div>
        </div>

        <div class="search-box">
            <form action="${pageContext.request.contextPath}/pageServlet" method="get">
                <input type="hidden" name="action" value="List">
                <input type="text" name="keyword" placeholder="搜索书名或作者...">
                <button type="submit"><i class="fas fa-search"></i></button>
            </form>
        </div>

        <div class="nav-menu">
            <% if(isLogin) { %>
            <a href="${pageContext.request.contextPath}/cart.jsp" class="nav-item" title="购物车" style="font-size: 18px;">
                <i class="fas fa-shopping-cart"></i>
            </a>
            <div class="nav-item user-menu">
                <img src="${pageContext.request.contextPath}<%= (user.getAvatar() != null && !user.getAvatar().isEmpty()) ? user.getAvatar() : "/static/img/avatar/default.jpg" %>" class="user-avatar-small">
                <span class="user-name"><%= user.getUsername() %></span>
                <div class="dropdown-content">
                    <a href="profile.jsp"><i class="fas fa-id-card"></i> 个人中心</a>
                    <a href="orders.jsp"><i class="fas fa-box"></i> 我的订单</a>
                    <a href="${pageContext.request.contextPath}/cartServlet?action=Map&user_id=${user.id}"><i class="fas fa-shopping-cart"></i> 我的购物车</a>
                    <div style="border-top: 1px solid #eee; margin: 5px 0;"></div>
                    <a href="logout.jsp" style="color: var(--accent-color);"><i class="fas fa-sign-out-alt"></i> 退出登录</a>
                </div>
            </div>
            <% } else { %>
            <a href="${pageContext.request.contextPath}/user/login.jsp" class="nav-item">登录</a>
            <a href="${pageContext.request.contextPath}/user/register.jsp" class="nav-item btn-nav-register">注册</a>
            <% } %>
        </div>
    </div>
</nav>

<div class="container">
    <div class="detail-container">
        <%-- 左侧：封面图 --%>
        <div class="detail-image-section">
            <img src="${pageContext.request.contextPath}<%= book.getImg_path() %>" alt="<%= book.getName() %>">
        </div>

        <%-- 右侧：详细信息 --%>
        <div class="detail-info-section">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/pageServlet?action=List">首页</a>
                <span> / </span>
                <a href="${pageContext.request.contextPath}/pageServlet?action=List&categoryId=<%= book.getCategory_id() %>"><%= categoryName %></a>
                <span> / </span>
                <span>正文</span>
            </div>

            <h1 class="detail-title"><%= book.getName() %></h1>
            <div class="detail-author">
                作者：<%= book.getAuthor() %>
            </div>

            <div class="detail-price-row">
                <div class="detail-price"><%= book.getPrice() %></div>
                <div class="stock-badge">库存: <%= book.getStock() %></div>
                <div class="sales-count">已售: <%= book.getSales() %> 件</div>
            </div>

            <div class="meta-grid">
                <div class="meta-item"><span class="meta-label">出版社:</span> <%= book.getPublisher() %></div>
                <div class="meta-item"><span class="meta-label">ISBN:</span> <%= book.getIsbn() %></div>
                <div class="meta-item"><span class="meta-label">编号:</span> <%= book.getId() %></div>
                <div class="meta-item"><span class="meta-label">分类:</span> <%= categoryName %></div>
            </div>

            <div class="detail-intro">
                <h3 class="intro-title">内容简介</h3>
                <div class="intro-content">
                    <%= (book.getIntro() != null && !book.getIntro().isEmpty()) ? book.getIntro() : "暂无详细介绍。" %>
                </div>
            </div>

            <div class="action-buttons">
                <button class="btn-lg btn-secondary" onclick="addToCart(<%= book.getId() %>)">
                    <i class="fas fa-cart-plus"></i> 加入购物车
                </button>
                <button class="btn-lg btn-primary" onclick="buyNow(<%= book.getId() %>)">
                    <i class="fas fa-bolt"></i> 立即购买
                </button>
            </div>
        </div>
    </div>
</div>

<footer>
    <div class="container">
        <p>&copy; 2025 麦田守望者书店 (The Catcher in the Rye Bookstore) | Course Design Project</p>
    </div>
</footer>

<script>
    const isUserLoggedIn = <%= isLogin %>;
    const currentUserId = "<%= isLogin ? user.getId() : "" %>";

    function addToCart(bookId) {
        if (!isUserLoggedIn) {
            if(confirm("您尚未登录，无法添加商品到购物车。\n是否立即前往登录页面？")) {
                window.location.href = "${pageContext.request.contextPath}/user/login.jsp";
            }
            return;
        }
        // 注意：这里需要带上 userId 参数
        window.location.href = "${pageContext.request.contextPath}/cartServlet?action=add&bookId=" + bookId + "&userId=" + currentUserId + "&count=1";
    }

    function buyNow(bookId) {
        if (!isUserLoggedIn) {
            if(confirm("您尚未登录，无法购买。\n是否立即前往登录页面？")) {
                window.location.href = "${pageContext.request.contextPath}/user/login.jsp";
            }
            return;
        }
        window.location.href = "${pageContext.request.contextPath}/cartServlet?action=add&bookId=" + bookId + "&userId=" + currentUserId + "&count=1&isBuyNow=true";
    }
</script>

</body>
</html>