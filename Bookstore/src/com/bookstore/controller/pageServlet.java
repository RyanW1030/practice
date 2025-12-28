package com.bookstore.controller;

import com.bookstore.bean.Book;
import com.bookstore.bean.UserInfo;
import com.bookstore.service.Impl.bookServiceImpl;
import com.bookstore.service.Impl.categoryServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;

@WebServlet(name = "pageServlet", value = "/pageServlet")
public class pageServlet extends baseServlet {
    bookServiceImpl bookService = new bookServiceImpl();
    categoryServiceImpl categoryService = new categoryServiceImpl();
    protected void List(HttpServletRequest request, HttpServletResponse response){
        UserInfo user = (UserInfo) request.getSession().getAttribute("user");
        String categoryId = request.getParameter("categoryId");
        String keyword = request.getParameter("keyword");
        ArrayList<Book> list = bookService.List(categoryId,keyword);//返回一个集合，这个集合是页面显示的内容，如果categoryId为null，则显示所有书籍；如果非空，则显示相应类别书籍
        ArrayList<Book> recommend = bookService.recommend(user);//返回推荐的书籍集合
        String currentCategoryName = categoryService.selectById(categoryId,keyword);
        request.setAttribute("List",list);
        request.setAttribute("Recommend",recommend);
        request.setAttribute("currentCategoryName",currentCategoryName);
        request.setAttribute("keyword",keyword);
        try {
            request.getRequestDispatcher("/front.jsp").forward(request,response);
        } catch (ServletException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    protected void Detail(HttpServletRequest request,HttpServletResponse response){
        int id = Integer.parseInt(request.getParameter("id"));
        Book book = bookService.selectById(id);
        String category_id = String.valueOf(book.getCategory_id());
        String category = categoryService.selectById(category_id,null);
        request.setAttribute("book",book);
        request.setAttribute("category",category);
        try {
            request.getRequestDispatcher("/user/detail.jsp").forward(request,response);
        } catch (ServletException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
