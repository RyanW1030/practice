package com.bookstore.service.Impl;

import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserOrder;
import com.bookstore.dao.Impl.*;
import com.bookstore.service.userService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

public class userServiceImpl implements userService {
    userDAOImpl userDAO = new userDAOImpl();
    UserOrderDAOImpl userOrderDAO=new UserOrderDAOImpl();
    orderitemDAOImpl orderitemDAO=new orderitemDAOImpl();
    cartitemDAOImpl cartitemDAO=new cartitemDAOImpl();
    userpreferenceDAOImpl userpreferenceDAO=new userpreferenceDAOImpl();
    @Override
    public UserInfo login(UserInfo user) {
        Connection connection = JDBCUtils.getConnection();
        UserInfo login = userDAO.login(connection, user);
        return login;
    }

    @Override
    public int register(UserInfo user) {
        Connection connection = JDBCUtils.getConnection();
        int register = userDAO.isRegister(connection, user);
        if(register==1){
            return 2;
        }
        else {
            int register1 = userDAO.register(connection, user);
            return register1;
        }
    }

    @Override
    public int update(UserInfo user) {
        Connection connection = JDBCUtils.getConnection();
        return userDAO.update(connection,user);
    }

    @Override
    public UserInfo selectById(int id) {
        Connection connection = JDBCUtils.getConnection();
        return userDAO.selectById(connection,id);
    }

    @Override
    public ArrayList<UserInfo> List() {
        Connection connection = JDBCUtils.getConnection();
        return userDAO.List(connection);
    }

    @Override
    public int recharge(UserInfo user) {
        Connection connection = JDBCUtils.getConnection();
        return userDAO.updateBalance(connection,user.getId(),user.getBalance());
    }

    @Override
    public int resetPassword(int user_id) {
        Connection connection = JDBCUtils.getConnection();
        return userDAO.resetPassword(connection,user_id);
    }

    @Override
    public int delete(int[] ids) {
        Connection connection=null;
        try{
            if(ids==null||ids.length==0){
                return 0;
            }
            else {
                Integer[] userIds=new Integer[ids.length];
                for (int i = 0; i <ids.length ; i++) {
                    userIds[i]=ids[i];
                }
                connection=JDBCUtils.getConnection();
                connection.setAutoCommit(false);
                ArrayList<UserOrder> userOrders = userOrderDAO.statusCheck(connection, userIds);
                if(userOrders.size()>0){
                    connection.rollback();
                    return -1;
                }
                ArrayList<String> order_ids = userOrderDAO.getOrderIds(connection,userIds);
                if(order_ids!=null&&order_ids.size()>0){
                    orderitemDAO.delete(connection,order_ids.toArray(new String[0]));
                }
                userOrderDAO.delete(connection,userIds);
                cartitemDAO.deleteByUserId(connection,userIds);
                userpreferenceDAO.delete(connection,userIds);
                int delete = userDAO.delete(connection, userIds);
                connection.commit();
                return delete;
            }
        }catch (Exception e){
                if(connection!=null){
                    try {
                        connection.rollback();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                return 0;
        }finally {
                JDBCUtils.close(connection,null);
        }
    }
}
