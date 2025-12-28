package com.bookstore.service;

import com.bookstore.bean.Book;
import com.bookstore.bean.CartItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

public interface cartitemService {
    /**
     *
     * @param cartItem 添加进入购物车的商品对象
     * @return 返回添加进数据库的商品条目
     */
    public int insert(CartItem cartItem);

    /**
     *
     * @param ids 根据购物车项id数组批量删除商品（数量从1到n）
     * @return 返回删除的商品条数
     */
    public int delete(int[] ids);

    /**
     *
     * @param cartItem 根据购物车项对象修改购物车内容
     * @return 返回的修改商品数量
     */
    public int update(CartItem cartItem);

    /**
     *
     * @param user_id  返回某个用户的所有购物车项（用户的购物车）
     * @return 返回的HashMap中保存的是由购物车项和对应书籍构成的键值对
     */
    public LinkedHashMap<CartItem,Book> Map(int user_id);

    /**
     *
     * @param ids 添加到账单的购物车项的ids
     * @return 返回购物车项和对应书籍的键值对
     */
    public LinkedHashMap<CartItem,Book> Map(Integer...ids);
}
