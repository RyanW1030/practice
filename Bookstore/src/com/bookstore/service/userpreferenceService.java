package com.bookstore.service;

import com.bookstore.bean.UserInfo;

import java.util.ArrayList;

public interface userpreferenceService {
    /**
     *
     * @param user 通过保存在session中的用户对象来查询用户喜好
     * @return 返回用户喜好的书籍类别ID
     */
    public ArrayList<Integer> preference(UserInfo user);

    /**
     *
     * @param user
     * @param ids
     * @return
     */
    public int insert(UserInfo user,int[] ids);
}
