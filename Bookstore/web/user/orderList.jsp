<%--
  =================================================================================
  【区域 1：页面数据接口文档】 (Data Interface Documentation)
  ---------------------------------------------------------------------------------
  ★ 规范说明：
  在此区域集中定义页面与后端的“契约”。
  ---------------------------------------------------------------------------------
  本页面文件: orderList.jsp
  页面描述: 我的订单列表页，展示当前登录用户的所有历史订单，支持查看详情、撤销未发货订单及确认收货。

  1. [Session 属性] user
     - 键名: "user"
     - 类型: UserInfo
     - 作用: 校验登录状态，获取 userId。

  2. [Request 属性] (Controller 传递的数据)
     - 键名: "OrderList"
       类型: ArrayList<UserOrder>
       作用: 订单列表数据源。
       ★ 状态定义 (bs14.sql):
          0 - 未付款 (Unpaid) -> 可撤销
          1 - 待发货 (Waiting) -> 可撤销
          2 - 已发货 (Shipped) -> [新增] 可确认收货
          3 - 已收货 (Received) -> 订单完成
     - 键名: "cancel" (撤单结果)
       类型: Integer
       作用: 撤销订单操作的结果状态码 (null: 无操作, 0: 失败, >0: 成功)
     - 键名: "confirm" (确认收货结果) [新增]
       类型: String ("yes")
       作用: 确认收货操作的反馈信号。

  3. [交互接口] (Form Action)
     - 查看详情: /orderServlet?action=List&order_id=XXX
     - 撤销订单: /orderServlet?action=cancelOrder&order_id=XXX
     - 确认收货: /orderServlet?action=confirm&order_id=XXX
  =================================================================================
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 引入必要的 Java 类库 --%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.math.BigDecimal" %>
<%-- 引入项目 Bean 类 --%>
<%@ page import="com.bookstore.bean.UserInfo" %>
<%@ page import="com.bookstore.bean.UserOrder" %>

<%
    // =============================================================================
    // 【区域 2：Java 数据处理区】 (Java Data Processing)
    // -----------------------------------------------------------------------------
    // ★ 规范说明：
    // 1. 集中处理所有 request.getAttribute() 操作。
    // 2. 必须进行空值检查 (Null Safety)。
    // =============================================================================

    // -----------------------------------------------------------
    // 2.1 基础环境与参数获取
    // -----------------------------------------------------------
    String contextPath = request.getContextPath();

    // 登录校验
    UserInfo user = (UserInfo) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(contextPath + "/user/login.jsp");
        return;
    }

    // -----------------------------------------------------------
    // 2.2 数据源获取与判空
    // -----------------------------------------------------------
    ArrayList<UserOrder> orderList = (ArrayList<UserOrder>) request.getAttribute("OrderList");
    boolean hasOrders = (orderList != null && orderList.size() > 0);

    // 获取操作反馈
    Integer cancelResult = (Integer) request.getAttribute("cancel");
    String confirmResult = (String) request.getAttribute("confirm"); // [新增]

    // -----------------------------------------------------------
    // 2.3 工具类初始化
    // -----------------------------------------------------------
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的订单 - 麦田守望者</title>

    <%--
       =========================================================================
       【区域 3.1：CSS 样式区】 (Styles)
       -------------------------------------------------------------------------
    --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="<%=contextPath%>/static/css/style.css?v=<%= System.currentTimeMillis() %>">

    <style>
        /* 页面特有列宽微调 */
        .col-oid { width: 28%; }
        .col-time { width: 20%; }
        .col-amount { width: 12%; }
        .col-status { width: 15%; }
        .col-op { width: 25%; }
    </style>
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
            <div class="user-menu">
                <% if(user.getAvatar() != null && !user.getAvatar().isEmpty()) { %>
                <img src="<%=contextPath + user.getAvatar()%>" class="user-avatar-small">
                <% } else { %>
                <img src="<%=contextPath%>/static/img/avatar/default.jpg" class="user-avatar-small">
                <% } %>
                <span class="user-name"><%= user.getUsername() %></span>
            </div>
            <a href="<%=contextPath%>/index.jsp" class="nav-item">返回首页</a>
        </div>
    </div>
</nav>

<%-- 主要内容区 --%>
<div class="container">
    <div class="cart-container">

        <%-- 标题 --%>
        <div class="cart-header-title">
            <i class="fas fa-clipboard-list" style="color: var(--primary-color);"></i>
            我的订单列表
            <% if(hasOrders) { %>
            <span class="cart-count-badge"><%= orderList.size() %></span>
            <% } %>
        </div>

        <%-- 列表逻辑 --%>
        <% if (!hasOrders) { %>
        <div class="empty-cart">
            <i class="fas fa-folder-open" style="font-size: 60px; color: #ddd; margin-bottom: 20px;"></i>
            <p>您还没有相关的订单记录</p>
            <a href="<%=contextPath%>/index.jsp" class="btn-checkout" style="text-decoration:none; background:var(--primary-color);">
                去商城逛逛
            </a>
        </div>
        <% } else { %>
        <table class="cart-table order-table">
            <thead>
            <tr>
                <th class="col-oid">订单号</th>
                <th class="col-time">下单时间</th>
                <th class="col-amount">订单金额</th>
                <th class="col-status">当前状态</th>
                <th class="col-op">操作</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (UserOrder order : orderList) {
                    int s = order.getStatus();
                    String statusText = "未知";
                    String statusClass = "status-0";
                    boolean canCancel = false;
                    boolean canConfirm = false; // [新增] 是否可确认收货

                    // 状态映射逻辑
                    switch (s) {
                        case 0:
                            statusText = "未付款";
                            statusClass = "status-0";
                            canCancel = true;
                            break;
                        case 1:
                            statusText = "待发货";
                            statusClass = "status-1";
                            canCancel = true;
                            break;
                        case 2:
                            statusText = "已发货";
                            statusClass = "status-2";
                            canCancel = false;
                            canConfirm = true; // [新增] 只有已发货状态才能确认收货
                            break;
                        case 3:
                            statusText = "已收货";
                            statusClass = "status-3";
                            canCancel = false;
                            break;
                    }
            %>
            <tr class="cart-item-row">
                <%-- 订单号 --%>
                <td><span class="order-id-font"><%= order.getOrder_id() %></span></td>

                <%-- 时间 --%>
                <td style="color: #666; font-size: 13px;">
                    <%= (order.getCreate_time() != null) ? sdf.format(order.getCreate_time()) : "--" %>
                </td>

                <%-- 金额 --%>
                <td><span class="col-total">￥<%= order.getTotal_money() %></span></td>

                <%-- 状态 --%>
                <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>

                <%-- 操作按钮组 --%>
                <td>
                    <div class="btn-action-group">
                        <a href="<%=contextPath%>/orderServlet?action=List&order_id=<%= order.getOrder_id() %>"
                           class="btn-view-detail" title="查看详情">
                            <i class="fas fa-eye" style="margin-right:4px;"></i> 详情
                        </a>

                        <%-- 撤销逻辑 --%>
                        <% if (canCancel) { %>
                        <a href="javascript:void(0)"
                           onclick="confirmCancel('<%= order.getOrder_id() %>')"
                           class="btn-cancel-order" title="撤销订单">
                            <i class="fas fa-undo-alt" style="margin-right:4px;"></i> 撤单
                        </a>
                        <% } %>

                        <%-- [新增] 确认收货逻辑 --%>
                        <% if (canConfirm) { %>
                        <a href="javascript:void(0)"
                           onclick="confirmReceipt('<%= order.getOrder_id() %>')"
                           class="btn-confirm-receipt" title="确认已收到商品">
                            <i class="fas fa-check-circle" style="margin-right:4px;"></i> 确认收货
                        </a>
                        <% } %>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <div class="cart-footer-bar" style="border-top:none; margin-top:0; justify-content:center; box-shadow:none;">
            <span style="color:#999; font-size:12px;">显示所有历史订单记录</span>
        </div>
        <% } %>

    </div>
</div>

<%--
   [组件] Toast 轻提示容器
--%>
<div id="toast-container">
    <i class="fas fa-info-circle"></i>
    <span id="toast-message"></span>
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
    // 基础路径
    const baseUrl = "<%=contextPath%>/orderServlet";

    // Toast 提示函数
    function showToast(message) {
        const toast = document.getElementById('toast-container');
        const toastMsg = document.getElementById('toast-message');

        toastMsg.innerText = message;
        toast.classList.add('show');

        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    // --- 结果反馈逻辑 ---

    // 撤单反馈
    <% if (cancelResult != null) { %>
    const cancelRes = <%= cancelResult %>;
    if (cancelRes > 0) {
        showToast("订单撤回成功！");
    } else {
        showToast("订单撤回失败，请稍后重试。");
    }
    <% } %>

    // [新增] 确认收货反馈
    <% if (confirmResult != null && "yes".equals(confirmResult)) { %>
    showToast("交易完成！感谢您的购买。");
    <% } %>

    // --- 交互逻辑 ---

    /**
     * 确认撤销订单
     */
    function confirmCancel(orderId) {
        if (confirm("确定要撤回该订单吗？\n撤回后无法恢复，需要重新下单。")) {
            window.location.href = baseUrl + "?action=cancelOrder&order_id=" + orderId;
        }
    }

    /**
     * [新增] 确认收货
     */
    function confirmReceipt(orderId) {
        if (confirm("请确认您已收到商品且无质量问题。\n确认收货后交易将完成。")) {
            window.location.href = baseUrl + "?action=confirm&order_id=" + orderId;
        }
    }
</script>

</body>
</html>