package com.bookstore.service.Impl;

import com.bookstore.bean.Book;
import com.bookstore.bean.CartItem;
import com.bookstore.dao.Impl.bookDAOImpl;
import com.bookstore.dao.Impl.cartitemDAOImpl;
import com.bookstore.service.cartitemService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

public class cartitemServiceImpl implements cartitemService {
    cartitemDAOImpl cartitemDAO = new cartitemDAOImpl();
    bookServiceImpl bookService=new bookServiceImpl();
    @Override
    public int insert(CartItem cartItem) {
        Connection connection = JDBCUtils.getConnection();
        CartItem existCartItem = cartitemDAO.selectByUserAndBook(connection,cartItem.getUser_id(),cartItem.getBook_id());
        if(existCartItem==null){
            return cartitemDAO.insert(connection, cartItem);
        }
        else {
            existCartItem.setCount(existCartItem.getCount()+cartItem.getCount());
            return cartitemDAO.update(connection,existCartItem);
        }
    }

    @Override
    public int delete(int[] ids) {
        Connection connection = JDBCUtils.getConnection();
        if(ids!=null&&ids.length>0){
            Integer[] cartItemIds=new Integer[ids.length];
            for (int i = 0; i <ids.length ; i++) {
                cartItemIds[i]=ids[i];
            }
            return cartitemDAO.delete(connection,cartItemIds);
        }
            return 0;
    }

    @Override
    public int update(CartItem cartItem) {
        Connection connection = JDBCUtils.getConnection();
        return cartitemDAO.update(connection,cartItem);
    }

    @Override
    public LinkedHashMap<CartItem, Book> Map(int user_id) {
        Connection connection = JDBCUtils.getConnection();
        LinkedHashMap<CartItem, Book> hm = new LinkedHashMap<>();
        for (CartItem cartItem : cartitemDAO.List(connection, user_id)) {
            int bookId = cartItem.getBook_id();
            Book book = bookService.selectById(bookId);
            hm.put(cartItem,book);
        }
        return hm;
    }

    @Override
    public LinkedHashMap<CartItem, Book> Map(Integer... ids) {
        Connection connection = JDBCUtils.getConnection();
        LinkedHashMap<CartItem, Book> hm = new LinkedHashMap<>();
        for (CartItem cartItem : cartitemDAO.List(connection, ids)) {
            int book_id = cartItem.getBook_id();
            Book book = bookService.selectById(book_id);
            hm.put(cartItem,book);
        }
        return hm;
    }
}
