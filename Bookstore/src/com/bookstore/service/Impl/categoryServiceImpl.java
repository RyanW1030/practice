package com.bookstore.service.Impl;

import com.bookstore.bean.Category;
import com.bookstore.dao.Impl.categoryDAOImpl;
import com.bookstore.service.categoryService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.util.ArrayList;

public class categoryServiceImpl implements categoryService {
    categoryDAOImpl categoryDAO = new categoryDAOImpl();
    @Override
    public String selectById(String categoryID,String keyword) {
        Connection connection = JDBCUtils.getConnection();
        if(keyword!=null&&!keyword.trim().isEmpty()){
            return "查询结果";
        }
        else if(categoryID==null||categoryID.trim().isEmpty()){
            return "全部书籍";
        }
        else {
            int id = Integer.parseInt(categoryID);
            Category category = categoryDAO.selectByID(connection, id);
            return category.getName();
        }
    }

    @Override
    public ArrayList<Category> List() {
        Connection connection = JDBCUtils.getConnection();
        return  categoryDAO.List(connection);
    }
}
