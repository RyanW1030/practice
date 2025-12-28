<%--
  =================================================================================
  【区域 1：页面数据接口文档】 (Data Interface Documentation)
  ---------------------------------------------------------------------------------
  ★ 规范说明：
  在此区域集中定义页面与后端的“契约”。
  ---------------------------------------------------------------------------------
  本页面文件: orderItems.jsp
  页面描述: 订单详情及支付页面。根据订单状态显示不同的交互组件。

  1. [Session 属性] user (核心依赖)
     - 键名: "user"
     - 类型: com.bookstore.bean.UserInfo
     - 来源: 用户登录后存入 Session
     - 作用: 顶部导航显示、支付余额校验。

  2. [Request 属性]
     - orderItems: LinkedHashMap<OrderItem, Book> (订单项列表)
     - currentOrderId: String (当前订单号)
     - userOrder: UserOrder (订单实体，提供状态、总金额、快照信息)

  3. [逻辑分支]
     - 状态 0 (未付款): 显示 "立即支付" 悬浮栏，校验余额。
     - 状态 1 (待发货): 显示物流卡片，无操作。
     - 状态 2 (已发货): 显示物流卡片，提示等待收货。
     - 状态 3 (已收货): [新增] 显示“交易完成”状态，显示物流卡片。

  4. [交互接口]
     - 支付跳转: /orderServlet?action=payment&order_id=[ID]
     - 返回列表: /orderServlet?action=orderList
  =================================================================================
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 引入必要的 Java 类库 --%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%-- 引入项目 Bean 类 --%>
<%@ page import="com.bookstore.bean.OrderItem" %>
<%@ page import="com.bookstore.bean.Book" %>
<%@ page import="com.bookstore.bean.UserOrder" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%
    // =============================================================================
    // 【区域 2：Java 数据处理区】 (Java Data Processing)
    // -----------------------------------------------------------------------------
    // ★ 规范说明：
    // 1. 集中处理所有 request 数据。
    // 2. 准备视图层所需的状态变量 (Title, Desc, Color)。
    // =============================================================================

    // -----------------------------------------------------------
    // 2.1 基础环境与参数获取
    // -----------------------------------------------------------
    String contextPath = request.getContextPath();

    // 接收核心数据
    String currentOrderId = (String) request.getAttribute("currentOrderId");
    UserOrder userOrder = (UserOrder) request.getAttribute("userOrder");
    LinkedHashMap<OrderItem, Book> orderMap = (LinkedHashMap<OrderItem, Book>) request.getAttribute("orderItems");

    // 获取用户信息 (用于余额校验)
    UserInfo user = (UserInfo) session.getAttribute("user");

    // -----------------------------------------------------------
    // 2.2 防空与兜底 (Null Safety)
    // -----------------------------------------------------------
    if (currentOrderId == null) currentOrderId = "未知订单";
    if (userOrder == null) userOrder = new UserOrder();
    if (user == null) {
        user = new UserInfo();
        user.setBalance(BigDecimal.ZERO);
        user.setUsername("游客");
    }

    // -----------------------------------------------------------
    // 2.3 业务逻辑计算
    // -----------------------------------------------------------
    int orderStatus = userOrder.getStatus(); // 0:未付款, 1:待发货, 2:已发货, 3:已收货
    BigDecimal totalMoney = userOrder.getTotal_money();
    BigDecimal userBalance = (user.getBalance() != null) ? user.getBalance() : BigDecimal.ZERO;

    // 余额是否充足
    boolean canAfford = userBalance.compareTo(totalMoney) >= 0;

    // 是否有商品数据
    boolean hasData = (orderMap != null && orderMap.size() > 0);

    // -----------------------------------------------------------
    // 2.4 状态显示配置 (View Model Preparation)
    // -----------------------------------------------------------
    String statusTitle = "";
    String statusDesc = "";
    String statusColor = "";
    String iconClass = "";
    String cardClass = "status-" + orderStatus; // 对应 CSS 类名

    if (orderStatus == 0) {
        statusTitle = "订单待支付";
        statusDesc = "请尽快完成支付，逾期订单将自动取消";
        statusColor = "#ff6b6b"; // 红
        iconClass = "fa-credit-card";
    } else if (orderStatus == 1) {
        statusTitle = "支付成功，等待发货";
        statusDesc = "商家正在打包您的商品，请耐心等待";
        statusColor = "#3498db"; // 蓝
        iconClass = "fa-box-open";
    } else if (orderStatus == 2) {
        statusTitle = "订单已发货";
        statusDesc = "商品正在飞速向您奔来，请留意查收";
        statusColor = "#2ecc71"; // 绿
        iconClass = "fa-shipping-fast";
    } else if (orderStatus == 3) {
        // [新增] 已收货状态配置
        statusTitle = "订单已签收";
        statusDesc = "交易已圆满完成，感谢您的惠顾";
        statusColor = "#27ae60"; // 深绿
        iconClass = "fa-check-circle"; // 完成图标
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>订单详情 - 麦田守望者</title>

    <%--
       =========================================================================
       【区域 3.1：CSS 样式区】 (Styles)
       -------------------------------------------------------------------------
    --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="<%=contextPath%>/static/css/style.css?v=<%=System.currentTimeMillis()%>">
</head>
<body class="cart-page-body">

<%--
   =========================================================================
   【区域 3.2：页面内容输出区】 (Page Content Output)
   -------------------------------------------------------------------------
--%>

<%-- 导航栏 --%>
<nav class="navbar">
    <div class="container">
        <a href="<%=contextPath%>/index.jsp" class="logo">
            <i class="fas fa-book-open"></i> 麦田守望者
        </a>
        <div class="nav-menu">
            <span class="nav-item">你好，<%= user.getUsername() %></span>
            <a href="<%=contextPath%>/index.jsp" class="nav-item">返回首页</a>
        </div>
    </div>
</nav>

<div class="container">
    <%-- 顶部边框颜色随状态变化 --%>
    <div class="cart-container" style="border-top: 4px solid <%=statusColor%>;">

        <%-- 1. 顶部状态卡片 --%>
        <div class="order-status-card <%=cardClass%>">
            <div class="status-icon-box">
                <div class="status-icon-circle" style="background-color: <%=statusColor%>;">
                    <i class="fas <%=iconClass%>"></i>
                </div>
                <div class="status-text">
                    <h2><%= statusTitle %></h2>
                    <p>订单号：<span style="font-family: monospace;"><%= currentOrderId %></span></p>
                    <p><%= statusDesc %></p>
                </div>
            </div>
            <div style="text-align: right;">
                <p style="font-size: 13px; color: #999;">订单金额</p>
                <p style="font-size: 24px; color: var(--accent-color); font-weight: bold;">
                    ￥<%= totalMoney %>
                </p>
            </div>
        </div>

        <%-- 2. 物流信息展示 (仅当已支付/发货/收货时显示) --%>
        <% if (orderStatus >= 1) { %>
        <div class="logistics-card">
            <div class="logistics-item">
                <i class="fas fa-map-marker-alt"></i>
                <span>收货地址：<%= (userOrder.getReceiver_address() != null) ? userOrder.getReceiver_address() : "地址未记录" %></span>
            </div>
            <div class="logistics-item">
                <i class="fas fa-phone-alt"></i>
                <span>联系电话：<%= (userOrder.getReceiver_phone() != null) ? userOrder.getReceiver_phone() : "电话未记录" %></span>
            </div>
        </div>
        <% } %>

        <%-- 3. 商品列表 --%>
        <table class="cart-table" style="margin-top: 20px;">
            <thead>
            <tr>
                <th width="45%">商品信息</th>
                <th width="15%">单价</th>
                <th width="15%">数量</th>
                <th width="15%">小计</th>
            </tr>
            </thead>
            <tbody>
            <%
                if (hasData) {
                    for (Map.Entry<OrderItem, Book> entry : orderMap.entrySet()) {
                        OrderItem item = entry.getKey();
                        Book book = entry.getValue();
            %>
            <tr class="cart-item-row">
                <td>
                    <div class="col-product">
                        <div class="cart-img-wrapper">
                            <img src="<%=contextPath + book.getImg_path()%>" alt="<%=book.getName()%>">
                        </div>
                        <div class="cart-info-text">
                            <span class="cart-book-title"><%=item.getName()%></span>
                            <span class="cart-book-author">作者：<%=book.getAuthor()%></span>
                            <span class="cart-book-author">出版社：<%=book.getPublisher()%></span>
                        </div>
                    </div>
                </td>
                <td class="col-price" style="padding-top: 40px;">
                    ￥<%=item.getPrice()%>
                </td>
                <td style="padding-top: 40px; color: #666; font-family: Arial;">
                    x <%=item.getCount()%>
                </td>
                <td class="col-total" style="padding-top: 40px;">
                    ￥<%=item.getTotal_price()%>
                </td>
            </tr>
            <%
                }
            } else {
            %>
            <tr>
                <td colspan="4" class="empty-cart">
                    <p>暂无订单数据</p>
                </td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>

        <%-- 4. 底部操作栏 (逻辑分支) --%>
        <% if (orderStatus == 0) { %>
        <%-- ==== 分支A：未付款，显示支付栏 ==== --%>
        <div class="payment-action-bar">
            <div class="balance-info">
                您的当前余额：<span class="balance-val">￥<%= userBalance %></span>
                <% if (!canAfford) { %>
                <span style="color: #e74c3c; margin-left: 10px;">
                                <i class="fas fa-exclamation-circle"></i> 余额不足
                            </span>
                <% } %>
            </div>
            <div>
                        <span style="margin-right: 15px; color: #666;">应付总额：
                            <strong style="color: var(--accent-color); font-size: 20px;">￥<%= totalMoney %></strong>
                        </span>
                <button class="btn-pay" onclick="handlePayment()">立即支付</button>
            </div>
        </div>
        <% } else { %>
        <%-- ==== 分支B：其他状态 (含已收货)，显示简单返回 ==== --%>
        <div class="cart-footer-bar" style="border-top:none; margin-top:20px; justify-content: flex-end;">
            <a href="<%=contextPath%>/orderServlet?action=orderList" class="btn-add">
                查看我的所有订单
            </a>
        </div>
        <% } %>

    </div>
</div>

<footer>
    <p>&copy; 2025 麦田守望者 System. All Rights Reserved.</p>
</footer>

<%--
   =========================================================================
   【区域 4：JS 代码区】 (JavaScript Logic)
   -------------------------------------------------------------------------
--%>
<script>
    function handlePayment() {
        // 获取 Java 计算出的布尔值
        var canAfford = <%= canAfford %>;
        var orderId = "<%= currentOrderId %>";
        var needed = "<%= totalMoney %>";
        var current = "<%= userBalance %>";

        if (canAfford) {
            if(confirm("确定使用余额支付 ￥" + needed + " 吗？")) {
                window.location.href = "<%=contextPath%>/orderServlet?action=payment&order_id=" + orderId;
            }
        } else {
            alert("支付失败！\n\n您的余额不足以支付当前订单。\n当前余额：￥" + current + "\n订单金额：￥" + needed + "\n\n请联系管理员或前往个人中心充值。");
        }
    }
</script>

</body>
</html>