package com.bookstore.dao.Impl;

import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserPreference;
import com.bookstore.dao.baseDAO;
import com.bookstore.dao.userpreferenceDAO;

import java.sql.Connection;
import java.util.ArrayList;

public class userpreferenceDAOImpl extends baseDAO<UserPreference> implements userpreferenceDAO {
    @Override
    public ArrayList<UserPreference> selectByUserId(Connection connection, UserInfo user) {
        String sql="select * from user_preference where user_id=?";
        return retrieve(connection,sql,user.getId());
    }

    @Override
    public int insert(Connection connection, UserInfo user,int category_id) {
        String sql="insert into user_preference(user_id,category_id) values(?,?)";
        return cud(connection,sql,user.getId(),category_id);
    }

    @Override
    public int delete(Connection connection, UserInfo user) {
        String sql="delete from user_preference where user_id=?";
        return cud(connection,sql,user.getId());
    }

    @Override
    public int delete(Connection connection, Integer... UserIds) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <UserIds.length ; i++) {
            placeHolder.append("?");
            if(i<UserIds.length-1){
                placeHolder.append(",");
            }
        }
        String sql="delete from user_preference where user_id in("+placeHolder+")";
        return cud(connection,sql,UserIds);
    }
}
