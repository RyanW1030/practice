package com.bookstore.controller;

import com.bookstore.bean.Category;
import com.bookstore.bean.UserInfo;
import com.bookstore.bean.UserPreference;
import com.bookstore.service.Impl.categoryServiceImpl;
import com.bookstore.service.Impl.userServiceImpl;
import com.bookstore.service.Impl.userpreferenceServiceImpl;
import com.bookstore.utils.WebUtils;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "userServlet", value = "/userServlet")
public class userServlet extends baseServlet {
        userServiceImpl userService = new userServiceImpl();
        userpreferenceServiceImpl userpreferenceService = new userpreferenceServiceImpl();
        categoryServiceImpl categoryService = new categoryServiceImpl();
        protected void login(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
            UserInfo user=WebUtils.param2Bean(request, UserInfo.class);
            //JSP页面把登录时的表单信息写入Javabean中，存放在request域，servlet直接从request域中获取登录信息
            UserInfo loginUser = userService.login(user);
            //login的值为0，表示登录失败，用户名或密码错误；login的值为1，表示登录成功
            if(loginUser==null){
                request.setAttribute("isLogin",false);
                request.getRequestDispatcher("/user/login.jsp").forward(request,response);
            }
            else {
                request.getSession().setAttribute("user",loginUser);
                response.sendRedirect("/bookstore/pageServlet?action=List");
            }
        }
        protected void register(HttpServletRequest request,HttpServletResponse response){
            UserInfo user=(UserInfo)request.getAttribute("user");
            //JSP页面把注册时的表单信息写入Javabean中，存放在request域，servlet直接从request域中获取注册信息
            int register = userService.register(user);
            //register的值为1代表注册成功；为0代表数据库操作失败；为2代表用户名已被占用
            try {
                if(register==1){
                    response.sendRedirect("/bookstore/user/login.jsp?isRegister="+register);
                }
                else {
                    response.sendRedirect("/bookstore/user/register.jsp?isRegister="+register);
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        protected void profile(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
            UserInfo user = (UserInfo) request.getSession().getAttribute("user");
            ArrayList<Category> list = categoryService.List();
            ArrayList<Integer> preference = userpreferenceService.preference(user);
            request.setAttribute("allCategories",list);
            request.setAttribute("userPreferenceIds",preference);
            request.getRequestDispatcher("/user/profile.jsp").forward(request,response);
        }
        protected void update(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
            UserInfo user = WebUtils.param2Bean(request, UserInfo.class);
            int[] preferences = WebUtils.parseInts(request.getParameterValues("preferences"));
            int updateUser = userService.update(user);
            int updateUserPreference = userpreferenceService.insert(user, preferences);
            UserInfo userUpdate = userService.selectById(user.getId());
            request.getSession().setAttribute("user",userUpdate);
            if(updateUser>0&&updateUserPreference==1){
                request.setAttribute("updateMsg","修改成功");
            }
            else {
                request.setAttribute("updateMsg","修改失败");
            }
            request.getRequestDispatcher("/userServlet?action=profile").forward(request,response);
        }
        protected void logout(HttpServletRequest request,HttpServletResponse response) throws IOException {
            HttpSession session = request.getSession(false);
            if(session!=null){
                session.invalidate();
            }
            response.sendRedirect("/bookstore/pageServlet?action=List");
        }
}
