package com.bookstore.service.Impl;

import com.bookstore.bean.Admin;
import com.bookstore.dao.Impl.adminDAOImpl;
import com.bookstore.service.adminService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.util.ArrayList;

public class adminServiceImpl implements adminService {
    adminDAOImpl adminDAO=new adminDAOImpl();
    @Override
    public Admin login(Admin admin) {
        Connection connection = JDBCUtils.getConnection();
        ArrayList<Admin> admins = adminDAO.selectByNameAndPwd(connection, admin);
        if(admins.size()==0){
            return null;
        }
        else {
            return admins.get(0);
        }
    }
}
