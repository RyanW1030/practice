package com.bookstore.controller;

import com.bookstore.bean.*;
import com.bookstore.service.Impl.*;
import com.bookstore.utils.WebUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebFilter;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name="adminServlet",value = "/adminServlet")
@MultipartConfig(maxFileSize = 1024*1024*10)
public class adminServlet extends baseServlet{
    userServiceImpl userService=new userServiceImpl();
    bookServiceImpl bookService=new bookServiceImpl();
    UserOrderServiceImpl userOrderService=new UserOrderServiceImpl();
    adminServiceImpl adminService=new adminServiceImpl();
    categoryServiceImpl categoryService=new categoryServiceImpl();
    protected void List(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        ArrayList<UserInfo> users = userService.List();
        String categoryId = request.getParameter("categoryId");
        String keyword = request.getParameter("keyword");
        ArrayList<Book> books;
        if(WebUtils.getValue(request,"recycleList")!=null){
            books=bookService.recycleList();
        }
        else {
            books = bookService.List(categoryId, keyword);
        }
        ArrayList<UserOrder> orders = userOrderService.List();
        ArrayList<Category> categoryList= categoryService.List();
        request.setAttribute("userList",users);
        request.setAttribute("bookList",books);
        request.setAttribute("orderList",orders);
        request.setAttribute("categoryList",categoryList);
        request.getRequestDispatcher("/admin/admin.jsp").forward(request,response);
    }
    protected void login(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        Admin admin = WebUtils.param2Bean(request, Admin.class);
        Admin loginAdmin = adminService.login(admin);
        if(loginAdmin==null){
                request.setAttribute("isLogin",false);
                request.getRequestDispatcher("/user/login.jsp").forward(request,response);
        }
        else {
            request.getSession().setAttribute("admin",loginAdmin);
            List(request,response);
        }
    }

    protected void addBooks(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        /*
        * 此处需注意，上传后的文件并未保存在源代码，即IDEA左侧 项目视图内的文件夹内。
        * 究其原因，本质上说，任何程序都是源代码编译后的可执行文件
        * 源代码可执行文件
        * ——在普通Java程序中分别对应*.java和*.class文件
        * ——在Java Web程序中对应模块目录（项目名/模块名）和工件目录（项目名/out/artifacts/模块名_war_exploded）
        * 因此，对于运行中的web项目，上传图片会保存到工件目录，而非模块目录
        * 此时，由于模块目录中文件并未更新，会导致项目再次被部署（重新编译生成工件）后，工件中不含一切上次部署时添加的文件
        * 有两种手段可以解决该问题：
        * ①  作为管理员，每次在管理员端上传文件后，在工件目录中找到这张图片，手动将文件添加到模块路径，避免下次重新部署时丢失
        * 一定要保证是工件目录下的文件，因为这个文件通过WebUtils中的upload方法重命名，确保不会和文件夹中的其它图片重名
        * （这并非多余行为，假如纯粹手动添加，无法如管理员端添加那样把数据同步到数据库）
        * ②  在Tomcat的配置文件中添加一组映射，使每次Tomcat每次读取资源时都前往指定目录而非工件目录，具体代码如下？
        * 在Tomcat目录/conf/server.xml末尾添加代码：
        * <Context path="/static/img/book" docBase="资源绝对路径" reloadable="true" />
        * 此处资源绝对路径你可以任意指定，例如："D:/Project/img"
        * 此时，你的上传和读取会都发生在这个目录，由于该目录不会因为工件的更新而变化，因此可视为持久性存储
        * 但此时值得注意的是，这种配置会将任何相对路径为"/static/img/book"的工件路径映射到你指定的路径下
        * 换言之，如果另外一个项目恰好也有这样一个相对路径，那么这个映射对这个新项目依然会有效。
        * 在本项目示例中，我们采用的是第一种“笨”办法完成图片上传。
        * */
        Book book = WebUtils.param2Bean(request, Book.class);
        String upload = WebUtils.upload(request);
        if(upload!=null){
            book.setImg_path(upload);
        }
        else {
            String defaultCover= "/static/img/book/defaultCover.jpg";
            book.setImg_path(defaultCover);
        }
        int add = bookService.add(book);
        request.setAttribute("add",add);
        List(request,response);
    }
    protected void updateBooks(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        Book book = WebUtils.param2Bean(request, Book.class);
        String upload = WebUtils.upload(request);
        if(upload!=null){
            book.setImg_path(upload);
        }
        else {
            book.setImg_path(bookService.selectById(book.getId()).getImg_path());
        }
        int update = bookService.update(book);
        request.setAttribute("update",update);
        List(request,response);
    }
    protected void deleteBooks(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String deleteBooks = request.getParameter("deleteBooks");
        int[] book_ids = WebUtils.parseIntArray(deleteBooks);
        int delete = bookService.softDelete(book_ids);
        request.setAttribute("delete",delete);
        List(request,response);
    }
    protected void eraseBooks(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String eraseBooks = request.getParameter("eraseBooks");
        int[] book_ids = WebUtils.parseIntArray(eraseBooks);
        int erase = bookService.delete(book_ids);
        request.setAttribute("erase",erase);
        request.setAttribute("recycleList","yes");
        List(request,response);
    }
    protected void recycleBooks(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String recycleBooks = request.getParameter("recycleBooks");
        int[] book_ids = WebUtils.parseIntArray(recycleBooks);
        int recycle = bookService.recycle(book_ids);
        request.setAttribute("recycleBooks",recycle);
        request.setAttribute("recycleList","yes");
        List(request,response);
    }
    protected void shipOrder(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String order_id = request.getParameter("order_id");
        int shipOrder = userOrderService.updateStatus(order_id, 2);
        request.setAttribute("shipOrder",shipOrder);
        request.setAttribute("tab", "orders");
        List(request,response);
    }
    protected void recharge(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        UserInfo user = WebUtils.param2Bean(request, UserInfo.class);
        int recharge = userService.recharge(user);
        request.setAttribute("charge",recharge);
        request.setAttribute("tab", "users");
        List(request,response);
    }
    protected void resetPwd(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        int user_id = Integer.parseInt(request.getParameter("id"));
        int resetPassword = userService.resetPassword(user_id);
        request.setAttribute("resetPassword",resetPassword);
        request.setAttribute("tab", "users");
        List(request,response);
    }
    protected void deleteUser(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String userIds = request.getParameter("ids");
        int[] user_ids = WebUtils.parseIntArray(userIds);
        int delete = userService.delete(user_ids);
        request.setAttribute("delete",delete);
        request.setAttribute("tab", "users");
        List(request,response);
    }
}
