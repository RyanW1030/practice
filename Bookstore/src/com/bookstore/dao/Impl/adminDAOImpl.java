package com.bookstore.dao.Impl;

import com.bookstore.bean.Admin;
import com.bookstore.dao.adminDAO;
import com.bookstore.dao.baseDAO;

import java.sql.Connection;
import java.util.ArrayList;

public class adminDAOImpl extends baseDAO<Admin> implements adminDAO {
    @Override
    public ArrayList<Admin> selectByNameAndPwd(Connection connection, Admin admin) {
        String sql="select * from admin where username=? and password=?";
        return retrieve(connection, sql, admin.getUsername(), admin.getPassword());
    }
}
