package com.bookstore.service.Impl;

import com.bookstore.bean.Book;
import com.bookstore.bean.UserInfo;
import com.bookstore.dao.Impl.bookDAOImpl;
import com.bookstore.dao.Impl.cartitemDAOImpl;
import com.bookstore.service.bookService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

public class bookServiceImpl implements bookService {
    bookDAOImpl bookDAO = new bookDAOImpl();
    cartitemDAOImpl cartitemDAO=new cartitemDAOImpl();
    userpreferenceServiceImpl userpreferenceService = new userpreferenceServiceImpl();
    @Override
    public ArrayList<Book> List(String category,String keyword) {
        Connection connection = JDBCUtils.getConnection();
        if(keyword!=null&&!keyword.trim().isEmpty()){
            return bookDAO.query(connection,keyword);
        }
        else if(category!=null&&!category.trim().isEmpty()){
            int category_id = Integer.parseInt(category);
            return bookDAO.List(connection,category_id);
        }
        else {
            return bookDAO.List(connection);
        }
    }
    @Override
    public ArrayList<Book> recommend(UserInfo user) {
        Connection connection = JDBCUtils.getConnection();
        if(user!=null){
            ArrayList<Integer> preference = userpreferenceService.preference(user);
            return bookDAO.recommend(connection,preference);
        }
        else {
            return bookDAO.recommend(connection);
        }
    }

    @Override
    public Book selectById(int id) {
        Connection connection = JDBCUtils.getConnection();
        return bookDAO.selectById(connection,id);
    }

    @Override
    public int delete(int[] bookIds) {
        Connection connection = null;
        try{
            connection=JDBCUtils.getConnection();
            connection.setAutoCommit(false);
            if(bookIds!=null&&bookIds.length>0){
                Integer[] ids=new Integer[bookIds.length];
                for (int i = 0; i <bookIds.length ; i++) {
                    ids[i]=bookIds[i];
                }
                cartitemDAO.deleteByBookId(connection,ids);
                int delete = bookDAO.delete(connection, ids);
                connection.commit();
                return delete;
            }
            else{
                return 0;
            }
        }catch (Exception e){
            if(connection!=null){
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return 0;
        }finally {
            JDBCUtils.close(connection,null);
        }
    }

    @Override
    public int update(Book book) {
        Connection connection = JDBCUtils.getConnection();
        return bookDAO.update(connection,book);
    }

    @Override
    public int add(Book book) {
        Connection connection = JDBCUtils.getConnection();
        return bookDAO.insert(connection,book);
    }

    @Override
    public int softDelete(int[] bookIds) {
        Connection connection = JDBCUtils.getConnection();
        if(bookIds!=null&&bookIds.length>0){
            Integer[] ids=new Integer[bookIds.length];
            for (int i = 0; i <bookIds.length ; i++) {
                ids[i]=bookIds[i];
            }
            return bookDAO.softDelete(connection,ids);
        }
        else{
            return 0;
        }
    }

    @Override
    public int recycle(int[] bookIds) {
        Connection connection = JDBCUtils.getConnection();
        if(bookIds!=null&&bookIds.length>0){
            Integer[] ids=new Integer[bookIds.length];
            for (int i = 0; i <bookIds.length ; i++) {
                ids[i]=bookIds[i];
            }
            return bookDAO.recycle(connection,ids);
        }
        else{
            return 0;
        }
    }

    @Override
    public ArrayList<Book> recycleList() {
        Connection connection = JDBCUtils.getConnection();
        return bookDAO.recycleList(connection);
    }
}
