package com.bookstore.dao;

import com.bookstore.bean.Book;
import com.bookstore.bean.CartItem;
import com.bookstore.bean.OrderItem;
import com.bookstore.bean.UserOrder;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;

public interface orderitemDAO {
    /**
     *
     * @param connection  从service层传入的connection对象，便于统一处理事务
     * @param order_id  本条订单项所归属的订单号
     * @param cartItem  本条订单项所对应的购物车项
     * @param book  本条订单项所对应的书籍
     * @return 添加的订单项数量
     */
    public int insert(Connection connection, String order_id, CartItem cartItem, Book book);

    /**
     *
     * @param connection 从service层传入的connection对象，便于统一处理事务
     * @param order_id 查询某一个订单下的订单详情
     * @return 返回订单详情
     */
    public ArrayList<OrderItem> List(Connection connection,String order_id);

    /**
     *
     * @param connection 从service层传入的connection对象，便于统一处理事务
     * @param order_id 根据订单号删除订单详情
     * @return 返回删除订单项的数量
     */
    public int delete(Connection connection,String...order_id);
}
