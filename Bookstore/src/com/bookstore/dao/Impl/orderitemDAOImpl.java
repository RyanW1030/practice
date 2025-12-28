package com.bookstore.dao.Impl;

import com.bookstore.bean.Book;
import com.bookstore.bean.CartItem;
import com.bookstore.bean.OrderItem;
import com.bookstore.bean.UserOrder;
import com.bookstore.dao.baseDAO;
import com.bookstore.dao.orderitemDAO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;

public class orderitemDAOImpl extends baseDAO<OrderItem> implements orderitemDAO {
    @Override
    public int insert(Connection connection, String order_id, CartItem cartItem, Book book) {
        String sql="insert into order_item (order_id,book_id,name,price,count,total_price) values(?,?,?,?,?,?)";
        BigDecimal total_price=book.getPrice().multiply(BigDecimal.valueOf(cartItem.getCount()));
        return cud(connection,sql,order_id,book.getId(),book.getName(),book.getPrice(),cartItem.getCount(),total_price);
    }

    @Override
    public ArrayList<OrderItem> List(Connection connection, String order_id) {
        String sql="select * from order_item where order_id=?";
        return retrieve(connection,sql,order_id);
    }

    @Override
    public int delete(Connection connection, String...order_id) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <order_id.length ; i++) {
            placeHolder.append("?");
            if(i<order_id.length-1){
                placeHolder.append(",");
            }
        }
        String sql="delete from order_item where order_id in("+placeHolder+")";
        return cud(connection,sql,order_id);
    }
}
