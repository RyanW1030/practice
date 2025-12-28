package com.bookstore.service;

import com.bookstore.bean.Admin;

public interface adminService {
    /**
     *
     * @param admin 检验该用户是否是合法的登录用户
     * @return 若登录合法，返回当前登录的管理员用户，若非法，返回null
     */
    public Admin login(Admin admin);
}
