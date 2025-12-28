<%--
  =================================================================================
  【区域 1：页面数据接口文档】 (Data Interface Documentation)
  ---------------------------------------------------------------------------------
  ★ 规范说明：
  在此区域集中定义页面与后端的“契约”。
  ---------------------------------------------------------------------------------
  本页面文件: cart.jsp
  页面描述: 用户购物车展示页面，支持下架/库存状态检测、数量调整及统一删除操作。

  1. [Session 属性] user
     - 键名: "user"
     - 类型: UserInfo
     - 作用: 校验登录状态，获取 userId。

  2. [Request 属性]
     - 键名: "Cart_book"
       类型: Map<CartItem, Book>
       作用: 核心数据源。
       ★ 状态逻辑约定:
         - 若 Value(Book) 为 null -> 物理删除 (已下架)
         - 若 Book.stock == -1 -> 逻辑删除 (已下架)
         - 若 Book.stock < count -> 库存不足
     - 键名: "delete" [新增]
       类型: Integer
       作用: 删除操作结果状态码 (null: 无操作, 0: 失败, >0: 成功删除数量)

  3. [交互接口]
     - 更新数量: /cartServlet?action=update&id=XXX&count=XXX
     - 删除操作: /cartServlet?action=delete&deleteIds=XXX
       (说明: 单删传 "1"，批删传 "1,2,3"，后端通过 WebUtils.parseIntArray 解析)
     - 清空购物车: /cartServlet?action=clear
     - 结算跳转: /orderServlet?action=createOrder
  =================================================================================
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 引入必要的 Java 类库 --%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.bookstore.bean.CartItem" %>
<%@ page import="com.bookstore.bean.Book" %>
<%@ page import="com.bookstore.bean.UserInfo" %>

<%
    // =============================================================================
    // 【区域 2：Java 数据处理区】 (Java Data Processing)
    // -----------------------------------------------------------------------------
    // ★ 规范说明：
    // 1. 集中处理 request 数据与业务状态预计算。
    // =============================================================================

    // -----------------------------------------------------------
    // 2.1 基础环境与参数获取
    // -----------------------------------------------------------
    String contextPath = request.getContextPath();
    UserInfo user = (UserInfo) session.getAttribute("user");

    // 安全防御：未登录跳转
    if (user == null) {
        response.sendRedirect(contextPath + "/user/login.jsp");
        return;
    }

    // -----------------------------------------------------------
    // 2.2 数据源获取
    // -----------------------------------------------------------
    Map<CartItem, Book> cartMap = (Map<CartItem, Book>) request.getAttribute("Cart_book");

    // 获取删除操作结果 (用于 Toast 反馈)
    Integer deleteResult = (Integer) request.getAttribute("delete");

    // -----------------------------------------------------------
    // 2.3 业务逻辑预计算 (默认总数)
    // -----------------------------------------------------------
    int totalCount = 0;

    // 仅计算有效商品（未下架 且 库存充足）
    if (cartMap != null) {
        for (Map.Entry<CartItem, Book> entry : cartMap.entrySet()) {
            CartItem item = entry.getKey();
            Book book = entry.getValue();

            // 逻辑判断：有效商品才计入徽章总数
            if (book != null && book.getStock() != -1 && book.getStock() >= item.getCount()) {
                totalCount += item.getCount();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的购物车 - 网上书城</title>

    <%--
       =========================================================================
       【区域 3.1：CSS 样式区】 (Styles)
       -------------------------------------------------------------------------
    --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=<%= System.currentTimeMillis() %>">
</head>
<body class="cart-page-body">

<%--
   =========================================================================
   【区域 3.2：页面内容输出区】 (Page Content Output)
   -------------------------------------------------------------------------
--%>

<nav class="navbar">
    <div class="container">
        <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="logo">
            <i class="fas fa-book-open"></i> Bookstore
        </a>
        <div class="nav-menu">
            <div class="user-menu">
                <% if(user.getAvatar() != null && !user.getAvatar().isEmpty()) { %>
                <img src="${pageContext.request.contextPath}<%= user.getAvatar() %>" class="user-avatar-small">
                <% } else { %>
                <img src="${pageContext.request.contextPath}/static/img/avatar/default.jpg" class="user-avatar-small">
                <% } %>
                <span class="user-name"><%= user.getUsername() %></span>
            </div>
            <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="nav-item">继续购物</a>
        </div>
    </div>
</nav>

<div class="container cart-container">
    <div class="cart-header-title">
        全部商品 <span class="cart-count-badge" id="headerTotalCount"><%= totalCount %></span>
    </div>

    <% if (cartMap == null || cartMap.isEmpty()) { %>
    <div class="empty-cart">
        <i class="fas fa-shopping-cart" style="font-size: 60px; color: #ddd; margin-bottom: 20px;"></i>
        <p>购物车空空如也，去挑几本好书吧！</p>
        <a href="${pageContext.request.contextPath}/pageServlet?action=List" class="btn-hero" style="display:inline-block; margin-top:10px;">去逛逛</a>
    </div>
    <% } else { %>
    <table class="cart-table">
        <thead>
        <tr>
            <th width="5%"><input type="checkbox" id="checkAllHeader" checked onclick="toggleAll(this)"> 全选</th>
            <th width="45%">商品信息</th>
            <th width="12%">单价</th>
            <th width="15%">数量</th>
            <th width="12%">小计</th>
            <th width="10%">操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            for (Map.Entry<CartItem, Book> entry : cartMap.entrySet()) {
                CartItem item = entry.getKey();
                Book book = entry.getValue();

                // --- [核心逻辑判断] ---
                // 1. 是否已下架
                boolean isOffShelf = (book == null || book.getStock() == -1);
                // 2. 是否库存不足
                boolean isStockInsufficient = (!isOffShelf && book.getStock() < item.getCount());
                // 3. 是否有效可买
                boolean isValid = !isOffShelf && !isStockInsufficient;

                // 计算显示数据
                BigDecimal price = isOffShelf ? BigDecimal.ZERO : book.getPrice();
                BigDecimal lineTotal = price.multiply(new BigDecimal(item.getCount()));

                String imgPath = isOffShelf ? "/static/img/book/saled.jpg" : book.getImg_path();
                String bookName = (book != null) ? book.getName() : "该商品已失效";
                if (isOffShelf && book != null) bookName += " (已下架)";
        %>
        <tr class="cart-item-row <%= !isValid ? "disabled" : "" %>">
            <td>
                <input type="checkbox" class="item-check"
                       value="<%= item.getId() %>"
                       data-subtotal="<%= lineTotal %>"
                       onclick="updateSummary()"
                    <%= isValid ? "checked" : "disabled" %>>
            </td>

            <td>
                <div class="col-product">
                    <div class="cart-img-wrapper">
                        <img src="${pageContext.request.contextPath}<%= imgPath %>" alt="封面">

                        <%-- [遮罩层] --%>
                        <% if (isOffShelf) { %>
                        <div class="sold-out-mask"><span class="sold-out-badge">已下架</span></div>
                        <% } else if (isStockInsufficient) { %>
                        <div class="sold-out-mask"><span class="sold-out-badge">库存不足</span></div>
                        <% } %>
                    </div>

                    <div class="cart-info-text">
                        <span class="cart-book-title"><%= bookName %></span>
                        <% if (book != null) { %>
                        <div class="cart-book-meta">
                            <span>ISBN: <%= book.getIsbn() != null ? book.getIsbn() : "暂无" %></span>
                            <span>作者: <%= book.getAuthor() %></span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </td>

            <td class="col-price">
                <% if(!isOffShelf) { %>
                ¥<%= String.format("%.2f", price) %>
                <% } else { %>
                --
                <% } %>
            </td>

            <td>
                <div class="cart-qty-control">
                    <%-- 减号 --%>
                    <button class="cart-qty-btn"
                            onclick="updateItemCount('${pageContext.request.contextPath}/cartServlet?action=update&id=<%= item.getId() %>&count=<%= item.getCount() - 1 %>&user_id=<%= user.getId() %>')"
                            <%= (item.getCount() <= 1 || isOffShelf) ? "disabled" : "" %>>-</button>

                    <input type="text" class="cart-qty-input" value="<%= item.getCount() %>" readonly>

                    <%-- 加号 --%>
                    <button class="cart-qty-btn"
                            onclick="updateItemCount('${pageContext.request.contextPath}/cartServlet?action=update&id=<%= item.getId() %>&count=<%= item.getCount() + 1 %>&user_id=<%= user.getId() %>')"
                            <%= (isOffShelf || (book != null && item.getCount() >= book.getStock())) ? "disabled" : "" %>>+</button>
                </div>

                <%-- 状态提示 --%>
                <div style="font-size: 12px; margin-top: 5px;">
                    <% if (isOffShelf) { %>
                    <span style="color: #999;">商品已失效</span>
                    <% } else if (isStockInsufficient) { %>
                    <span class="text-danger"><i class="fas fa-exclamation-circle"></i> 库存不足 (剩 <%= book.getStock() %>)</span>
                    <% } else if(book.getStock() < 10) { %>
                    <span style="color: #e74c3c">库存紧张: <%= book.getStock() %></span>
                    <% } else { %>
                    <span style="color: #999;">库存充足</span>
                    <% } %>
                </div>
            </td>

            <td class="col-total">
                <span class="subtotal-display">¥<%= String.format("%.2f", lineTotal) %></span>
            </td>

            <td class="col-action">
                <%--
                   [修改]: 单项删除链接
                   使用 deleteIds 参数，指向 delete 方法
                --%>
                <a href="${pageContext.request.contextPath}/cartServlet?action=delete&deleteIds=<%= item.getId() %>&user_id=<%= user.getId() %>"
                   class="link-delete"
                   onclick="return confirm('确定要移除该商品吗？')">
                    删除
                </a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>

    <div class="cart-footer-bar">
        <div class="cart-footer-left">
            <input type="checkbox" id="checkAllFooter" checked onclick="toggleAll(this)">
            <label for="checkAllFooter" style="margin-left: 5px; cursor:pointer;">全选</label>

            <a href="javascript:void(0)" onclick="batchDelete()" class="link-delete" style="margin-left: 20px;">
                删除选中商品
            </a>
            <a href="${pageContext.request.contextPath}/cartServlet?action=clear&user_id=<%= user.getId() %>"
               class="link-delete" style="margin-left: 15px;"
               onclick="return confirm('确定要清空购物车吗？')">
                清空购物车
            </a>
        </div>
        <div class="cart-footer-right">
            <span class="total-price-label">已选 <strong style="color:var(--accent-color)" id="selectedCount">0</strong> 件商品，总价：</span>
            <span class="total-price-value" id="finalTotalPrice">0.00</span>

            <button class="btn-checkout" onclick="checkout()">去结算</button>
        </div>
    </div>
    <% } %>
</div>

<%--
   [组件] Toast 轻提示容器
--%>
<div id="toast-container">
    <i class="fas fa-info-circle"></i>
    <span id="toast-message"></span>
</div>

<%--
   =========================================================================
   【区域 4：JS 代码区】 (JavaScript Logic)
   -------------------------------------------------------------------------
--%>
<script>
    /**
     * Toast 提示函数
     */
    function showToast(message) {
        const toast = document.getElementById('toast-container');
        const toastMsg = document.getElementById('toast-message');

        toastMsg.innerText = message;
        toast.classList.add('show');

        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    // --- [结果反馈逻辑] 检测后端传来的 delete 状态码 ---
    <% if (deleteResult != null) { %>
    const delRes = <%= deleteResult %>;
    if (delRes > 0) {
        showToast("成功移除商品！");
    } else {
        showToast("删除失败，请重试。");
    }
    <% } %>

    /**
     * 全选/反选逻辑
     * 特性：自动跳过 disabled 的复选框
     */
    function toggleAll(source) {
        const checkboxes = document.querySelectorAll('.item-check:not(:disabled)');
        const footerCheck = document.getElementById('checkAllFooter');
        const headerCheck = document.getElementById('checkAllHeader');

        footerCheck.checked = source.checked;
        headerCheck.checked = source.checked;

        checkboxes.forEach(cb => {
            cb.checked = source.checked;
        });

        updateSummary();
    }

    /**
     * 更新总价与数量
     */
    function updateSummary() {
        const checkboxes = document.querySelectorAll('.item-check:checked:not(:disabled)');
        let total = 0.0;
        let count = 0;

        checkboxes.forEach(cb => {
            total += parseFloat(cb.getAttribute('data-subtotal'));
            count++;
        });

        document.getElementById('finalTotalPrice').innerText = total.toFixed(2);
        document.getElementById('selectedCount').innerText = count;

        // 联动全选框
        const validCheckboxes = document.querySelectorAll('.item-check:not(:disabled)');
        if(validCheckboxes.length > 0) {
            const isAllChecked = (checkboxes.length === validCheckboxes.length);
            document.getElementById('checkAllHeader').checked = isAllChecked;
            document.getElementById('checkAllFooter').checked = isAllChecked;
        }
    }

    /**
     * 结算跳转
     */
    function checkout() {
        const checkboxes = document.querySelectorAll('.item-check:checked:not(:disabled)');
        if (checkboxes.length === 0) {
            alert("请至少选择一件有效商品进行结算！\n(库存不足或下架商品无法结算)");
            return;
        }

        let ids = [];
        let total = 0.0;
        checkboxes.forEach(cb => {
            ids.push(cb.value);
            total += parseFloat(cb.getAttribute('data-subtotal'));
        });

        const idStr = ids.join(",");
        const totalPriceStr = total.toFixed(2);

        window.location.href = "${pageContext.request.contextPath}/orderServlet?action=createOrder&user_id=<%= user.getId() %>&cartItemIds=" + idStr + "&total_price=" + totalPriceStr;
    }

    /**
     * 批量删除
     */
    function batchDelete() {
        // 允许删除选中的（包括手动勾选的）
        const checkboxes = document.querySelectorAll('.item-check:checked');
        if (checkboxes.length === 0) {
            alert("请至少选择一件商品！");
            return;
        }
        if (!confirm("确定要删除选中的 " + checkboxes.length + " 件商品吗？")) { return; }

        let ids = [];
        checkboxes.forEach(cb => { ids.push(cb.value); });

        // [修改]: 构建 URL，参数名改为 deleteIds，Action 改为 delete
        window.location.href = "${pageContext.request.contextPath}/cartServlet?action=delete&deleteIds=" + ids.join(",") + "&user_id=<%= user.getId() %>";
    }

    function updateItemCount(url) {
        window.location.href = url;
    }

    // 初始化
    window.onload = updateSummary;
</script>

</body>
</html>