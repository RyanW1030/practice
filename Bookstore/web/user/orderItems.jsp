<%--
  =================================================================================
  【区域 1：页面数据接口文档】 (Data Interface Documentation)
  ---------------------------------------------------------------------------------
  ★ 规范说明：
  在此区域集中定义页面与后端的“契约”。
  ---------------------------------------------------------------------------------
  本页面文件: orderItems.jsp
  页面描述: 订单详情及支付页面。支持显示“物理删除”或“已下架”的书籍快照信息。

  1. [Session 属性] user
     - 类型: com.bookstore.bean.UserInfo
     - 作用: 顶部导航及支付鉴权。

  2. [Request 属性]
     - orderItems: LinkedHashMap<OrderItem, Book>
       说明: 订单项与书籍对象的映射。
       注意: Book 对象可能为 null (已被物理删除) 或 stock=-1 (已下架)。
     - currentOrderId: String (当前订单号)
     - userOrder: UserOrder (订单实体)

  3. [交互接口]
     - 支付: /orderServlet?action=payment&order_id=[ID]
     ---------------------------------------------------------------------------------
  修改记录: 修复物理删除商品显示图片为 saled.jpg
  =================================================================================
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.bookstore.bean.OrderItem" %>
<%@ page import="com.bookstore.bean.Book" %>
<%@ page import="com.bookstore.bean.UserOrder" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%
    // =============================================================================
    // 【区域 2：Java 数据处理区】 (Java Data Processing)
    // =============================================================================

    String contextPath = request.getContextPath();

    // 数据源获取与判空
    String currentOrderId = (String) request.getAttribute("currentOrderId");
    UserOrder userOrder = (UserOrder) request.getAttribute("userOrder");
    LinkedHashMap<OrderItem, Book> orderMap = (LinkedHashMap<OrderItem, Book>) request.getAttribute("orderItems");
    UserInfo user = (UserInfo) session.getAttribute("user");

    if (currentOrderId == null) currentOrderId = "未知订单";
    if (userOrder == null) userOrder = new UserOrder();
    if (user == null) {
        user = new UserInfo();
        user.setBalance(BigDecimal.ZERO);
        user.setUsername("游客");
    }

    // 业务状态计算
    int orderStatus = userOrder.getStatus();
    BigDecimal totalMoney = userOrder.getTotal_money();
    BigDecimal userBalance = (user.getBalance() != null) ? user.getBalance() : BigDecimal.ZERO;

    boolean canAfford = userBalance.compareTo(totalMoney) >= 0;
    boolean hasData = (orderMap != null && orderMap.size() > 0);

    // 视图状态配置
    String statusTitle = "未知状态";
    String statusDesc = "暂无状态描述";
    String statusColor = "#999";
    String iconClass = "fa-question-circle";
    String cardClass = "status-" + orderStatus;

    if (orderStatus == 0) {
        statusTitle = "订单待支付";
        statusDesc = "请尽快完成支付，逾期订单将自动取消";
        statusColor = "#ff6b6b";
        iconClass = "fa-credit-card";
    } else if (orderStatus == 1) {
        statusTitle = "支付成功，等待发货";
        statusDesc = "商家正在打包您的商品，请耐心等待";
        statusColor = "#3498db";
        iconClass = "fa-box-open";
    } else if (orderStatus == 2) {
        statusTitle = "订单已发货";
        statusDesc = "商品正在飞速向您奔来，请留意查收";
        statusColor = "#2ecc71";
        iconClass = "fa-shipping-fast";
    } else if (orderStatus == 3) {
        statusTitle = "订单已签收";
        statusDesc = "交易已圆满完成，感谢您的惠顾";
        statusColor = "#27ae60";
        iconClass = "fa-check-circle";
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>订单详情 - 麦田守望者</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="<%=contextPath%>/static/css/style.css?v=<%=System.currentTimeMillis()%>">
</head>
<body class="cart-page-body">

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
    <div class="cart-container" style="border-top: 4px solid <%=statusColor%>;">

        <%-- 1. 顶部状态卡片 --%>
        <div class="order-status-card <%=cardClass%>">
            <div class="status-icon-box">
                <div class="status-icon-circle" style="background-color: <%=statusColor%>;">
                    <i class="fas <%=iconClass%>"></i>
                </div>
                <div class="status-text">
                    <h2><%= statusTitle %></h2>
                    <p>订单号：<span class="font-monospace"><%= currentOrderId %></span></p>
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

        <%-- 2. 物流信息 --%>
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
                <th width="15%">单价 (快照)</th>
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

                        // --- 状态判断 ---
                        boolean isPhysicalDeleted = (book == null);
                        boolean isSoftDeleted = (!isPhysicalDeleted && book.getStock() == -1);
                        boolean isInvalid = isPhysicalDeleted || isSoftDeleted;

                        // --- [修正点] 图片路径逻辑 ---
                        // 1. 如果物理删除 -> 使用 saled.jpg
                        // 2. 如果逻辑删除 -> 依然显示原图 (配合CSS置灰)
                        // 3. 正常情况 -> 显示原图
                        String imgPath;
                        if (isPhysicalDeleted) {
                            imgPath = "/static/img/book/saled.jpg";
                        } else {
                            imgPath = book.getImg_path();
                        }

                        String rowClass = isInvalid ? "item-invalid" : "";
                        String bookName = item.getName();
                        String author = (isPhysicalDeleted) ? "未知作者" : book.getAuthor();
                        String publisher = (isPhysicalDeleted) ? "未知出版社" : book.getPublisher();
            %>
            <tr class="cart-item-row <%=rowClass%>">
                <td>
                    <div class="col-product">
                        <div class="cart-img-wrapper">
                            <%-- onerror 依然指向 defaultCover，防止 saled.jpg 也加载失败 --%>
                            <img src="<%=contextPath + imgPath%>" alt="<%=bookName%>" onerror="this.src='<%=contextPath%>/static/img/book/defaultCover.jpg'">
                        </div>
                        <div class="cart-info-text">
                            <span class="cart-book-title">
                                <%=bookName%>

                                <% if (isPhysicalDeleted) { %>
                                    <span class="item-status-badge badge-danger-light">已失效</span>
                                <% } else if (isSoftDeleted) { %>
                                    <span class="item-status-badge badge-gray-light">已下架</span>
                                <% } %>
                            </span>

                            <span class="cart-book-author">作者：<%=author%></span>
                            <span class="cart-book-author">出版社：<%=publisher%></span>

                            <% if (isInvalid) { %>
                            <span class="snapshot-info"><i class="fas fa-history"></i> 此为历史订单快照数据</span>
                            <% } %>
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

        <%-- 4. 底部操作栏 --%>
        <% if (orderStatus == 0) { %>
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

<script>
    function handlePayment() {
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