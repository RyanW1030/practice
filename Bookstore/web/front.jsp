<%--
  ========================================================================
  【页面数据接口文档】 (Data Interface Documentation)
  ------------------------------------------------------------------------
  本页面文件: front.jsp
  页面描述: 商城首页，展示轮播图、书籍列表、分类导航及分页信息。

  1. [Session 属性] user
     - 键名: "user"
     - 类型: com.bookstore.bean.UserInfo
     - 来源: UserServlet (登录成功后存入)
     - 作用:
       1. 判断用户登录状态 (显示登录/注册 vs 个人中心/注销)。
       2. 获取 user_id 用于加入购物车操作。
       3. 显示用户头像和昵称。
     - 键名: "addCartSuccess"
     - 类型: String ("true")
     - 来源: CartServlet
     - 作用: 用于判断是否显示“加入购物车成功”的 Toast 提示。

  2. [Request 属性] (来自 PageServlet)
     - 键名: "List"
       类型: List<Book>
       作用: 当前页展示的书籍列表数据。
     - 键名: "Recommend"
       类型: List<Book>
       作用: 轮播图展示的推荐书籍列表。
     - 键名: "currentCategoryName"
       类型: String
       作用: 当前展示的分类名称（如“计算机网络”），用于页面标题。
     - 键名: "categoryId"
       类型: String
       作用: 回显当前分类 ID，用于分页链接和状态保持。
     - 键名: "keyword"
       类型: String
       作用: 回显搜索关键词，用于分页链接和状态保持。

  3. [Request 参数] (URL 参数)
     - 键名: "page"
       类型: String (int)
       作用: 指定当前页码。
     - 键名: "categoryId"
       类型: String (int)
       作用: 按分类筛选书籍。
     - 键名: "keyword"
       类型: String
       作用: 按关键词搜索书籍。
     - 键名: "bookId"
       类型: String (int)
       作用: 从购物车操作返回时，用于自动滚动定位到该书籍位置。

  4. [数据流向]
     - 搜索提交 -> PageServlet (action=List)
     - 加入购物车 -> CartServlet (action=add)
     - 分页跳转 -> PageServlet (action=List)
  ========================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.bookstore.bean.Book" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%
  // ==========================================
  // 1. 后端数据接收与状态解析
  // ==========================================

  // [Session] 用户状态
  UserInfo user = (UserInfo) session.getAttribute("user");
  boolean isLogin = (user != null);

  // [Request] 状态保持：分类 ID
  String currentCategoryId = request.getParameter("categoryId");
  if (currentCategoryId == null) currentCategoryId = (String) request.getAttribute("categoryId");
  if (currentCategoryId == null) currentCategoryId = "";

  // [Request] 状态保持：搜索关键词
  String currentKeyword = request.getParameter("keyword");
  if (currentKeyword == null) currentKeyword = (String) request.getAttribute("keyword");
  if (currentKeyword == null) currentKeyword = "";

  // [Request] 状态保持：页码
  String pageParam = request.getParameter("page");
  int pageNum = 1;
  if (pageParam != null && !pageParam.isEmpty()) {
    try { pageNum = Integer.parseInt(pageParam); } catch (Exception e) {}
  }

  // [Request] 业务数据：分类名称 & 书籍列表
  String currentCategoryName = (String) request.getAttribute("currentCategoryName");
  if (currentCategoryName == null) currentCategoryName = "全部书籍";

  List<Book> allBooks = (List<Book>) request.getAttribute("List");
  if (allBooks == null) allBooks = new ArrayList<>();

  List<Book> recommendBooks = (List<Book>) request.getAttribute("Recommend");
  if (recommendBooks == null) recommendBooks = new ArrayList<>();

  // 前端分页计算逻辑 (若后端未分页，则在此切片)
  int pageSize = 8;
  int totalBooks = allBooks.size();
  int totalPages = (int) Math.ceil((double) totalBooks / pageSize);
  if (pageNum < 1) pageNum = 1;
  if (pageNum > totalPages && totalPages > 0) pageNum = totalPages;

  int startIndex = (pageNum - 1) * pageSize;
  int endIndex = Math.min(startIndex + pageSize, totalBooks);
  List<Book> displayBooks = (totalBooks > 0) ? allBooks.subList(startIndex, endIndex) : new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>麦田守望者书店</title>
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
          <a href="${pageContext.request.contextPath}/pageServlet?action=List">全部书籍</a>
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
        <input type="text" name="keyword" placeholder="搜索书名或作者..." value="<%= currentKeyword %>">
        <button type="submit"><i class="fas fa-search"></i></button>
      </form>
    </div>

    <div class="nav-menu">
      <% if(isLogin) { %>
      <a href="${pageContext.request.contextPath}/cartServlet?action=Map&user_id=${user.id}" class="nav-item" title="购物车" style="font-size: 18px;">
        <i class="fas fa-shopping-cart"></i>
      </a>
      <div class="nav-item user-menu">
        <img src="${pageContext.request.contextPath}<%= (user.getAvatar() != null && !user.getAvatar().isEmpty()) ? user.getAvatar() : "/static/img/avatar/default.jpg" %>" class="user-avatar-small">
        <span class="user-name"><%= user.getUsername() %></span>
        <div class="dropdown-content">
          <a href="/bookstore/userServlet?action=profile"><i class="fas fa-id-card"></i> 个人中心</a>
          <a href="<%=request.getContextPath()%>/orderServlet?action=orderList"><i class="fas fa-box"></i> 我的订单</a>
          <a href="${pageContext.request.contextPath}/cartServlet?action=Map&user_id=${user.id}"><i class="fas fa-shopping-cart"></i> 我的购物车</a>
          <div style="border-top: 1px solid #eee; margin: 5px 0;"></div>
          <a href="${pageContext.request.contextPath}/userServlet?action=logout" style="color: var(--accent-color);"><i class="fas fa-sign-out-alt"></i> 退出登录</a>
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
  <div class="hero-section">
    <div class="carousel" id="bookCarousel">
      <% if (!recommendBooks.isEmpty()) {
        for (int i = 0; i < recommendBooks.size(); i++) {
          Book b = recommendBooks.get(i);
      %>
      <div class="carousel-slide <%= (i == 0) ? "active" : "" %>">
        <div class="slide-content">
          <span style="color: #888; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; display:block; margin-bottom:10px;">
             <i class="fas fa-star" style="color:#f1c40f;"></i> Editor's Choice / 店长推荐
          </span>
          <h2><%= b.getName() %></h2>
          <p><%= (b.getIntro() != null) ? b.getIntro() : "暂无简介" %></p>
          <a href="${pageContext.request.contextPath}/pageServlet?id=<%= b.getId() %>&action=Detail" class="btn-hero">立即购买 <i class="fas fa-arrow-right"></i></a>
        </div>
        <div class="slide-image-wrapper">
          <img src="${pageContext.request.contextPath}<%= b.getImg_path() %>">
        </div>
      </div>
      <% }} else { %>
      <div class="carousel-slide active">
        <div class="slide-content"><h2>欢迎来到麦田守望者</h2><a href="#" class="btn-hero">开始探索</a></div>
      </div>
      <% } %>
      <div class="carousel-dots">
        <% for(int i=0; i<recommendBooks.size(); i++) { %>
        <div class="dot <%= (i==0)? "active":"" %>" onclick="switchSlide(<%= i %>)"></div>
        <% } %>
      </div>
    </div>
  </div>
</div>

<div class="container main-content">
  <div class="section-header">
    <h2 class="section-title"><%= currentCategoryName %></h2>
    <span style="color: #999; font-size: 14px; padding-bottom: 5px;">第 <%= pageNum %> / <%= totalPages %> 页</span>
  </div>

  <div class="book-grid">
    <% if (displayBooks.isEmpty()) { %>
    <div style="grid-column: 1/-1; text-align: center; padding: 60px; color: #999;">
      <i class="fas fa-box-open" style="font-size: 48px; margin-bottom: 20px;"></i>
      <p>暂无相关书籍数据</p>
    </div>
    <% } else { for (Book book : displayBooks) {
      boolean isOutOfStock = (book.getStock() <= 0);
      String cardClass = isOutOfStock ? "book-card sold-out" : "book-card";
    %>
    <div class="<%= cardClass %>" id="book_<%= book.getId() %>">
      <a href="${pageContext.request.contextPath}/pageServlet?id=<%= book.getId() %>&action=Detail" class="book-img-wrapper">
        <img src="${pageContext.request.contextPath}<%= book.getImg_path() %>">
        <% if (isOutOfStock) { %><div class="sold-out-mask"><span class="sold-out-badge">暂时缺货</span></div><% } %>
      </a>
      <div class="book-info">
        <a href="#" class="book-title" title="<%= book.getName() %>"><%= book.getName() %></a>
        <div class="book-author"><%= book.getAuthor() %></div>
        <div class="book-price-row">
          <span class="price">￥<%= book.getPrice() %></span>
          <% if (isOutOfStock) { %>
          <button class="btn-add disabled" disabled><i class="fas fa-ban"></i> 缺货</button>
          <% } else { %>
          <button class="btn-add" onclick="openCartModal(<%= book.getId() %>, '<%= book.getName() %>', <%= book.getStock() %>, <%= book.getPrice() %>)">
            <i class="fas fa-cart-plus"></i>
          </button>
          <% } %>
        </div>
      </div>
    </div>
    <% } } %>
  </div>

  <% if (totalPages > 1) {
    // 构建分页基础链接，保留 keyword 和 categoryId
    StringBuilder baseParams = new StringBuilder();
    baseParams.append("action=List");
    if(!currentCategoryId.isEmpty()) baseParams.append("&categoryId=").append(currentCategoryId);
    if(!currentKeyword.isEmpty()) baseParams.append("&keyword=").append(java.net.URLEncoder.encode(currentKeyword, "UTF-8"));
    String baseUrl = request.getContextPath() + "/pageServlet?" + baseParams.toString() + "&page=";
  %>
  <div class="pagination">
    <% if (pageNum > 1) { %><a href="<%= baseUrl + (pageNum - 1) %>" class="page-btn"><i class="fas fa-chevron-left"></i></a><% } %>
    <% for (int i = 1; i <= totalPages; i++) { %>
    <a href="<%= baseUrl + i %>" class="page-btn <%= (i == pageNum) ? "active" : "" %>"><%= i %></a>
    <% } %>
    <% if (pageNum < totalPages) { %><a href="<%= baseUrl + (pageNum + 1) %>" class="page-btn"><i class="fas fa-chevron-right"></i></a><% } %>
  </div>
  <% } %>
</div>

<footer>
  <div class="container"><p>&copy; 2025 麦田守望者书店</p></div>
</footer>

<div class="modal-overlay" id="cartModal">
  <div class="modal-box">
    <div class="modal-header">
      <h3 class="modal-title" id="modalBookName">书籍名称</h3>
      <span class="modal-stock">库存: <span id="modalStockNum">0</span></span>
    </div>
    <div class="modal-error" id="modalErrorMsg"></div>
    <div class="quantity-control">
      <button class="qty-btn" onclick="adjustQty(-1)"><i class="fas fa-minus"></i></button>
      <input type="text" class="qty-input" id="modalQty" value="1" readonly>
      <button class="qty-btn" onclick="adjustQty(1)"><i class="fas fa-plus"></i></button>
    </div>
    <div class="modal-actions">
      <button class="btn-modal btn-cancel" onclick="closeCartModal()">取消</button>
      <button class="btn-modal btn-confirm" onclick="confirmAddToCart()">确定加入 <span id="modalTotalPrice"></span></button>
    </div>
  </div>
</div>

<div id="toast-container">
  <i class="fas fa-check-circle" style="color: #2ecc71;"></i> 已成功加入购物车
</div>

<script>
  const isUserLoggedIn = <%= isLogin %>;

  // --- [状态保持] 获取 JSP 渲染时的状态变量 ---
  const currentCategoryId = "<%= currentCategoryId %>";
  const currentPage = "<%= pageNum %>";
  const currentKeyword = "<%= currentKeyword %>";

  let currentBookId = 0;
  let currentStock = 0;
  let currentPrice = 0.0;

  // --- Toast & 自动滚动逻辑 ---
  <%
     String success = (String) session.getAttribute("addCartSuccess");
     String lastBookId = request.getParameter("bookId");

     if("true".equals(success)) {
         session.removeAttribute("addCartSuccess");
  %>
  window.onload = function() {
    const toast = document.getElementById("toast-container");
    toast.classList.add("show");
    setTimeout(() => { toast.classList.remove("show"); }, 3000);

    const bookId = "<%= (lastBookId != null) ? lastBookId : "" %>";
    if (bookId) {
      const element = document.getElementById("book_" + bookId);
      if (element) {
        element.scrollIntoView({behavior: "smooth", block: "center"});
      }
    }
  };
  <% } %>

  function openCartModal(bookId, bookName, stock, price) {
    if (!isUserLoggedIn) {
      if(confirm("您尚未登录，是否前往登录页面？")) window.location.href = "${pageContext.request.contextPath}/user/login.jsp";
      return;
    }
    currentBookId = bookId;
    currentStock = stock;
    currentPrice = price;

    document.getElementById('modalBookName').innerText = bookName;
    document.getElementById('modalStockNum').innerText = stock;
    document.getElementById('modalQty').value = 1;
    document.getElementById('modalErrorMsg').innerText = "";
    updateTotalPrice(1);

    const confirmBtn = document.querySelector('.btn-confirm');
    if (stock <= 0) {
      confirmBtn.disabled = true;
      confirmBtn.style.opacity = 0.5;
      confirmBtn.style.cursor = 'not-allowed';
    } else {
      confirmBtn.disabled = false;
      confirmBtn.style.opacity = 1;
      confirmBtn.style.cursor = 'pointer';
    }

    const modal = document.getElementById('cartModal');
    modal.style.display = 'flex';
    setTimeout(() => modal.classList.add('show'), 10);
  }

  function closeCartModal() {
    const modal = document.getElementById('cartModal');
    modal.classList.remove('show');
    setTimeout(() => { modal.style.display = 'none'; }, 300);
  }

  function adjustQty(delta) {
    const qtyInput = document.getElementById('modalQty');
    let newQty = parseInt(qtyInput.value) + delta;
    if (newQty < 1) newQty = 1;
    if (newQty > currentStock) newQty = currentStock;
    qtyInput.value = newQty;
    updateTotalPrice(newQty);
  }

  function updateTotalPrice(qty) {
    document.getElementById('modalTotalPrice').innerText = "¥" + (qty * currentPrice).toFixed(2);
  }

  // --- 核心：确认添加并携带所有状态参数 ---
  function confirmAddToCart() {
    const qty = document.getElementById('modalQty').value;
    const user_id = "${user.id}";

    // 基础参数
    let url = "${pageContext.request.contextPath}/cartServlet?action=add" +
            "&user_id=" + user_id +
            "&book_id=" + currentBookId +
            "&count=" + qty;

    // [状态保持] 附加参数：分类、页码、搜索词
    if (currentCategoryId) url += "&categoryId=" + currentCategoryId;
    if (currentPage) url += "&page=" + currentPage;
    if (currentKeyword) url += "&keyword=" + encodeURIComponent(currentKeyword);

    window.location.href = url;
  }

  document.getElementById('cartModal').addEventListener('click', function(e) {
    if (e.target === this) closeCartModal();
  });

  // 轮播图逻辑
  let slideIndex = 0;
  const slides = document.querySelectorAll('.carousel-slide');
  const dots = document.querySelectorAll('.dot');
  function switchSlide(n) {
    if(!slides.length) return;
    slides.forEach(s => s.classList.remove('active'));
    dots.forEach(d => d.classList.remove('active'));
    slideIndex = n;
    if(slideIndex >= slides.length) slideIndex = 0;
    if(slideIndex < 0) slideIndex = slides.length -1;
    slides[slideIndex].classList.add('active');
    if(dots[slideIndex]) dots[slideIndex].classList.add('active');
  }
  setInterval(() => switchSlide(slideIndex + 1), 5000);
</script>
</body>
</html>