package com.bookstore.utils;

import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

public class JDBCUtils {
    public static Connection getConnection(){
        Connection connection=null;
        try{
            InputStream resourceAsStream = JDBCUtils.class.getClassLoader().getResourceAsStream("connection.properties");
            Properties properties = new Properties();
            properties.load(resourceAsStream);
            Class.forName(properties.getProperty("className"));
            connection = DriverManager.getConnection(properties.getProperty("url"), properties);
        }catch (Exception e){
            e.printStackTrace();
        }
        return connection;
    }
    public static void close(Connection connection, PreparedStatement preparedStatement, ResultSet resultSet){
        try{
            if(connection!=null){
                connection.close();
            }
            if(preparedStatement!=null){
                preparedStatement.close();
            }
            if(resultSet!=null){
                resultSet.close();
            }
        }catch (SQLException e){
            e.printStackTrace();
        }
    }
    public static void close(Connection connection, PreparedStatement preparedStatement){
        try{
            if(connection!=null){
                connection.close();
            }
            if(preparedStatement!=null){
                preparedStatement.close();
            }
        }catch (SQLException e){
            e.printStackTrace();
        }
    }
}
