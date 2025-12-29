package com.bookstore.dao.Impl;

import com.bookstore.bean.Book;
import com.bookstore.dao.baseDAO;
import com.bookstore.dao.bookDAO;

import java.sql.Connection;
import java.util.ArrayList;

public class bookDAOImpl extends baseDAO<Book> implements bookDAO {
    @Override
    public ArrayList<Book> List(Connection connection) {
        String sql="select * from book where stock>=0";
        return retrieve(connection,sql);
    }

    @Override
    public ArrayList<Book> List(Connection connection, int category) {
        String sql="select * from book where category_id=? and stock>=0";
        return retrieve(connection,sql,category);
    }

    @Override
    public ArrayList<Book> recommend(Connection connection) {
        String sql = "SELECT * FROM book where stock>=0 ORDER BY sales DESC LIMIT 0, 5";
        return retrieve(connection,sql);
    }

    @Override
    public ArrayList<Book> recommend(Connection connection, ArrayList<Integer> list) {
        StringBuilder placeHolder=new StringBuilder();
        if(list.size()>0){
            Integer[] ids=new Integer[list.size()];
            for (int i = 0; i <list.size() ; i++) {
                ids[i]=list.get(i);
                placeHolder.append("?");
                if(i<list.size()-1){
                    placeHolder.append(",");
                }
            }
            String sql="SELECT * FROM book where category_id in("+placeHolder+") and stock>=0 ORDER BY sales DESC LIMIT 0, 5";
            return retrieve(connection,sql,ids);
        }
        else {
            return recommend(connection);
        }
    }

    @Override
    public Book selectById(Connection connection, int id) {
        String sql="select * from book where id=?";
        ArrayList<Book> retrieve = retrieve(connection, sql, id);
        if(retrieve.size()>0){
            return retrieve.get(0);
        }
        else{
            return null;
        }
    }

    @Override
    public int delete(Connection connection, Integer... ids) {
        StringBuilder placeHolders=new StringBuilder();
        for (int i = 0; i <ids.length ; i++) {
            placeHolders.append("?");
            if(i<ids.length-1){
                placeHolders.append(",");
            }
        }
        String sql="delete from book where id in("+placeHolders+")";
        return cud(connection,sql,ids);
    }

    @Override
    public ArrayList<Book> query(Connection connection, String key) {
        String sql="select * from book where author=? or name like ? and stock>=0";
        String fuzzy="%"+key+"%";
        return retrieve(connection,sql,key,fuzzy);
    }

    @Override
    public int update(Connection connection, Book book) {
        String sql="update book set name=?,author=?,price=?,sales=?,stock=?,intro=?,publisher=?,isbn=?,img_path=?,category_id=? where id=?";
        return cud(connection,sql,book.getName(),book.getAuthor(),book.getPrice(),book.getSales(),book.getStock(),book.getIntro(),book.getPublisher(),book.getIsbn(),book.getImg_path(),book.getCategory_id(),book.getId());
    }

    @Override
    public int insert(Connection connection, Book book) {
        String sql="insert into book(name,author,price,sales,stock,intro,publisher,isbn,img_path,category_id) values(?,?,?,?,?,?,?,?,?,?)";
        return cud(connection,sql,book.getName(),book.getAuthor(),book.getPrice(),book.getSales(),book.getStock(),book.getIntro(),book.getPublisher(),book.getIsbn(),book.getImg_path(),book.getCategory_id());
    }

    @Override
    public int softDelete(Connection connection, Integer... ids) {
        StringBuilder placeHolders=new StringBuilder();
        for (int i = 0; i <ids.length ; i++) {
            placeHolders.append("?");
            if(i<ids.length-1){
                placeHolders.append(",");
            }
        }
        String sql="update book set stock=-1 where id in("+placeHolders+")";
        return cud(connection,sql,ids);
    }

    @Override
    public int recycle(Connection connection, Integer... ids) {
        StringBuilder placeHolders=new StringBuilder();
        for (int i = 0; i <ids.length ; i++) {
            placeHolders.append("?");
            if(i<ids.length-1){
                placeHolders.append(",");
            }
        }
        String sql="update book set stock=0 where id in("+placeHolders+")";
        return cud(connection,sql,ids);
    }

    @Override
    public ArrayList<Book> recycleList(Connection connection) {
        String sql="select * from book where stock=-1";
        return retrieve(connection,sql);
    }
}
