package com.bookstore.dao;

import com.bookstore.bean.CartItem;

import java.sql.Connection;
import java.util.ArrayList;

public interface cartitemDAO {
    /**
     *
     * @param connection  由service层传入的connection对象，这一设计便于处理数据库事务
     * @param cartItem  待插入的CartItem对象
     * @return  返回值大于1表示插入成功，返回值小于1表示插入失败
     */
    public int insert(Connection connection, CartItem cartItem);
    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param ids 可变形参列表，用于处理从1~n的不确定数量的删除；该参数设计成引用数据类型是为了便于可变形参列表在方法之间的传递
     * @return 返回删除的数据条数
     */
    public int delete(Connection connection,Integer...ids);
    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param cartItem 存放修改后数据的CartItem对象
     * @return 返回更新数据的数量
     */
    public int update(Connection connection,CartItem cartItem);

    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param user_id 根据用户id查询该用户的所有购物车内容
     * @return 返回某个用户的所有购物车内容
     */
    public ArrayList<CartItem> List(Connection connection,int user_id);

    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param ids 购物车商品生成订单时，所选择的购物车项的ids。
     * @return 加入订单的购物车书籍集合
     */
    public ArrayList<CartItem> List(Connection connection,Integer...ids);
    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param id 通过id查找书籍
     * @return 返回待查找的书籍
     */
    public CartItem selectById(Connection connection,int id);

    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param user_id 按照用户id查找
     * @param book_id 按照书籍id查找
     * @return 查找某个特定用户是否购物车中有某本书，便于订单撤销时的购物车恢复
     */
    public CartItem selectByUserAndBook(Connection connection,int user_id,int book_id);

    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param BookIds 删除购物车中所有指定书籍的内容
     * @return 返回删除记录的条数
     */
    public int deleteByBookId(Connection connection,Integer...BookIds);

    /**
     *
     * @param connection 由service层传入的connection对象，这一设计便于处理数据库事务
     * @param UserIds 删除传入的所有用户的购物车项
     * @return 返回删除记录的条数
     */
    public int deleteByUserId(Connection connection,Integer...UserIds);
}
