package com.bookstore.service;

import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserOrder;

import java.util.ArrayList;

public interface UserOrderService {
    /**
     *
     * @param user 创建用户user的订单
     * @return 返回创建订单的订单号
     */
    public String createOrder(UserInfo user,int[] cartitem_ids);

    /**
     *
     * @param order_id 根据订单id取消某项订单
     * @return 取消订单的数量
     */
    public int cancelOrder(String order_id);

    /**
     *
     * @param user 查询当前user对象的订单
     * @return 返回对象的所有订单
     */
    public ArrayList<UserOrder> List(UserInfo user);

    /**
     *
     * @param order_id 所支付订单的订单号
     * @param user_id 当前用户的id
     * @return 返回1代表支付成功，0代表支付失败
     */
    public int pay(String order_id,int user_id);

    /**
     *
     * @param order_id 根据id对订单进行查询
     * @return 返回id对应的订单
     */
    public UserOrder selectById(String order_id);

    /**
     *
     * @return 返回所有订单
     */
    public ArrayList<UserOrder> List();

    /**
     *
     * @param order_id  需要更新状态的订单id
     * @param status 待更新的状态
     * @return 返回更新订单的条数
     */
    public int updateStatus(String order_id,int status);
}
