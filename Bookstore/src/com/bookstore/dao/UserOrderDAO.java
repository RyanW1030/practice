package com.bookstore.dao;

import com.bookstore.bean.OrderItem;
import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserOrder;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;

public interface UserOrderDAO {
    /**
     *
     * @param connection  由Service层创建数据库连接传入DAO
     * @param user 创建用户user的订单
     * @return 返回创建的订单数量
     */
    public int insert(Connection connection, UserInfo user, String uuid, BigDecimal total_money);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param uuid 待更新订单的uuid
     * @param total_money 更新后的总价
     * @return 更新的订单数量
     */
    public int update(Connection connection,String uuid,BigDecimal total_money);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param order_id 通过order_id寻找订单
     * @return 返回所需求的订单
     */
    public UserOrder selectById(Connection connection,String order_id);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param order_id 根据订单号删除订单
     * @return 删除订单的条数
     */
    public int delete(Connection connection,String order_id);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param user_ids 根据用户id来删除订单
     * @return 删除的订单条目
     */
    public int delete(Connection connection,Integer...user_ids);
    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param user_id 根据用户id查询他的订单
     * @return 返回某个用户的所有订单
     */
    public ArrayList<UserOrder> List(Connection connection,int user_id);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param order_id 根据订单id修改订单状态
     * @param status 订单状态，0为未付款，1为已付款未发货，2为已发货
     * @return 更新成功返回1，失败返回0
     */
    public int updateStatus(Connection connection,String order_id,int status);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @return 返回所有的订单
     */
    public ArrayList<UserOrder> List(Connection connection);

    /**
     *
     * @param connection 由Service层创建数据库连接传入DAO
     * @param user_ids 根据用户id查询订单号
     * @return 返回给定用户集合的所有订单号
     */
    public ArrayList<String> getOrderIds(Connection connection,Integer...user_ids);
    public ArrayList<UserOrder> statusCheck(Connection connection,Integer...user_ids);
}
