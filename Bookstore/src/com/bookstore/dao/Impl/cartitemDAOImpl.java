package com.bookstore.dao.Impl;

import com.bookstore.bean.CartItem;
import com.bookstore.dao.baseDAO;
import com.bookstore.dao.cartitemDAO;

import java.sql.Connection;
import java.util.ArrayList;

public class cartitemDAOImpl extends baseDAO<CartItem> implements cartitemDAO {
    @Override
    public int insert(Connection connection, CartItem cartItem) {
        String sql="insert into cart_item(user_id,book_id,count) value(?,?,?)";
        return cud(connection,sql,cartItem.getUser_id(),cartItem.getBook_id(),cartItem.getCount());
    }

    @Override
    public int delete(Connection connection, Integer... ids) {
        StringBuilder placeHolders=new StringBuilder();
        for (int i = 0; i < ids.length; i++) {
            placeHolders.append("?");
            if(i<ids.length-1){
                placeHolders.append(",");
            }
        }
        String sql="delete from cart_item where id in("+placeHolders+")";
        return cud(connection, sql, ids);
    }

    @Override
    public int update(Connection connection, CartItem cartItem) {
        String sql="update cart_item set count=? where id=?";
        return cud(connection, sql, cartItem.getCount(), cartItem.getId());
    }

    @Override
    public ArrayList<CartItem> List(Connection connection,int user_id) {
        String sql="select * from cart_item where user_id=?";
        return retrieve(connection,sql,user_id);
    }

    @Override
    public ArrayList<CartItem> List(Connection connection, Integer... ids) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <ids.length; i++) {
            placeHolder.append("?");
            if(i<ids.length-1){
                placeHolder.append(",");
            }
        }
        String sql="select * from cart_item where id in("+placeHolder+")";
        return retrieve(connection,sql,ids);
    }

    @Override
    public CartItem selectById(Connection connection, int id) {
        String sql="select from cart_item where id=?";
        return retrieve(connection,sql,id).get(0);
    }

    @Override
    public CartItem selectByUserAndBook(Connection connection, int user_id, int book_id) {
        String sql="select * from cart_item where user_id=? and book_id=?";
        ArrayList<CartItem> cartItems = retrieve(connection, sql, user_id, book_id);
        if(cartItems.size()!=0){
            return cartItems.get(0);
        }
        else {
            return null;
        }
    }

    @Override
    public int deleteByBookId(Connection connection, Integer... BookIds) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <BookIds.length ; i++) {
            placeHolder.append("?");
            if(i<BookIds.length-1){
                placeHolder.append(",");
            }
        }
        String sql="delete from cart_item where book_id in("+placeHolder+")";
        return cud(connection,sql,BookIds);
    }

    @Override
    public int deleteByUserId(Connection connection, Integer... UserIds) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <UserIds.length ; i++) {
            placeHolder.append("?");
            if(i<UserIds.length-1){
                placeHolder.append(",");
            }
        }
        String sql="delete from cart_item where user_id in("+placeHolder+")";
        return cud(connection,sql,UserIds);
    }
}
