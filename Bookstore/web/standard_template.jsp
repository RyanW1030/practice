<%--
  =================================================================================
  【区域 1：页面数据接口文档】 (Data Interface Documentation)
  ---------------------------------------------------------------------------------
  ★ 规范说明：
  在此区域集中定义页面与后端的“契约”。
  不写任何逻辑代码，仅用于描述页面依赖的数据源、参数和交互目标。
  ---------------------------------------------------------------------------------
  本页面文件: [文件名].jsp
  页面描述: [简短描述页面功能，例如：管理员后台核心页面]

  1. [Session 属性] (可选)
     - 键名: "admin"
       作用: 校验管理员登录权限，若为空则跳转至登录页。

  2. [Request 属性] (Controller 传递的数据)
     - 键名: "[dataList]"
       类型: ArrayList<BeanType>
       作用: [描述数据用途，例如：主要展示的数据列表]
     - 键名: "[categoryList]"
       类型: ArrayList<Category>
       作用: [描述数据用途，例如：下拉菜单的数据源]

  3. [Request 参数] (URL/Form 参数)
     - 参数名: "tab"
       类型: String (Default: "list")
       作用: 控制当前激活的视图模块。
     - 参数名: "id"
       类型: Integer
       作用: 指定操作对象的ID。

  4. [交互接口] (Form Action / AJAX URL)
     - [动作名]: /servlet?action=[method]
       参数: [列出关键参数]
  =================================================================================
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 引入必要的 Java 类库 --%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%-- 引入项目 Bean 类 (根据实际情况添加) --%>
<%-- <%@ page import="com.bookstore.bean.*" %> --%>

<%
  // =============================================================================
  // 【区域 2：Java 数据处理区】 (Java Data Processing)
  // -----------------------------------------------------------------------------
  // ★ 规范说明：
  // 1. 集中处理所有 request.getAttribute() 操作。
  // 2. 必须进行空值检查 (Null Safety)，赋予默认值，防止页面抛出 NPE。
  // 3. 进行简单的数据格式化（如日期），为 View 层准备纯净的数据。
  // 4. 声明本页面将要使用的所有全局变量。
  // =============================================================================

  // -----------------------------------------------------------
  // 2.1 基础环境与参数获取
  // -----------------------------------------------------------
  String contextPath = request.getContextPath();

  // 获取页面状态参数 (例如 tab 切换)，并设置默认值
  String currentTab = request.getParameter("tab");
  if (currentTab == null || currentTab.isEmpty()) {
    currentTab = "default_tab_name"; // [修改] 设置默认 Tab
  }

  // -----------------------------------------------------------
  // 2.2 数据源获取与判空 (Data Retrieval & Null Safety)
  // -----------------------------------------------------------
  // [示例] 获取主数据列表
  // ArrayList<Book> dataList = (ArrayList<Book>) request.getAttribute("dataList");
  // if (dataList == null) dataList = new ArrayList<>();

  // [示例] 获取辅助数据 (如分类下拉框)
  // ArrayList<Category> categoryList = (ArrayList<Category>) request.getAttribute("categoryList");
  // if (categoryList == null) categoryList = new ArrayList<>();

  // -----------------------------------------------------------
  // 2.3 工具类初始化
  // -----------------------------------------------------------
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>[页面标题]</title>

  <%--
     =========================================================================
     【区域 3.1：CSS 样式区】 (Styles)
     -------------------------------------------------------------------------
     ★ 规范说明：
     1. 优先引入公共样式文件。
     2. 页面特有的微调样式写在 <style> 块中。
     =========================================================================
  --%>
  <link rel="stylesheet" href="<%=contextPath%>/static/css/style.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet">

  <style>
    /* 页面特有样式 (Page Specific Styles) */
    .custom-helper { display: none; }
  </style>
</head>
<body>

<%--
   =========================================================================
   【区域 3.2：页面内容输出区】 (Page Content Output)
   -------------------------------------------------------------------------
   ★ 规范说明：
   1. 负责 HTML 结构输出。
   2. 尽量减少复杂的 Java 逻辑判断（<% if... %>），保持结构清晰。
   3. 使用 <%= var %> 输出变量。
   =========================================================================
--%>

<div class="layout-container">

  <aside class="sidebar">
    <a href="<%=contextPath%>/servlet?action=list&tab=moduleA"
       class="<%= "moduleA".equals(currentTab) ? "active" : "" %>">
      模块 A
    </a>
  </aside>

  <main class="main-content">

    <%-- <% if ("moduleA".equals(currentTab)) { %> --%>
    <div class="content-card">
      <div class="toolbar">
        <button onclick="openAddModal()">新增</button>
      </div>

      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>名称</th>
          <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%-- <% for(Item item : dataList) { %> --%>
        <tr>
          <td><%-- <%= item.getId() %> --%></td>
          <td><%-- <%= item.getName() %> --%></td>
          <td>
            <div id="data-<%-- <%= item.getId() %> --%>" style="display:none;">
              <input type="hidden" class="d-name" value="<%-- <%= item.getName() %> --%>">
            </div>

            <button onclick="openEditModal(<%-- <%= item.getId() %> --%>)">编辑</button>
          </td>
        </tr>
        <%-- <% } %> --%>
        </tbody>
      </table>
    </div>
    <%-- <% } %> --%>

  </main>
</div>

<%--
   [模块 C] 弹窗组件 (Modals)
   通常置于 body 底部，默认隐藏
--%>
<div id="dataModal" class="modal-overlay">
  <div class="modal-box">
    <h3>数据信息</h3>
    <form action="<%=contextPath%>/servlet" method="post">
      <input type="hidden" name="action" id="formAction" value="">
      <input type="hidden" name="id" id="dataId" value="0">

      <div class="form-group">
        <label>名称</label>
        <input type="text" name="name" id="dataName">
      </div>

      <div class="actions">
        <button type="button" onclick="closeModal()">取消</button>
        <button type="submit" id="btnSubmit">保存</button>
      </div>
    </form>
  </div>
</div>

<%--
   =========================================================================
   【区域 4：JS 代码区】 (JavaScript Logic)
   -------------------------------------------------------------------------
   ★ 规范说明：
   1. 负责页面交互逻辑、弹窗控制、表单提交修正。
   2. 严禁在此处直接书写 Java 代码 (<% ... %>)，除非用于输出常量路径。
   3. 所有的 DOM 操作应封装在函数中。
   =========================================================================
--%>
<script>
  // 常量定义
  const modal = document.getElementById('dataModal');
  const formAction = document.getElementById('formAction');
  const btnSubmit = document.getElementById('btnSubmit');

  /**
   * 打开新增弹窗
   * 功能：重置表单，设置 Action 为添加方法
   */
  function openAddModal() {
    // 1. 设置接口动作 -> add
    formAction.value = "addMethod";
    btnSubmit.innerText = "立即添加";

    // 2. 重置表单数据
    document.getElementById('dataId').value = "0";
    document.getElementById('dataName').value = "";

    // 3. 显示弹窗
    modal.classList.add('show');
  }

  /**
   * 打开编辑弹窗
   * 功能：从 Hidden DOM 读取数据回填，设置 Action 为更新方法
   * @param {number} id - 目标数据ID
   */
  function openEditModal(id) {
    // 1. 设置接口动作 -> update
    formAction.value = "updateMethod";
    btnSubmit.innerText = "保存修改";

    // 2. 获取隐藏域中的数据源
    const container = document.getElementById('data-' + id);
    if (!container) return; // 安全校验

    // 3. 回填表单
    document.getElementById('dataId').value = id;
    document.getElementById('dataName').value = container.querySelector('.d-name').value;

    // 4. 显示弹窗
    modal.classList.add('show');
  }

  /**
   * 关闭弹窗
   */
  function closeModal() {
    modal.classList.remove('show');
  }

  // 绑定点击遮罩关闭事件
  modal.addEventListener('click', function(e) {
    if (e.target === this) closeModal();
  });
</script>

</body>
</html>
