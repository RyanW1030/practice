<%--
  =================================================================================
  【区域 1：页面数据接口文档】 (Data Interface Documentation)
  ---------------------------------------------------------------------------------
  ★ 规范说明：
  在此区域集中定义页面与后端的“契约”。
  ---------------------------------------------------------------------------------
  本页面文件: admin.jsp
  页面描述: 管理员后台核心页面，集成书籍管理、订单监控、用户管理(含批量删除/充值)。

  1. [Session 属性]
     - 键名: "admin" (Admin)
       作用: 校验管理员登录权限。

  2. [Request 属性] (数据源)
     - "bookList" (ArrayList<Book>) : 书籍列表
     - "userList" (ArrayList<UserInfo>) : 用户列表
     - "orderList" (ArrayList<UserOrder>) : 订单列表
     - "categoryList" (ArrayList<Category>) : 分类列表
     - "recycleList" (String "yes") : 标记是否为回收站模式

  3. [Request 属性] (操作结果状态码，Integer，1=成功, 0=失败)
     - 书籍操作: "add", "update", "delete", "erase", "recycleBooks"
     - 订单操作: "shipOrder"
     - 用户操作: "charge" (充值), "resetPassword" (重置密码), "delete" (删除用户)

  4. [Request 参数] (URL/Form 参数)
     - tab: "books" | "users" | "orders" (默认 "books")
     - action: 对应 Servlet 方法名
     - ids: 批量操作的 ID 字符串
     - balance: 用户最终余额 (注意：是原有余额+充值金额的总和)

  5. [交互接口]
     - 用户充值: /adminServlet?action=recharge (POST: id, balance, tab=users)
     - 批量删用户: /adminServlet?action=deleteUser (GET: ids, tab=users)
     - 重置密码: /adminServlet?action=resetPwd (GET: id, tab=users)
  =================================================================================
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 引入必要的 Java 类库 --%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%-- 引入项目 Bean 类 --%>
<%@ page import="com.bookstore.bean.UserInfo" %>
<%@ page import="com.bookstore.bean.Book" %>
<%@ page import="com.bookstore.bean.UserOrder" %>
<%@ page import="com.bookstore.bean.Category" %>

<%
    // =============================================================================
    // 【区域 2：Java 数据处理区】 (Java Data Processing)
    // -----------------------------------------------------------------------------
    // ★ 规范说明：
    // 1. 集中处理所有 request 数据获取与判空。
    // 2. 准备 View 层所需的纯净数据。
    // =============================================================================

    // -----------------------------------------------------------
    // 2.1 基础环境与参数获取
    // -----------------------------------------------------------
    String contextPath = request.getContextPath();

    // 获取当前激活的 Tab (优先 Attribute，其次 Parameter)
    String currentTab = (String) request.getAttribute("tab");
    if (currentTab == null || currentTab.isEmpty()) {
        currentTab = request.getParameter("tab");
    }
    // 设置默认 Tab
    if (currentTab == null || currentTab.isEmpty()) {
        currentTab = "books";
    }

    // -----------------------------------------------------------
    // 2.2 业务状态判断 (回收站模式)
    // -----------------------------------------------------------
    Object recycleAttr = request.getAttribute("recycleList");
    String recycleParam = request.getParameter("recycleList");
    boolean isRecycleMode = (recycleAttr != null && "yes".equals(recycleAttr.toString()))
            || (recycleParam != null && "yes".equals(recycleParam));

    // -----------------------------------------------------------
    // 2.3 搜索参数回显
    // -----------------------------------------------------------
    String paramKeyword = request.getParameter("keyword");
    if (paramKeyword == null) paramKeyword = "";

    String paramCategoryId = request.getParameter("categoryId");
    if (paramCategoryId == null) paramCategoryId = "";

    // -----------------------------------------------------------
    // 2.4 数据源获取与判空 (Data Retrieval & Null Safety)
    // -----------------------------------------------------------
    ArrayList<Book> bookList = (ArrayList<Book>) request.getAttribute("bookList");
    if (bookList == null) bookList = new ArrayList<>();

    ArrayList<UserInfo> userList = (ArrayList<UserInfo>) request.getAttribute("userList");
    if (userList == null) userList = new ArrayList<>();

    ArrayList<UserOrder> orderList = (ArrayList<UserOrder>) request.getAttribute("orderList");
    if (orderList == null) orderList = new ArrayList<>();

    ArrayList<Category> categoryList = (ArrayList<Category>) request.getAttribute("categoryList");
    if (categoryList == null) categoryList = new ArrayList<>();

    // -----------------------------------------------------------
    // 2.5 操作结果状态码获取 (用于 Toast 反馈)
    // -----------------------------------------------------------
    Integer addResult = (Integer) request.getAttribute("add");
    Integer updateResult = (Integer) request.getAttribute("update");
    Integer eraseResult = (Integer) request.getAttribute("erase");
    Integer recycleResult = (Integer) request.getAttribute("recycleBooks");
    Integer shipResult = (Integer) request.getAttribute("shipOrder");
    // 用户管理结果
    Integer chargeResult = (Integer) request.getAttribute("charge");
    Integer resetPwdResult = (Integer) request.getAttribute("resetPassword");
    Integer deleteResult = (Integer) request.getAttribute("delete");

    // -----------------------------------------------------------
    // 2.6 工具类初始化
    // -----------------------------------------------------------
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>后台管理系统 - 网上书城</title>

    <%--
       =========================================================================
       【区域 3.1：CSS 样式区】 (Styles)
       -------------------------------------------------------------------------
    --%>
    <link rel="stylesheet" href="<%=contextPath%>/static/css/style.css?v=<%= System.currentTimeMillis() %>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet">

    <style>
        /* 页面特有样式微调 */
        .admin-table th, .admin-table td { vertical-align: middle !important; }
        .text-center { text-align: center !important; }
        .text-left { text-align: left !important; }
        .text-right { text-align: right !important; }
        .text-nowrap { white-space: nowrap !important; min-width: 80px; }
        /* 充值弹窗内的余额显示 */
        .current-balance-display {
            font-size: 13px; color: #666; margin-bottom: 8px; font-weight: bold;
        }
    </style>
</head>
<body>

<%--
   =========================================================================
   【区域 3.2：页面内容输出区】 (Page Content Output)
   -------------------------------------------------------------------------
--%>

<div class="admin-layout">

    <%-- 侧边栏导航 --%>
    <aside class="admin-sidebar">
        <div class="admin-logo"><i class="fas fa-user-shield" style="margin-right: 10px;"></i> 管理后台</div>
        <nav class="sidebar-menu">
            <a href="<%=contextPath%>/adminServlet?action=List&tab=books" class="sidebar-item <%= "books".equals(currentTab) ? "active" : "" %>">
                <i class="fas fa-book"></i> 书籍管理
            </a>
            <a href="<%=contextPath%>/adminServlet?action=List&tab=orders" class="sidebar-item <%= "orders".equals(currentTab) ? "active" : "" %>">
                <i class="fas fa-clipboard-list"></i> 订单管理
            </a>
            <a href="<%=contextPath%>/adminServlet?action=List&tab=users" class="sidebar-item <%= "users".equals(currentTab) ? "active" : "" %>">
                <i class="fas fa-users"></i> 用户管理
            </a>
        </nav>
        <div class="admin-user-info">
            <img src="<%=contextPath%>/static/img/avatar/default.jpg" class="admin-avatar">
            <div>
                <div style="font-weight: bold; font-size: 14px;">Administrator</div>
                <div style="font-size: 12px; color: #95a5a6; margin-top: 2px;">超级管理员</div>
            </div>
            <a href="<%=contextPath%>/userServlet?action=logout" title="退出" style="margin-left: auto; color: #e74c3c;"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </aside>

    <%-- 主内容区 --%>
    <main class="admin-main">
        <header class="admin-header">
            <div class="page-title">
                <% if("books".equals(currentTab)) { %> 书籍列表管理 <% } %>
                <% if("users".equals(currentTab)) { %> 注册用户管理 <% } %>
                <% if("orders".equals(currentTab)) { %> 全平台订单监控 <% } %>
            </div>
            <div>
                <a href="<%=contextPath%>/index.jsp" target="_blank" class="btn-sm btn-edit"><i class="fas fa-external-link-alt"></i> 前往商城首页</a>
            </div>
        </header>

        <div class="admin-content">

            <%-- [模块 A] 书籍管理 --%>
            <% if ("books".equals(currentTab)) { %>
            <div class="admin-card">
                <div class="admin-toolbar">
                    <%-- 左侧按钮组 --%>
                    <div style="display:flex; gap:10px; align-items:center;">
                            <span style="font-size: 14px; color: #666; margin-right: 5px;">
                                <%= isRecycleMode ? "回收站" : "在售" %>：<%= bookList.size() %> 本
                            </span>
                        <% if (isRecycleMode) { %>
                        <button class="btn-toolbar-action btn-action-restore" onclick="batchRecycleBooks()"><i class="fas fa-trash-restore-alt"></i> 批量还原</button>
                        <button class="btn-toolbar-action btn-action-dark" onclick="batchEraseBooks()"><i class="fas fa-times-circle"></i> 彻底删除</button>
                        <% } else { %>
                        <button class="btn-toolbar-action btn-action-danger" onclick="batchDeleteBooks()"><i class="fas fa-trash-alt"></i> 批量下架</button>
                        <button class="btn-toolbar-action btn-action-primary" onclick="openAddBookModal()"><i class="fas fa-plus"></i> 新增书籍</button>
                        <% } %>
                    </div>
                    <%-- 右侧搜索 --%>
                    <div class="admin-search-form">
                        <% if (!isRecycleMode) { %>
                        <form action="<%=contextPath%>/adminServlet" method="get" style="display:flex; gap:8px;">
                            <input type="hidden" name="action" value="List">
                            <input type="hidden" name="tab" value="books">
                            <select name="categoryId" class="admin-search-select" onchange="this.form.submit()">
                                <option value="">全部分类</option>
                                <% for(Category c : categoryList) { String selected = String.valueOf(c.getId()).equals(paramCategoryId) ? "selected" : ""; %>
                                <option value="<%= c.getId() %>" <%= selected %>><%= c.getName() %></option>
                                <% } %>
                            </select>
                            <input type="text" name="keyword" class="admin-search-input" placeholder="搜索书名/作者..." value="<%= paramKeyword %>">
                            <button type="submit" class="btn-search-icon" title="搜索"><i class="fas fa-search"></i></button>
                        </form>
                        <a href="<%=contextPath%>/adminServlet?action=List&tab=books&recycleList=yes" class="btn-toggle-mode" title="查看回收站"><i class="fas fa-recycle"></i> 回收站</a>
                        <% } else { %>
                        <a href="<%=contextPath%>/adminServlet?action=List&tab=books" class="btn-toggle-mode" style="background:#eef6ff; color:var(--primary-color); border-color:#b3d7ff;"><i class="fas fa-arrow-left"></i> 返回列表</a>
                        <% } %>
                    </div>
                </div>
                <%-- 书籍表格 --%>
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th width="5%" class="text-center"><input type="checkbox" id="checkAllBooks" onclick="toggleAllBooks(this)" class="book-check"></th>
                        <th width="5%" class="text-center">ID</th>
                        <th width="7%" class="text-center">封面</th>
                        <th width="20%" class="text-left">书名</th>
                        <th width="12%" class="text-left">作者</th>
                        <th width="10%" class="text-center text-nowrap">分类</th>
                        <th width="9%" class="text-center text-nowrap">价格</th>
                        <th width="9%" class="text-center text-nowrap">库存</th>
                        <th width="9%" class="text-center text-nowrap">销量</th>
                        <th width="14%" class="text-center text-nowrap">操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for(Book b : bookList) {
                        String categoryName = "未知";
                        for(Category c : categoryList){ if(c.getId() == b.getCategory_id()) { categoryName = c.getName(); break; } }
                    %>
                    <tr>
                        <td class="text-center"><input type="checkbox" class="book-check" value="<%= b.getId() %>"></td>
                        <td class="text-center"><%= b.getId() %></td>
                        <td class="text-center"><img src="<%=contextPath%><%= b.getImg_path() %>" style="height: 40px; width: auto; border-radius: 4px; display:inline-block;"></td>
                        <td class="text-left" title="<%= b.getName() %>"><div style="white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width: 200px;"><%= b.getName() %></div></td>
                        <td class="text-left"><%= b.getAuthor() %></td>
                        <td class="text-center"><span class="badge badge-gray" style="white-space: nowrap; display: inline-block;"><%= categoryName %></span></td>
                        <td class="text-center" style="color: var(--accent-color); font-weight: bold;">￥<%= b.getPrice() %></td>
                        <td class="text-center"><%= b.getStock() < 0 ? "<span style='color:#999;'>已删除</span>" : (b.getStock() < 10 ? "<span style='color:red;font-weight:bold;'>" + b.getStock() + "</span>" : b.getStock()) %></td>
                        <td class="text-center"><%= b.getSales() %></td>
                        <td class="text-center text-nowrap">
                            <div id="data-<%= b.getId() %>" style="display:none;">
                                <input type="hidden" class="d-name" value="<%= b.getName() %>">
                                <input type="hidden" class="d-author" value="<%= b.getAuthor() %>">
                                <input type="hidden" class="d-price" value="<%= b.getPrice() %>">
                                <input type="hidden" class="d-stock" value="<%= b.getStock() %>">
                                <input type="hidden" class="d-cate" value="<%= b.getCategory_id() %>">
                                <input type="hidden" class="d-pub" value="<%= b.getPublisher() == null ? "" : b.getPublisher() %>">
                                <input type="hidden" class="d-isbn" value="<%= b.getIsbn() == null ? "" : b.getIsbn() %>">
                                <input type="hidden" class="d-img" value="<%=contextPath%><%= b.getImg_path() %>">
                                <textarea class="d-intro"><%= b.getIntro() == null ? "" : b.getIntro() %></textarea>
                            </div>
                            <div class="action-btn-group" style="justify-content: center;">
                                <% if (isRecycleMode) { %>
                                <button class="btn-sm btn-restore-sm" onclick="singleRecycleBook(<%= b.getId() %>, '<%= b.getName() %>')" title="还原"><i class="fas fa-trash-restore"></i></button>
                                <button class="btn-sm btn-dark-sm" onclick="singleEraseBook(<%= b.getId() %>, '<%= b.getName() %>')" title="彻底删除"><i class="fas fa-times"></i></button>
                                <% } else { %>
                                <button class="btn-sm btn-edit" onclick="openEditBookModal(<%= b.getId() %>)" title="编辑"><i class="fas fa-edit"></i></button>
                                <button class="btn-sm btn-danger" onclick="deleteSingleBook(<%= b.getId() %>, '<%= b.getName() %>')" title="下架"><i class="fas fa-trash"></i></button>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>

            <%-- [模块 B] 订单管理 --%>
            <% if ("orders".equals(currentTab)) { %>
            <div class="admin-card">
                <div class="admin-toolbar"><span>共 <%= orderList.size() %> 笔订单</span></div>
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th width="20%" class="text-left">订单号</th>
                        <th width="13%" class="text-center">下单时间</th>
                        <th width="7%" class="text-center">用户ID</th>
                        <th width="10%" class="text-right" style="padding-right: 20px;">金额</th>
                        <th width="12%" class="text-center text-nowrap">状态</th>
                        <th width="20%" class="text-left">收货信息</th>
                        <th width="18%" class="text-center text-nowrap">操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for(UserOrder o : orderList) {
                        String statusLabel = ""; String statusClass = ""; int s = o.getStatus();
                        if(s == 0) { statusLabel = "未付款"; statusClass = "badge-red"; }
                        else if(s == 1) { statusLabel = "待发货"; statusClass = "badge-blue"; }
                        else if(s == 2) { statusLabel = "已发货"; statusClass = "badge-orange"; }
                        else if(s == 3) { statusLabel = "已收货"; statusClass = "badge-green"; }
                        else { statusLabel = "未知"; statusClass = "badge-gray"; }
                    %>
                    <tr>
                        <td class="text-left"><span class="font-monospace"><%= o.getOrder_id() %></span></td>
                        <td class="text-center" style="font-size: 13px;"><%= (o.getCreate_time() != null) ? sdf.format(o.getCreate_time()) : "--" %></td>
                        <td class="text-center"><%= o.getUser_id() %></td>
                        <td class="text-right" style="color: var(--accent-color); font-weight: bold; padding-right: 20px;">￥<%= o.getTotal_money() %></td>
                        <td class="text-center text-nowrap"><span class="badge <%= statusClass %> status-badge"><%= statusLabel %></span></td>
                        <td class="text-left">
                            <div class="cell-address">
                                <div><i class="fas fa-map-marker-alt" style="color:#999; margin-right:4px;"></i><%= o.getReceiver_address() %></div>
                                <div style="margin-top:2px;"><i class="fas fa-phone" style="color:#999; margin-right:4px;"></i><%= o.getReceiver_phone() %></div>
                            </div>
                        </td>
                        <td class="text-center text-nowrap">
                            <% if(s == 1) { %>
                            <a href="<%=contextPath%>/adminServlet?action=shipOrder&order_id=<%= o.getOrder_id() %>&tab=orders" class="btn-sm btn-success"><i class="fas fa-shipping-fast"></i> 立即发货</a>
                            <% } else { %>
                            <span style="color: #bbb; font-size: 12px;">--</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>

            <%-- [模块 C] 用户管理 --%>
            <% if ("users".equals(currentTab)) { %>
            <div class="admin-card">
                <div class="admin-toolbar">
                    <div style="display:flex; gap:10px; align-items:center;">
                        <span style="font-size: 14px; color: #666; margin-right: 5px;">
                            共 <%= userList.size() %> 位注册用户
                        </span>
                        <%-- 批量删除按钮 --%>
                        <button class="btn-toolbar-action btn-action-danger" onclick="batchDeleteUsers()">
                            <i class="fas fa-trash-alt"></i> 批量删除
                        </button>
                    </div>
                </div>
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th width="5%" class="text-center">
                            <input type="checkbox" id="checkAllUsers" onclick="toggleAllUsers(this)" class="user-check">
                        </th>
                        <th class="text-center">ID</th>
                        <th class="text-center">头像</th>
                        <th class="text-left">用户名</th>
                        <th class="text-left">邮箱</th>
                        <th class="text-center">余额</th>
                        <th class="text-center">操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for(UserInfo u : userList) { %>
                    <tr>
                        <td class="text-center">
                            <input type="checkbox" class="user-check" value="<%= u.getId() %>">
                        </td>
                        <td class="text-center"><%= u.getId() %></td>
                        <td class="text-center">
                            <img src="<%=contextPath%><%= u.getAvatar() %>" class="admin-avatar">
                        </td>
                        <td class="text-left"><%= u.getUsername() %></td>
                        <td class="text-left"><%= u.getEmail() %></td>
                        <td class="text-center" style="color: var(--accent-color); font-weight: bold;">
                            ￥<%= u.getBalance() %>
                        </td>
                        <td class="text-center">
                            <div class="action-btn-group" style="justify-content: center;">
                                <%--
                                    [修改点] 充值按钮：传入 currentBalance
                                    注意：u.getBalance() 返回 BigDecimal，JS中直接作为数值处理
                                --%>
                                <button class="btn-sm btn-success"
                                        onclick="openRechargeModal(<%= u.getId() %>, '<%= u.getUsername() %>', <%= (u.getBalance()!=null?u.getBalance():0) %>)">
                                    <i class="fas fa-coins"></i> 充值
                                </button>

                                <a href="<%=contextPath%>/adminServlet?action=resetPwd&id=<%= u.getId() %>&tab=users"
                                   class="btn-sm btn-edit"
                                   onclick="return confirm('确定要重置该用户密码为 12345678 吗？')">
                                    <i class="fas fa-key"></i> 重置
                                </a>

                                <button class="btn-sm btn-danger" onclick="deleteSingleUser(<%= u.getId() %>, '<%= u.getUsername() %>')">
                                    <i class="fas fa-trash"></i> 删除
                                </button>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>

        </div>
    </main>
</div>

<%--
   [模块 D] 弹窗组件 (Modals)
--%>

<%-- 1. 书籍编辑/新增弹窗 --%>
<div class="modal-overlay" id="bookModal">
    <div class="modal-box" style="width: 700px;">
        <div class="modal-header"><h3 class="modal-title" id="modalTitle">书籍信息</h3></div>
        <form id="bookForm" action="" method="post" enctype="multipart/form-data">
            <input type="hidden" name="id" id="bookId" value="0">
            <div class="admin-form-row">
                <div class="form-group" style="flex: 2;"><label>书籍名称</label><input type="text" name="name" id="bookName" class="form-control" required></div>
                <div class="form-group" style="flex: 1;">
                    <label>所属分类</label>
                    <select name="category_id" id="bookCategory" class="form-select" required>
                        <option value="" disabled selected>请选择分类</option>
                        <% for(Category c : categoryList) { %><option value="<%= c.getId() %>"><%= c.getName() %></option><% } %>
                    </select>
                </div>
            </div>
            <div class="admin-form-row">
                <div class="form-group"><label>作者</label><input type="text" name="author" id="bookAuthor" class="form-control" required></div>
                <div class="form-group"><label>出版社</label><input type="text" name="publisher" id="bookPublisher" class="form-control"></div>
            </div>
            <div class="admin-form-row">
                <div class="form-group"><label>ISBN</label><input type="text" name="isbn" id="bookIsbn" class="form-control"></div>
                <div class="form-group"><label>价格</label><input type="number" step="0.01" name="price" id="bookPrice" class="form-control" required></div>
                <div class="form-group"><label>库存</label><input type="number" name="stock" id="bookStock" class="form-control" required></div>
            </div>
            <div class="form-group">
                <label>封面图片</label>
                <div class="file-upload-wrapper"><input type="file" name="cover_img" id="fileInput" accept="image/*" onchange="previewImage(this)"><div class="upload-placeholder"><i class="fas fa-cloud-upload-alt"></i><span>点击上传</span></div></div>
                <div class="img-preview-box" id="previewBox"><img id="previewImg" src=""></div>
            </div>
            <div class="form-group"><label>简介</label><textarea name="intro" id="bookIntro" class="form-textarea"></textarea></div>
            <div class="modal-actions">
                <button type="button" class="btn-modal btn-cancel" onclick="closeBookModal()">取消</button>
                <button type="submit" id="btnSubmit" class="btn-modal btn-confirm">保存信息</button>
            </div>
        </form>
    </div>
</div>

<%--
   2. [修改] 用户充值弹窗
   逻辑：输入增量金额 -> JS计算总额 -> 提交总额给后端
--%>
<div class="modal-overlay" id="rechargeModal">
    <div class="modal-box" style="width: 400px;">
        <div class="modal-header">
            <h3 class="modal-title">用户充值</h3>
            <p id="rechargeUserName" style="font-size: 14px; color: #666; margin-top: 5px;"></p>
        </div>
        <%-- onsubmit 绑定计算函数 --%>
        <form action="<%=contextPath%>/adminServlet?action=recharge&tab=users" method="post" onsubmit="return handleRechargeSubmit()">
            <input type="hidden" name="id" id="rechargeUserId" value="">

            <%-- 隐藏域：存储原有余额（用于JS计算） --%>
            <input type="hidden" id="rechargeOriginalBalance" value="0">

            <%-- 隐藏域：存储最终提交给Servlet的余额（name="balance"） --%>
            <input type="hidden" name="balance" id="rechargeFinalBalance" value="">

            <div class="form-group">
                <%-- 显示当前余额 --%>
                <div class="current-balance-display" id="currentBalanceText">当前余额：￥0.00</div>

                <label>充值金额 (￥)</label>
                <%-- 注意：这里的输入框没有 name 属性，不会直接提交给 Servlet --%>
                <input type="number" step="0.01" id="rechargeAmountInput" class="form-control" required placeholder="请输入充值金额" min="0.01">
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-modal btn-cancel" onclick="closeRechargeModal()">取消</button>
                <button type="submit" class="btn-modal btn-confirm" style="background-color: #28a745;">确认充值</button>
            </div>
        </form>
    </div>
</div>

<%-- Toast 轻提示容器 --%>
<div id="toast-container">
    <i class="fas fa-info-circle"></i>
    <span id="toast-message"></span>
</div>

<%--
   =========================================================================
   【区域 4：JS 代码区】 (JavaScript Logic)
   -------------------------------------------------------------------------
   ★ 规范说明：
   1. 负责页面交互逻辑、弹窗控制。
   2. 包含通用工具函数 (Toast, Checkbox) 和特定模块逻辑。
   =========================================================================
--%>
<script>
    // --- 1. 全局变量与工具函数 ---
    const baseUrl = "<%=contextPath%>/adminServlet";
    const modal = document.getElementById('bookModal');
    const rechargeModal = document.getElementById('rechargeModal');
    const previewBox = document.getElementById('previewBox');
    const previewImg = document.getElementById('previewImg');
    const fileInput = document.getElementById('fileInput');
    const bookForm = document.getElementById('bookForm');
    const btnSubmit = document.getElementById('btnSubmit');

    // 显示 Toast 提示
    function showToast(message) {
        const toast = document.getElementById('toast-container');
        const toastMsg = document.getElementById('toast-message');
        toastMsg.innerText = message;
        toast.classList.add('show');
        setTimeout(() => { toast.classList.remove('show'); }, 3000);
    }

    // 获取选中的 ID 字符串
    function getSelectedIds(selector) {
        const checkboxes = document.querySelectorAll(selector + ':checked');
        if (checkboxes.length === 0) { alert("请先选择要操作的项！"); return null; }
        let ids = []; checkboxes.forEach(cb => ids.push(cb.value)); return ids.join(",");
    }

    // --- 2. 服务端结果反馈 ---
    <% if (addResult != null) { %> showToast(<%= addResult > 0 %> ? "添加图书成功！" : "添加图书失败。"); <% } %>
    <% if (updateResult != null) { %> showToast(<%= updateResult > 0 %> ? "修改图书成功！" : "修改图书失败。"); <% } %>
    <% if (eraseResult != null) { %> showToast(<%= eraseResult > 0 %> ? "彻底删除成功！" : "彻底删除失败。"); <% } %>
    <% if (recycleResult != null) { %> showToast(<%= recycleResult > 0 %> ? "书籍还原成功！" : "还原失败。"); <% } %>
    <% if (shipResult != null) { %> showToast(<%= shipResult > 0 %> ? "发货成功！" : "发货失败。"); <% } %>
    <% if (chargeResult != null) { %> showToast(<%= chargeResult > 0 %> ? "充值成功！" : "充值失败。"); <% } %>
    <% if (resetPwdResult != null) { %> showToast(<%= resetPwdResult > 0 %> ? "密码重置成功！" : "重置失败。"); <% } %>
    <% if (deleteResult != null) { %> showToast(<%= deleteResult > 0 %> ? "删除操作成功！" : "删除失败。"); <% } %>

    // --- 3. 书籍模块交互 ---
    function toggleAllBooks(source) {
        document.querySelectorAll('.book-check').forEach(cb => cb.checked = source.checked);
    }
    function batchDeleteBooks() {
        const ids = getSelectedIds('.book-check'); if (!ids) return;
        if (!confirm("确定要将选中的书籍移入回收站吗？")) return;
        window.location.href = baseUrl + "?action=deleteBooks&deleteBooks=" + ids;
    }
    function batchRecycleBooks() {
        const ids = getSelectedIds('.book-check'); if (!ids) return;
        if (!confirm("确定要还原选中的书籍吗？")) return;
        window.location.href = baseUrl + "?action=recycleBooks&recycleBooks=" + ids;
    }
    function batchEraseBooks() {
        const ids = getSelectedIds('.book-check'); if (!ids) return;
        if (!confirm("警告：确定要【彻底删除】选中的书籍吗？")) return;
        window.location.href = baseUrl + "?action=eraseBooks&eraseBooks=" + ids;
    }
    function deleteSingleBook(id, name) {
        if (!confirm("确定要将《" + name + "》移入回收站吗？")) return;
        window.location.href = baseUrl + "?action=deleteBooks&deleteBooks=" + id;
    }
    function singleRecycleBook(id, name) {
        if (!confirm("确定要还原《" + name + "》吗？")) return;
        window.location.href = baseUrl + "?action=recycleBooks&recycleBooks=" + id;
    }
    function singleEraseBook(id, name) {
        if (!confirm("警告：彻底删除《" + name + "》后将无法恢复！")) return;
        window.location.href = baseUrl + "?action=eraseBooks&eraseBooks=" + id;
    }
    function openAddBookModal() {
        document.getElementById('modalTitle').innerText = "新增书籍";
        document.getElementById('bookId').value = "0";
        bookForm.action = baseUrl + "?action=addBooks";
        btnSubmit.innerText = "立即添加";
        ['bookName','bookAuthor','bookPrice','bookStock','bookCategory','bookPublisher','bookIsbn','bookIntro'].forEach(id => document.getElementById(id).value = "");
        fileInput.value = ""; previewBox.classList.remove('show'); previewImg.src = "";
        modal.classList.add('show');
    }
    function openEditBookModal(id) {
        document.getElementById('modalTitle').innerText = "编辑书籍 (ID: " + id + ")";
        document.getElementById('bookId').value = id;
        bookForm.action = baseUrl + "?action=updateBooks";
        btnSubmit.innerText = "保存修改";
        const container = document.getElementById('data-' + id);
        document.getElementById('bookName').value = container.querySelector('.d-name').value;
        document.getElementById('bookAuthor').value = container.querySelector('.d-author').value;
        document.getElementById('bookPrice').value = container.querySelector('.d-price').value;
        document.getElementById('bookStock').value = container.querySelector('.d-stock').value;
        document.getElementById('bookCategory').value = container.querySelector('.d-cate').value;
        document.getElementById('bookPublisher').value = container.querySelector('.d-pub').value;
        document.getElementById('bookIsbn').value = container.querySelector('.d-isbn').value;
        document.getElementById('bookIntro').value = container.querySelector('.d-intro').value;
        const currentImgPath = container.querySelector('.d-img').value;
        if(currentImgPath) { previewImg.src = currentImgPath; previewBox.classList.add('show'); } else { previewBox.classList.remove('show'); }
        fileInput.value = "";
        modal.classList.add('show');
    }
    function closeBookModal() { modal.classList.remove('show'); }
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) { previewImg.src = e.target.result; previewBox.classList.add('show'); }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // --- 4. 用户模块交互 ---
    function toggleAllUsers(source) {
        document.querySelectorAll('.user-check').forEach(cb => cb.checked = source.checked);
    }
    function batchDeleteUsers() {
        const ids = getSelectedIds('.user-check'); if (!ids) return;
        if (!confirm("警告：确定要批量删除这些用户吗？\n删除用户将同时清空其所有订单和购物车数据！")) return;
        window.location.href = baseUrl + "?action=deleteUser&ids=" + ids + "&tab=users";
    }
    function deleteSingleUser(id, name) {
        if (!confirm("警告：确定要删除用户 [" + name + "] 吗？\n此操作将级联删除其所有数据！")) return;
        window.location.href = baseUrl + "?action=deleteUser&ids=" + id + "&tab=users";
    }

    // 打开充值弹窗：接收当前余额
    function openRechargeModal(id, name, currentBalance) {
        document.getElementById('rechargeUserId').value = id;
        document.getElementById('rechargeUserName').innerText = "目标用户: " + name;

        // 1. 保存原有余额
        document.getElementById('rechargeOriginalBalance').value = currentBalance;
        // 2. 显示原有余额
        document.getElementById('currentBalanceText').innerText = "当前余额：￥" + parseFloat(currentBalance).toFixed(2);
        // 3. 清空输入框
        document.getElementById('rechargeAmountInput').value = "";

        rechargeModal.classList.add('show');
    }

    // 提交前计算：最终余额 = 原有 + 输入
    function handleRechargeSubmit() {
        var originalElem = document.getElementById('rechargeOriginalBalance');
        var inputElem = document.getElementById('rechargeAmountInput');
        var finalElem = document.getElementById('rechargeFinalBalance');

        var original = parseFloat(originalElem.value);
        var input = parseFloat(inputElem.value);

        if (isNaN(input) || input <= 0) {
            alert("请输入正确的充值金额！");
            return false;
        }

        // 核心修正逻辑：累加
        var total = original + input;

        // 赋值给隐藏域以便 Servlet 读取
        finalElem.value = total.toFixed(2);

        return true;
    }

    function closeRechargeModal() {
        rechargeModal.classList.remove('show');
    }

    // --- 5. 通用事件绑定 ---
    window.onclick = function(event) {
        if (event.target === modal) closeBookModal();
        if (event.target === rechargeModal) closeRechargeModal();
    }
</script>

</body>
</html>