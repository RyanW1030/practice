package com.bookstore.dao;

import com.bookstore.bean.Admin;

import java.sql.Connection;
import java.util.ArrayList;

public interface adminDAO {
    /**
     *
     * @param connection 从service层传入的connection
     * @param admin  验证该admin对象是否是合法的登录对象
     * @return 返回查询到的管理员用户，保存在集合ArrayList中
     */
    public ArrayList<Admin> selectByNameAndPwd(Connection connection, Admin admin);
}
