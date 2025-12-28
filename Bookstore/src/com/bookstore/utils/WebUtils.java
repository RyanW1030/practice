package com.bookstore.utils;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Map;
import java.util.UUID;

/**
 * Web层通用工具类
 * 用于将 Request 参数自动封装到 Java Bean 中
 */
@MultipartConfig(maxFileSize = 1024*1024*10)
public class WebUtils {

    /**
     * 将 request 中的参数封装到 clazz 对应的对象中
     * @param request HTTP请求对象
     * @param clazz 要封装的目标类字节码
     * @param <T> 泛型
     * @return 封装好的对象
     */
    public static <T> T param2Bean(HttpServletRequest request, Class<T> clazz) {
        T bean = null;
        try {
            // 1. 创建目标对象实例
            bean = clazz.newInstance();

            // 2. 获取该类所有声明的属性 (字段)
            Field[] fields = clazz.getDeclaredFields();

            // 3. 遍历属性
            for (Field field : fields) {
                String name = field.getName(); // 属性名，如 "userId"

                // 4. 从 request 中获取对应的值
                String value = request.getParameter(name);

                // 如果 request 中没有这个参数，或者参数为空，跳过
                if (value == null || value.trim().isEmpty()) {
                    continue;
                }

                // 5. 开启访问权限 (暴力反射，防止 private 无法访问)
                field.setAccessible(true);

                // 6. 类型转换并赋值
                // 因为 request.getParameter 拿到的永远是 String，
                // 但 Bean 的属性可能是 int, double 等，需要转换
                Class<?> type = field.getType();

                if (type == String.class) {
                    field.set(bean, value);
                } else if (type == int.class || type == Integer.class) {
                    field.set(bean, Integer.parseInt(value));
                } else if (type == double.class || type == Double.class) {
                    field.set(bean, Double.parseDouble(value));
                } else if (type == BigDecimal.class) {
                    field.set(bean, new BigDecimal(value));
                }
                // 如果还有其他类型 (如 Date)，可以在这里继续补充分支
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bean;
    }
    public static int[] parseInts(String[] strArr) {
        if (strArr == null || strArr.length == 0) {
            return new int[0];
        }

        return Arrays.stream(strArr)
                .mapToInt(str -> {
                    try {
                        return Integer.parseInt(str);
                    } catch (NumberFormatException e) {
                        return 0; // 或者处理错误
                    }
                })
                .toArray();
    }
    public static int[] parseIntArray(String str) {
        if (str == null || str.trim().isEmpty()) {
            return new int[0];
        }

        String[] parts = str.split(",");
        // 这里的数组长度可能会比 parts 小（如果过滤掉无效项），但为了简单通常直接开辟 parts.length
        int[] result = new int[parts.length];

        for (int i = 0; i < parts.length; i++) {
            try {
                result[i] = Integer.parseInt(parts[i].trim());
            } catch (NumberFormatException e) {
                // 如果解析失败，这里需要决定是跳过还是报错
                // 简单处理：设为0或报错
                throw new RuntimeException("Invalid number format: " + parts[i]);
            }
        }
        return result;
    }
    public static String makeUUID() {
        return UUID.randomUUID().toString().replace("-", "");
    }
    public static String upload(HttpServletRequest request) throws ServletException, IOException {
        Part coverImg = request.getPart("cover_img");
        boolean hasNewImage=(coverImg!=null&&coverImg.getSize()>0&&coverImg.getSubmittedFileName().length()>0);
        if (hasNewImage) {
            // === 情况 A: 用户上传了新图片 ===

            // a. 生成唯一文件名 (防止重名覆盖)
            String oldName = coverImg.getSubmittedFileName();
            String ext = oldName.substring(oldName.lastIndexOf(".")); // 获取后缀 .jpg/.png
            String newFileName = UUID.randomUUID().toString().replace("-", "") + ext;

            // b. 动态获取服务器上的存储路径 (对应 web/static/img/book)
            String dirPath = request.getServletContext().getRealPath("/static/img/book");

            // c. 如果目录不存在则创建
            File dir = new File(dirPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // d. 保存文件到磁盘
            String savePath = dirPath + File.separator + newFileName;
            coverImg.write(savePath);
            return "/static/img/book/"+newFileName;
    }else {
            return null;
        }
    }
    public static String getValue(HttpServletRequest request, String name) {
        // 1. 优先尝试从 Attribute 中获取（通常是 Controller 内部传递的数据，优先级更高）
        Object attrValue = request.getAttribute(name);
        if (attrValue != null) {
            return attrValue.toString();
        }

        // 2. 如果 Attribute 没有，则尝试从 Parameter 中获取（页面提交的数据）
        return request.getParameter(name);
    }
}
