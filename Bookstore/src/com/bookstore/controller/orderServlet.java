package com.bookstore.controller;

import com.bookstore.bean.Book;
import com.bookstore.bean.OrderItem;
import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserOrder;
import com.bookstore.service.Impl.UserOrderServiceImpl;
import com.bookstore.service.Impl.orderitemServiceImpl;
import com.bookstore.service.Impl.userServiceImpl;
import com.bookstore.service.UserOrderService;
import com.bookstore.utils.WebUtils;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;

@WebServlet(name = "orderServlet", value = "/orderServlet")
public class orderServlet extends baseServlet {
    UserOrderServiceImpl userOrderService = new UserOrderServiceImpl();
    orderitemServiceImpl useritemService=new orderitemServiceImpl();
    userServiceImpl userService=new userServiceImpl();
    protected void createOrder(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        UserInfo user = (UserInfo) request.getSession().getAttribute("user");
        String cartItemIds = request.getParameter("cartItemIds");
        int[] cartitem_ids = WebUtils.parseIntArray(cartItemIds);
        String order_id= userOrderService.createOrder(user, cartitem_ids);
        System.out.println(order_id);
        request.setAttribute("order_id",order_id);
        List(request,response);
    }
    protected void List(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String order_id = (String) request.getAttribute("order_id");
        if(order_id==null){
            order_id=request.getParameter("order_id");
        }
        if(!order_id.equals("error")){
            LinkedHashMap<OrderItem, Book> map = useritemService.Map(order_id);
            UserOrder userOrder = userOrderService.selectById(order_id);
            UserInfo user = userService.selectById(userOrder.getUser_id());
            request.setAttribute("orderItems",map);
            request.setAttribute("currentOrderId",order_id);
            request.setAttribute("userOrder",userOrder);
            request.setAttribute("user",user);
            request.getRequestDispatcher("/user/orderItems.jsp").forward(request,response);
        }
        else {
            response.sendRedirect(request.getContextPath()+"/index.jsp");
        }
    }
    protected void orderList(HttpServletRequest request,HttpServletResponse response) throws IOException, ServletException {
        UserInfo user = (UserInfo) request.getSession().getAttribute("user");
        if(user==null){
            response.sendRedirect(request.getContextPath()+"/user/login.jsp");
        }
        else {
            ArrayList<UserOrder> list = userOrderService.List(user);
            request.setAttribute("OrderList",list);
            request.getRequestDispatcher("/user/orderList.jsp").forward(request,response);
        }
    }
    protected void payment(HttpServletRequest request,HttpServletResponse response) throws IOException, ServletException {
        UserInfo user = (UserInfo) request.getSession().getAttribute("user");
        String order_id=request.getParameter("order_id");
        if(user==null){
            response.sendRedirect(request.getContextPath()+"/user/login.jsp");
        }
        else {
            int pay = userOrderService.pay(order_id, user.getId());
            request.setAttribute("order_id",order_id);
            List(request,response);
        }
    }
    protected void cancelOrder(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String order_id = request.getParameter("order_id");
        int cancel = userOrderService.cancelOrder(order_id);
        request.setAttribute("cancel",cancel);
        orderList(request,response);
    }
    protected void confirm(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
        String order_id = request.getParameter("order_id");
        userOrderService.updateStatus(order_id,3);
        request.setAttribute("confirm","yes");
        orderList(request,response);
    }
}
