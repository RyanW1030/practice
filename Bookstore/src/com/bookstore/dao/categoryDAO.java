package com.bookstore.dao;

import com.bookstore.bean.Category;

import java.sql.Connection;
import java.util.ArrayList;

public interface categoryDAO {
    /**
     *
     * @param categoryID 传入的参数是书籍类别的ID，根据书籍类别的ID查找书籍分类
     * @return 返回书籍的分类信息对象
     */
    public Category selectByID(Connection connection, int categoryID);

    /**
     *
     * @param connection 传入的参数是书籍类别的ID，根据书籍类别的ID查找书籍分类
     * @return 返回所有书籍类别信息
     */
    public ArrayList<Category> List(Connection connection);
}
