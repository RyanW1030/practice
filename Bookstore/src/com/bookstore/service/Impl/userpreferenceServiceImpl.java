package com.bookstore.service.Impl;

import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserPreference;
import com.bookstore.dao.Impl.userpreferenceDAOImpl;
import com.bookstore.service.userpreferenceService;
import com.bookstore.utils.JDBCUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

public class userpreferenceServiceImpl implements userpreferenceService {
    userpreferenceDAOImpl userpreferenceDAO = new userpreferenceDAOImpl();
    @Override
    public ArrayList<Integer> preference(UserInfo user) {
        ArrayList<Integer> integers = new ArrayList<>();
        Connection connection = JDBCUtils.getConnection();
        for (UserPreference userPreference : userpreferenceDAO.selectByUserId(connection, user)) {
            integers.add(userPreference.getCategory_id());
        }
        return integers;
    }

    @Override
    public int insert(UserInfo user, int[] ids) {
        Connection connection=null;
        int result=0;
        try{
            connection=JDBCUtils.getConnection();
            connection.setAutoCommit(false);
            userpreferenceDAO.delete(connection,user);
            if(ids!=null&&ids.length>0){
                for (int i = 0; i <ids.length ; i++) {
                    userpreferenceDAO.insert(connection,user,ids[i]);
                }
                connection.commit();
                return 1;
            }
        }catch (Exception e){
            if(connection!=null){
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return 0;
        }
        finally {
            JDBCUtils.close(connection,null);
        }
        return result;
    }
}
