package com.bookstore.service;

import com.bookstore.bean.Category;

import java.util.ArrayList;

public interface categoryService {
    /**
     *
     * @param id 根据ID查询书籍类别名称。由于service中需要做条件判断，因此此处传入String类型变量
     * @return 根据条件返回书籍类别名称
     */
    public String selectById(String id,String keyword);

    /**
     *
     * @return 获取所有书籍类别名称
     */
    public ArrayList<Category> List();
}
