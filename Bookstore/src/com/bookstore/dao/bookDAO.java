package com.bookstore.dao;

import com.bookstore.bean.Book;

import java.sql.Connection;
import java.util.ArrayList;

public interface bookDAO {
    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @return 返回所有书籍列表
     */
    public ArrayList<Book> List(Connection connection);
    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param category  查询某一类书籍，传入书籍类别编号
     * @return 返回某一类书籍列表
     */
    public ArrayList<Book> List(Connection connection,int category);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @return 返回推荐列表书籍
     */
    public ArrayList<Book> recommend(Connection connection);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param list 当前用户阅读偏好类别的id
     * @return 返回该用户所有偏好中销量前5的书籍
     */
    public ArrayList<Book> recommend(Connection connection,ArrayList<Integer> list);
    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param id 书籍ID
     * @return 返回待查找的书籍
     */
    public Book selectById(Connection connection, int id);

    /**
     *
     * @param connection  由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param ids 可变形参列表，用于处理从1~n的不确定数量的删除；该参数设计成引用数据类型是为了便于可变形参列表在方法之间的传递
     * @return  返回删除的数量
     */
    public int delete(Connection connection,Integer...ids);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param key 模糊查询条件，可根据书名或作者进行模糊查询
     * @return 返回查询结果集合
     */
    public ArrayList<Book> query(Connection connection,String key);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param book 修改后的书籍对象
     * @return 返回修改书籍的数量
     */
    public int update(Connection connection,Book book);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param book 所添加的书籍对象
     * @return 添加的记录条数
     */
    public int insert(Connection connection,Book book);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param ids 软性删除的书籍列表
     * @return 返回删除的书籍数量
     */
    public int softDelete(Connection connection,Integer...ids);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @param ids 从软性删除中回收的书籍列表
     * @return 返回回收的书籍数量
     */
    public int recycle(Connection connection,Integer...ids);

    /**
     *
     * @param connection 由调用bookDAO的service类传入Connection对象（便于今后处理数据库事务）
     * @return 返回回收站中的书籍列表
     */
    public ArrayList<Book> recycleList(Connection connection);
}
