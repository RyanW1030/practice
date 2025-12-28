package com.bookstore.dao.Impl;

import com.bookstore.bean.UserInfo;
import com.bookstore.dao.baseDAO;
import com.bookstore.dao.userDAO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;

public class userDAOImpl extends baseDAO<UserInfo> implements userDAO {
    @Override
    public UserInfo login(Connection connection,UserInfo user) {
        String sql="select * from user_info where username=? and password=?";
        ArrayList<UserInfo> retrieve = retrieve(connection, sql, user.getUsername(), user.getPassword());
        if(retrieve.size()==0){
            return null;
        }
        return retrieve.get(0);
    }

    @Override
    public int register(Connection connection,UserInfo user) {
        String sql="insert into user_info (username,password,email) value(?,?,?)";
        int cud = cud(connection, sql, user.getUsername(), user.getPassword(), user.getEmail());
        return cud;
    }

    @Override
    public int isRegister(Connection connection, UserInfo user) {
        String sql="select * from user_info where username=?";
        ArrayList<UserInfo> retrieve = retrieve(connection, sql, user.getUsername());
        if(retrieve.size()==0){
            return 0;
        }
        else {
            return  1;
        }
    }

    @Override
    public int update(Connection connection, UserInfo user) {
        String sql="update user_info set password=?,email=?,phone=?,address=?,avatar=? where id=?";
        return cud(connection,sql,user.getPassword(),user.getEmail(),user.getPhone(),user.getAddress(),user.getAvatar(),user.getId());
    }

    @Override
    public UserInfo selectById(Connection connection, int id) {
        String sql="select * from user_info where id=?";
        return retrieve(connection,sql,id).get(0);
    }

    @Override
    public int updateBalance(Connection connection, int user_id,BigDecimal expense) {
        String sql="update user_info set balance=? where id=?";
        return cud(connection,sql,expense,user_id);
    }

    @Override
    public ArrayList<UserInfo> List(Connection connection) {
        String sql="select * from user_info";
        return retrieve(connection,sql);
    }

    @Override
    public int resetPassword(Connection connection, int user_id) {
        String sql="update user_info set password='12345678' where id=?";
        return cud(connection,sql,user_id);
    }

    @Override
    public int delete(Connection connection,Integer... ids) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <ids.length ; i++) {
            placeHolder.append("?");
            if(i<ids.length-1){
                placeHolder.append(",");
            }
        }
        String sql="delete from user_info where id in("+placeHolder+")";
        return cud(connection,sql,ids);
    }
}
