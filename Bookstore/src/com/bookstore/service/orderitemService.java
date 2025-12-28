package com.bookstore.service;

import com.bookstore.bean.Book;
import com.bookstore.bean.OrderItem;
import com.bookstore.bean.UserOrder;

import java.util.ArrayList;
import java.util.LinkedHashMap;

public interface orderitemService {
    /**
     *
     * @param order_id 根据订单号查询订单详情
     * @return 返回订单详情
     */
    public LinkedHashMap<OrderItem, Book> Map(String order_id);
}
