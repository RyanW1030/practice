package com.bookstore.dao;

import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserPreference;

import java.sql.Connection;
import java.util.ArrayList;

public interface userpreferenceDAO {
    /**
     *
     * @param connection 考虑到数据库事务，由service层传入的connection对象
     * @param user 通过session中保存的user对象查询当前登录用户的图书喜好
     * @return UserPreference对象记录了用户的阅读偏好
     */
    public ArrayList<UserPreference> selectByUserId(Connection connection, UserInfo user);

    /**
     *
     * @param connection  考虑到数据库事务，由service层传入的connection对象
     * @param user 添加到用户偏好中的用户
     * @param category_id 添加到用户偏好中的书籍id
     * @return
     */
    public int insert(Connection connection,UserInfo user,int category_id);

    /**
     *
     * @param connection 考虑到数据库事务，由service层传入的connection对象
     * @param user 传入用户信息，以删除某个用户所有的偏好记录
     * @return
     */
    public int delete(Connection connection,UserInfo user);

    /**
     *
     * @param connection 考虑到数据库事务，由service层传入的connection对象
     * @param UserIds 批量删除一些用户的阅读偏好
     * @return 返回删除的阅读偏好的条目数
     */
    public int delete(Connection connection,Integer...UserIds);
}
