package com.bookstore.dao;

import com.bookstore.bean.UserInfo;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;

public interface userDAO {
    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param user  将浏览器输入的用户名和密码打包成UserInfo对象传入登录方法
     * @return  如果登录成功，则返回Userinfo对象，如果失败，则返回null
     */
    public UserInfo login(Connection connection,UserInfo user);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param user  将浏览器输入的注册信息打包成UserInfo对象传入注册方法
     * @return  如果注册成功，返回值大于0，失败则等于0
     */
    public int register(Connection connection,UserInfo user);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param user 将浏览器输入的注册信息打包成UserInfo对象传入检验用户名是否被占用方法
     * @return 返回1则代表用户名已被占用，0代表用户名未被占用
     */
    public int isRegister(Connection connection,UserInfo user);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param user 修改后的用户对象
     * @return 修改用户数量
     */
    public int update(Connection connection,UserInfo user);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param id 根据id对用户进行查询
     * @return 返回查询的用户
     */
    public UserInfo selectById(Connection connection,int id);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param expense 对用户余额进行修改
     * @return 返回修改记录的条数
     */
    public int updateBalance(Connection connection, int user_id,BigDecimal expense);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @return 返回所有用户列表
     */
    public ArrayList<UserInfo> List(Connection connection);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param user_id 需要重置密码的用户id
     * @return 返回被重置密码的用户个数
     */
    public int resetPassword(Connection connection,int user_id);

    /**
     *
     * @param connection 从service方法中传入数据库连接Connection对象
     * @param ids 批量删除的用户id数组
     * @return 删除的用户数量
     */
    public int delete(Connection connection,Integer...ids);
}
