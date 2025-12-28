package com.bookstore.controller;

import com.bookstore.bean.Book;
import com.bookstore.bean.CartItem;
import com.bookstore.bean.UserInfo;
import com.bookstore.service.Impl.cartitemServiceImpl;
import com.bookstore.utils.WebUtils;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet(name = "cartServlet", value = "/cartServlet")
public class cartServlet extends baseServlet {
    cartitemServiceImpl cartitemService = new cartitemServiceImpl();
    protected void Map(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        /*int user_id = Integer.parseInt(request.getParameter("user_id"));*/
        UserInfo user = (UserInfo) request.getSession().getAttribute("user");
        int user_id = user.getId();
        HashMap<CartItem, Book> map = cartitemService.Map(user_id);
        request.setAttribute("Cart_book",map);
        request.getRequestDispatcher("/user/cart.jsp").forward(request,response);
    }
    protected void add(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
/*        int userId = Integer.parseInt(request.getParameter("userId"));
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        int count = Integer.parseInt(request.getParameter("count"));
        CartItem cartItem = new CartItem();
        cartItem.setBook_id(bookId);
        cartItem.setUser_id(userId);
        cartItem.setCount(count);*/
        CartItem cartItem = WebUtils.param2Bean(request, CartItem.class);
        cartitemService.insert(cartItem);
        StringBuilder placeHolders=new StringBuilder("/pageServlet?action=List");
        String categoryId = request.getParameter("categoryId");
        if(categoryId!=null&&!categoryId.trim().isEmpty()){
            placeHolders.append("&categoryId=").append(categoryId);
        }
        String page = request.getParameter("page");
        if(page!=null&&!page.trim().isEmpty()){
            placeHolders.append("&page=").append(page);
        }
        String searchName = request.getParameter("keyword");
        if (searchName != null && !searchName.trim().isEmpty()) {
            // 这里的编码是为了作为 URL 参数传递
            placeHolders.append("&keyword=").append(java.net.URLEncoder.encode(searchName, "UTF-8"));
        }
        request.getSession().setAttribute("addCartSuccess", "true");
        request.getRequestDispatcher(placeHolders.toString()).forward(request,response);
    }
    protected void update(HttpServletRequest request,HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        int count = Integer.parseInt(request.getParameter("count"));
        CartItem cartItem = new CartItem();
        cartItem.setCount(count);
        cartItem.setId(id);
        cartitemService.update(cartItem);
        response.sendRedirect("/bookstore/cartServlet?action=Map&user_id="+request.getParameter("user_id"));
    }
    protected void delete(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String deleteIds = request.getParameter("deleteIds");
        int[] deleteCartItemIds = WebUtils.parseIntArray(deleteIds);
        int delete = cartitemService.delete(deleteCartItemIds);
        request.setAttribute("delete",delete);
        Map(request,response);
    }
}
