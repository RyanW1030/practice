package com.bookstore.service.Impl;

import com.bookstore.bean.*;
import com.bookstore.dao.Impl.*;
import com.bookstore.service.UserOrderService;
import com.bookstore.utils.JDBCUtils;
import com.bookstore.utils.WebUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

public class UserOrderServiceImpl implements UserOrderService {
    UserOrderDAOImpl userOrderDAO = new UserOrderDAOImpl();
    orderitemDAOImpl orderitemDAO=new orderitemDAOImpl();
    cartitemServiceImpl cartitemService=new cartitemServiceImpl();
    cartitemDAOImpl cartitemDAO=new cartitemDAOImpl();
    bookDAOImpl bookDAO=new bookDAOImpl();
    userDAOImpl userDAO=new userDAOImpl();
    @Override
    public String createOrder(UserInfo user,int[] cartitem_ids) {
        //user_order和order_item必须同时创建（事务）
        Connection connection=null;

        // 类型转换
        Integer[] cartitemids=new Integer[cartitem_ids.length];
        String uuid = WebUtils.makeUUID();
        BigDecimal total_money = new BigDecimal(0);
        int result=0;
        for (int i = 0; i < cartitem_ids.length; i++) {
            cartitemids[i]=cartitem_ids[i];
        }
        try{
            connection=JDBCUtils.getConnection();
            connection.setAutoCommit(false);// 开启事务

            // ==========================================
            // 策略：先插入订单占位 (金额为0)，解决外键依赖
            // ==========================================
            userOrderDAO.insert(connection, user,uuid,total_money);

            // 获取商品数据
            LinkedHashMap<CartItem, Book> map = cartitemService.Map(cartitemids);

            // 遍历处理
            for (Map.Entry<CartItem, Book> cartItemBookEntry : map.entrySet()) {
                CartItem cartItem = cartItemBookEntry.getKey();
                Book book = cartItemBookEntry.getValue();

                // 1. 插入子项 (此时父订单已存在，安全)
                orderitemDAO.insert(connection, uuid, cartItem, book);

                // 2. 累加金额
                total_money=total_money.add(book.getPrice().multiply(BigDecimal.valueOf(cartItem.getCount())));

                // 3. 扣库存、加销量
                book.setStock(book.getStock()-cartItem.getCount());
                book.setSales(book.getSales()+cartItem.getCount());
                bookDAO.update(connection,book);

                // 4. 删购物车
                cartitemDAO.delete(connection,cartItem.getId());
                result++;
            }

            // ==========================================
            // 最后一步：回填计算好的总金额
            // ==========================================;
            userOrderDAO.update(connection,uuid,total_money);
            connection.commit();
            return uuid;
        }catch (Exception e){
            System.out.println("异常有无被抛出？！");
            e.printStackTrace();
            if(connection!=null){
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return "error";
        }
        finally {
            JDBCUtils.close(connection,null);
        }
    }

    @Override
    public int cancelOrder(String order_id) {
        Connection connection=null;
        int result=0;
        try{
            connection=JDBCUtils.getConnection();
            connection.setAutoCommit(false);
            UserOrder userOrder = userOrderDAO.selectById(connection, order_id);
            if (userOrder == null) {
                return 0; // 或者抛出异常，或者返回特定错误码
            }
            for (OrderItem orderItem : orderitemDAO.List(connection, order_id)) {
                int book_id = orderItem.getBook_id();
                int count = orderItem.getCount();
                int user_id = userOrder.getUser_id();
                CartItem oldItem = cartitemDAO.selectByUserAndBook(connection, user_id, book_id);
                if(oldItem==null){
                    CartItem cartItem = new CartItem();
                    cartItem.setUser_id(user_id);
                    cartItem.setBook_id(book_id);
                    cartItem.setCount(count);
                    cartitemDAO.insert(connection,cartItem);
                }
                else {
                    oldItem.setCount(oldItem.getCount()+orderItem.getCount());
                    cartitemDAO.update(connection,oldItem);
                }
                Book book = bookDAO.selectById(connection, book_id);
                book.setSales(book.getSales()-count);
                if(book.getStock()!=-1){//设定状态-1为书籍下架，此处条件判断保证不会因为订单撤回而产生书籍意外上架的情况
                    book.setStock(book.getStock()+count);
                }
                bookDAO.update(connection,book);
                result++;
            }
            BigDecimal total_money = userOrder.getTotal_money();
            if(userOrder.getStatus()==1){//客户已付款
                UserInfo userInfo = userDAO.selectById(connection, userOrder.getUser_id());
                BigDecimal balance = userInfo.getBalance();
                balance=balance.add(userOrder.getTotal_money());
                userDAO.updateBalance(connection,userInfo.getId(),balance);
            }
            orderitemDAO.delete(connection,order_id);
            userOrderDAO.delete(connection,order_id);
            connection.commit();
            return result;
        }catch (Exception e){
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return 0;
        }
        finally {
            JDBCUtils.close(connection,null);
        }
    }

    @Override
    public ArrayList<UserOrder> List(UserInfo user) {
        Connection connection = JDBCUtils.getConnection();
        return userOrderDAO.List(connection,user.getId());
    }

    @Override
    public int pay(String order_id, int user_id) {
        Connection connection=null;
        try{
            connection=JDBCUtils.getConnection();
            connection.setAutoCommit(false);
            UserOrder userOrder = userOrderDAO.selectById(connection, order_id);
            UserInfo user = userDAO.selectById(connection, user_id);
            if(user==null||userOrder==null){
                connection.rollback();
                return 0;
            }
            if(userOrder.getStatus()==1){
                connection.rollback();
                return 1;
            }
            BigDecimal total_money = userOrder.getTotal_money();
            if(user.getBalance().compareTo(total_money)<0){
                connection.rollback();
                return 0;
            }
            BigDecimal subtract = user.getBalance().subtract(total_money);
            userDAO.updateBalance(connection,user_id,subtract);
            userOrderDAO.updateStatus(connection,order_id,1);
            connection.commit();
            return 1;
        }catch (Exception e){
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return 0;
        }
        finally {
            JDBCUtils.close(connection,null);
        }
    }

    @Override
    public UserOrder selectById(String order_id) {
        Connection connection = JDBCUtils.getConnection();
        return userOrderDAO.selectById(connection,order_id);
    }

    @Override
    public ArrayList<UserOrder> List() {
        Connection connection = JDBCUtils.getConnection();
        return userOrderDAO.List(connection);
    }

    @Override
    public int updateStatus(String order_id, int status) {
        Connection connection = JDBCUtils.getConnection();
        return userOrderDAO.updateStatus(connection,order_id,status);
    }
}
