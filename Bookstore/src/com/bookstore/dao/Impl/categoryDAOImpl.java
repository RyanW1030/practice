package com.bookstore.dao.Impl;

import com.bookstore.bean.Category;
import com.bookstore.dao.baseDAO;
import com.bookstore.dao.categoryDAO;

import java.sql.Connection;
import java.util.ArrayList;

public class categoryDAOImpl extends baseDAO<Category> implements categoryDAO {
    @Override
    public Category selectByID(Connection connection,int categoryID) {
        String sql="select * from category where id=?";
        return retrieve(connection,sql,categoryID).get(0);
    }

    @Override
    public ArrayList<Category> List(Connection connection) {
        String sql="select * from category";
        return retrieve(connection,sql);
    }
}
