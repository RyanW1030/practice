package com.bookstore.dao.Impl;

import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserOrder;
import com.bookstore.dao.UserOrderDAO;
import com.bookstore.dao.baseDAO;
import com.bookstore.utils.WebUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Timestamp;
import java.util.ArrayList;

public class UserOrderDAOImpl extends baseDAO<UserOrder> implements UserOrderDAO {
    @Override
    public int insert(Connection connection, UserInfo user, String uuid, BigDecimal total_money) {
        String sql="insert into user_order(order_id,create_time,total_money,status,user_id,receiver_address,receiver_phone) values(?,?,?,?,?,?,?)";
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        return cud(connection, sql, uuid, timestamp, total_money,0, user.getId(), user.getAddress(), user.getPhone());
    }

    @Override
    public int update(Connection connection, String uuid, BigDecimal total_money) {
        String sql="update user_order set total_money=? where order_id=?";
        return cud(connection,sql,total_money,uuid);
    }

    @Override
    public UserOrder selectById(Connection connection, String order_id) {
        String sql="select * from user_order where order_id=?";
        return retrieve(connection,sql,order_id).get(0);
    }

    @Override
    public int delete(Connection connection, String order_id) {
        String sql="delete from user_order where order_id=?";
        return cud(connection,sql,order_id);
    }

    @Override
    public int delete(Connection connection, Integer... user_ids) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <user_ids.length ; i++) {
            placeHolder.append("?");
            if(i<user_ids.length-1){
                placeHolder.append(",");
            }
        }
        String sql="delete from user_order where user_id in("+placeHolder+")";
        return cud(connection,sql,user_ids);
    }

    @Override
    public ArrayList<UserOrder> List(Connection connection,int user_id) {
        String sql="select * from user_order where user_id=?";
        return retrieve(connection,sql,user_id);
    }

    @Override
    public int updateStatus(Connection connection, String order_id, int status) {
        String sql="update user_order set status=? where order_id=?";
        return cud(connection,sql,status,order_id);
    }

    @Override
    public ArrayList<UserOrder> List(Connection connection) {
        String sql="select * from user_order";
        return retrieve(connection,sql);
    }

    @Override
    public ArrayList<String> getOrderIds(Connection connection, Integer... user_ids) {
        ArrayList<String> OrderIds = new ArrayList<>();
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <user_ids.length ; i++) {
            placeHolder.append("?");
            if(i<user_ids.length-1){
                placeHolder.append(",");
            }
        }
        String sql="select order_id from user_order where user_id in("+placeHolder+")";
        return getField(connection,sql,user_ids);
    }

    @Override
    public ArrayList<UserOrder> statusCheck(Connection connection, Integer... user_ids) {
        StringBuilder placeHolder=new StringBuilder();
        for (int i = 0; i <user_ids.length ; i++) {
            placeHolder.append("?");
            if(i<user_ids.length-1){
                placeHolder.append(",");
            }
        }
        String sql="select * from user_order where user_id in("+placeHolder+") and status in(1,2)";
        return retrieve(connection,sql,user_ids);
    }
}
