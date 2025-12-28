package com.bookstore.dao;

import com.bookstore.utils.JDBCUtils;

import java.lang.reflect.Field;
import java.sql.*;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.ArrayList;

public abstract class baseDAO<T> {
    Class aClass;
    {
        Type genericSuperclass = this.getClass().getGenericSuperclass();
        ParameterizedType gsc=(ParameterizedType)genericSuperclass;
        Type[] actualTypeArguments = gsc.getActualTypeArguments();
        aClass=(Class)actualTypeArguments[0];
    }
    public ArrayList<T> retrieve(Connection connection,String sql,Object...param){
        ArrayList<T> ts = new ArrayList<>();
        PreparedStatement preparedStatement=null;
        ResultSet resultSet=null;
        try {
            preparedStatement=connection.prepareStatement(sql);
            for (int i = 0; i <param.length ; i++) {
                preparedStatement.setObject(i+1,param[i]);
            }
            resultSet= preparedStatement.executeQuery();
            ResultSetMetaData metaData = resultSet.getMetaData();
            int columnCount = metaData.getColumnCount();
            while(resultSet.next()){
                T t=(T)aClass.newInstance();
                for (int i = 1; i <=columnCount ; i++) {
                    Object object = resultSet.getObject(i);
                    String columnLabel = metaData.getColumnLabel(i);
                    Field declaredField = t.getClass().getDeclaredField(columnLabel);
                    declaredField.setAccessible(true);
                    declaredField.set(t,object);
                }
                ts.add(t);
            }
        }catch (Exception e){
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        finally {
            JDBCUtils.close(null,preparedStatement,resultSet);
        }
        return ts;
    }
    public <V> ArrayList<V> getField(Connection connection,String sql,Object...param){
        ArrayList<V> vs = new ArrayList<>();
        PreparedStatement preparedStatement=null;
        ResultSet resultSet=null;
        try {
            preparedStatement=connection.prepareStatement(sql);
            for (int i = 0; i <param.length ; i++) {
                preparedStatement.setObject(i+1,param[i]);
            }
            resultSet= preparedStatement.executeQuery();
            ResultSetMetaData metaData = resultSet.getMetaData();
            while(resultSet.next()){
                V v = (V) resultSet.getObject(1);
                vs.add(v);
            }
        }catch (Exception e){
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        finally {
            JDBCUtils.close(null,preparedStatement,resultSet);
        }
        return vs;
    }
    public int cud(Connection connection,String sql,Object...param){
        PreparedStatement preparedStatement=null;
        int i=0;
        try{
            preparedStatement=connection.prepareStatement(sql);
            for (int j = 0; j <param.length; j++) {
                preparedStatement.setObject(j+1,param[j]);
            }
            i = preparedStatement.executeUpdate();
        }catch (SQLException e){
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        finally {
            JDBCUtils.close(null,preparedStatement);
        }
        return i;
    }
}
