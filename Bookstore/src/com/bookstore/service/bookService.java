package com.bookstore.service;

import com.bookstore.bean.Book;
import com.bookstore.bean.UserInfo;

import java.util.ArrayList;

public interface bookService {
    /**
     *
     * @param category  书籍类别参数，若非空，则首页显示该类别书籍
     * @param keyword  查询参数，若非空，则首页显示查询结果
     * @return 根据条件返回书籍列表
     */
    public ArrayList<Book> List(String category,String keyword);
    /**
     *
     * @return 返回向当前用户推荐的书籍列表
     */
    public ArrayList<Book> recommend(UserInfo user);
    /**
     *
     * @param id  待查询的书籍ID
     * @return 返回待查询的书籍对象
     */
    public Book selectById(int id);

    /**
     *
     * @param bookIds 批量删除的书籍id（刚性删除，彻底从数据库中删除）
     * @return 删除的书籍条目数
     */
    public int delete(int[] bookIds);

    /**
     *
     * @param book 修改后的书籍信息
     * @return 修改书籍的条目
     */
    public int update(Book book);

    /**
     *
     * @param book 添加的图书信息
     * @return 返回添加书籍的条目
     */
    public int add(Book book);

    /**
     *
     * @param bookIds 软性删除的书籍id
     * @return 返回删除的记录条数
     */
    public int softDelete(int[] bookIds);

    /**
     *
     * @param bookIds 需要被回收的书籍ID
     * @return 回收的书籍数量
     */
    public int recycle(int[] bookIds);

    /**
     *
     * @return 返回回收站中所有的书籍内容
     */
    public ArrayList<Book> recycleList();
}
