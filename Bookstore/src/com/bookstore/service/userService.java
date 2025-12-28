package com.bookstore.service;

import com.bookstore.bean.UserInfo;

import java.util.ArrayList;

public interface userService {
    /**
     *
     * @param user 用于校验登录是否合法的user对象
     * @return 如果登录成功返回数据库中的对象，失败返回null
     */
    public UserInfo login(UserInfo user);

    /**
     *
     * @param user  用于写入数据库的用户信息
     * @return 如果注册成功返回1，如果用户名被占据返回2，如果数据库操作失败返回0
     */
    public int register(UserInfo user);

    /**
     *
     * @param user 更新后的用户信息
     * @return 更新用户信息的数量
     */
    public int update(UserInfo user);

    /**
     *
     * @param id 根据id对用户进行查询
     * @return 返回待查询用户对象
     */
    public UserInfo selectById(int id);

    /**
     *
     * @return 返回所有用户列表
     */
    public ArrayList<UserInfo> List();

    /**
     *
     * @param user 充值后的用户信息
     * @return 返回充值用户数量
     */
    public int recharge(UserInfo user);

    /**
     *
     * @param user_id 根据用户id重置用户密码
     * @return 返回被重置密码的用户个数
     */
    public int resetPassword(int user_id);

    /**
     *
     * @param ids 批量删除用户的id
     * @return 返回值为0，代表删除失败；返回值为-1，代表用户还有已付款未收货的订单；返回值大于0，代表删除成功
     */
    public int delete(int[] ids);
}
