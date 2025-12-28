package com.bookstore.dao.Impl;

import com.bookstore.bean.Book;
import com.bookstore.utils.JDBCUtils;
import org.junit.Test;

import java.sql.Connection;

import static org.junit.Assert.*;

public class bookDAOImplTest {
    bookDAOImpl bookDAO = new bookDAOImpl();
    Connection connection = JDBCUtils.getConnection();
    @Test
    public void list() {
    }

    @Test
    public void testList() {
    }

    @Test
    public void recommend() {
    }

    @Test
    public void selectById() {
        Book bookById = bookDAO.selectById(connection, 11);
        System.out.println(bookById);
    }
}