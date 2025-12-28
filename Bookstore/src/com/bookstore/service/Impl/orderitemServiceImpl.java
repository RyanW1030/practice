package com.bookstore.service.Impl;

import com.bookstore.bean.Book;
import com.bookstore.bean.OrderItem;
import com.bookstore.bean.UserOrder;
import com.bookstore.dao.Impl.orderitemDAOImpl;
import com.bookstore.service.orderitemService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.LinkedHashMap;

public class orderitemServiceImpl implements orderitemService {
    orderitemDAOImpl orderitemDAO=new orderitemDAOImpl();
    bookServiceImpl bookService=new bookServiceImpl();
    @Override
    public LinkedHashMap<OrderItem, Book> Map(String order_id) {
        Connection connection = JDBCUtils.getConnection();
        LinkedHashMap<OrderItem, Book> hm = new LinkedHashMap<>();
        for (OrderItem orderItem : orderitemDAO.List(connection, order_id)) {
            int book_id = orderItem.getBook_id();
            Book book = bookService.selectById(book_id);
            hm.put(orderItem,book);
        }
        return hm;
    }
}
