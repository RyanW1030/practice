```mermaid
erDiagram
    %% 用户系统
    USER_INFO {
        int id PK
        varchar username
        varchar password
        varchar email
        decimal balance
        varchar address
        varchar phone
        varchar avatar
    }

    ADMIN {
        int id PK
        varchar username
        varchar password
        varchar email
    }

    %% 商品与分类系统
    CATEGORY {
        int id PK
        varchar name
    }

    BOOK {
        int id PK
        varchar name
        varchar author
        decimal price
        int sales
        int stock
        text intro
        varchar publisher
        varchar isbn
        varchar img_path
        int category_id FK
    }

    %% 购物车系统
    CART_ITEM {
        int id PK
        int user_id FK
        int book_id FK
        int count
    }

    %% 订单系统
    USER_ORDER {
        varchar order_id PK "UUID字符串"
        timestamp create_time
        decimal total_money
        int status
        int user_id FK
        varchar receiver_address
        varchar receiver_phone
    }

    ORDER_ITEM {
        int id PK
        varchar order_id FK
        int book_id "逻辑关联，无物理外键"
        varchar name "书名快照"
        decimal price "价格快照"
        int count
        decimal total_price
    }

    %% 用户偏好（多对多关系）
    USER_PREFERENCE {
        int user_id PK, FK
        int category_id PK, FK
    }

    %% ----------- 关系连线 -----------

    %% 分类与书籍 (1对多)
    CATEGORY ||--o{ BOOK : "包含"

    %% 用户与购物车 (1对多)
    USER_INFO ||--o{ CART_ITEM : "拥有"
    %% 书籍与购物车 (1对多)
    BOOK ||--o{ CART_ITEM : "被添加进"

    %% 用户与订单 (1对多)
    USER_INFO ||--o{ USER_ORDER : "下单"
    %% 订单与订单项 (1对多)
    USER_ORDER ||--o{ ORDER_ITEM : "包含"

    %% 用户偏好 (多对多关联表)
    USER_INFO ||--o{ USER_PREFERENCE : "记录"
    CATEGORY ||--o{ USER_PREFERENCE : "被偏好"