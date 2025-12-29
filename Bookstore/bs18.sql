/*
SQLyog 企业版 - MySQL GUI v8.14 
MySQL - 5.7.35 : Database - bookstore
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`bookstore` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `bookstore`;

/*Table structure for table `admin` */

DROP TABLE IF EXISTS `admin`;

CREATE TABLE `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(50) NOT NULL COMMENT '密码',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

/*Data for the table `admin` */

insert  into `admin`(`id`,`username`,`password`,`email`) values (1,'admin','12345678','admin@gmail.com');

/*Table structure for table `book` */

DROP TABLE IF EXISTS `book`;

CREATE TABLE `book` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '图书ID',
  `name` varchar(100) NOT NULL COMMENT '书名',
  `author` varchar(100) NOT NULL COMMENT '作者',
  `price` decimal(10,2) NOT NULL COMMENT '售价',
  `sales` int(11) DEFAULT '0' COMMENT '销量',
  `stock` int(11) NOT NULL COMMENT '库存',
  `intro` text COMMENT '书籍简介',
  `publisher` varchar(100) DEFAULT NULL COMMENT '出版社',
  `isbn` varchar(50) DEFAULT NULL COMMENT '版号/ISBN',
  `img_path` varchar(200) DEFAULT '/static/img/default_book.jpg' COMMENT '封面路径',
  `category_id` int(11) DEFAULT NULL COMMENT '所属分类ID',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4;

/*Data for the table `book` */

insert  into `book`(`id`,`name`,`author`,`price`,`sales`,`stock`,`intro`,`publisher`,`isbn`,`img_path`,`category_id`) values (1,'算法导论（原书第3版）','Thomas H.Cormen 等','128.00',560,0,'被誉为计算机算法的圣经，详细阐述了算法的设计与分析。','机械工业出版社','9787111407010','/static/img/book/introduction.avif',1),(2,'数据结构（C语言版）','严蔚敏','29.00',8900,300,'国内计算机专业最经典的教材之一，考研必备。','清华大学出版社','9787302147510','/static/img/book/c.avif',1),(3,'算法（第4版）','Robert Sedgewick','99.00',1206,74,'Java语言描述，图文并茂，非常适合初学者入门算法。','人民邮电出版社','9787115293800','/static/img/book/al.avif',1),(4,'大话数据结构','程杰','59.00',3407,143,'以趣味方式讲解数据结构，通俗易懂，适合小白。','清华大学出版社','9787302255659','/static/img/book/ds.avif',1),(5,'计算机网络（第8版）','谢希仁','59.80',7803,397,'国内高校使用最广泛的计算机网络教材。','电子工业出版社','9787121411748','/static/img/book/net.avif',2),(6,'计算机网络：自顶向下方法（原书第7版）','James F. Kurose','89.00',2103,117,'从应用层开始介绍，独特的自顶向下视角。','机械工业出版社','9787111599715','/static/img/book/net2.avif',2),(7,'TCP/IP详解 卷1：协议','W.Richard Stevens','98.00',952,58,'网络编程人员的案头必备神书，深入剖析协议细节。','机械工业出版社','9787111547426','/static/img/book/tcp.avif',2),(8,'数据库系统概念（原书第6版）','Abraham Silberschatz','99.00',670,90,'数据库领域的“帆船书”，理论基础极其扎实。','机械工业出版社','9787111375296','/static/img/book/db.jpg',3),(9,'高性能MySQL（第4版）','Silvia Botros','128.00',1501,109,'MySQL领域的进阶必读，涵盖架构与优化。','电子工业出版社','9787121442575','/static/img/book/mysql.avif',3),(10,'数据库系统概论（第5版）','王珊 / 萨师煊','42.00',6000,350,'国内大学计算机专业数据库课程的标准教材。','高等教育出版社','9787040406641','/static/img/book/dbi.avif',3),(11,'Redis设计与实现','黄健宏','79.00',2302,128,'深入理解Redis内部机制的优秀国产书籍。','机械工业出版社','9787111464747','/static/img/book/redis.avif',3),(12,'深入理解计算机系统（CSAPP）','Randal E.Bryant','139.00',3100,85,'CMU镇校之宝，打通软件与硬件隔阂的神书。','机械工业出版社','9787111544937','/static/img/book/cssy.avif',4),(13,'计算机组成与设计：硬件/软件接口','David A. Patterson','99.00',890,70,'图灵奖得主经典之作，RISC-V版更是紧跟潮流。','机械工业出版社','9787111652144','/static/img/book/design.avif',4),(14,'计算机组成原理（第3版）','唐朔飞','50.00',4500,260,'国内经典的组成原理教材，条理清晰。','高等教育出版社','9787040545180','/static/img/book/assembled.avif',4),(15,'人工智能：一种现代的方法（第4版）','Stuart Russell','198.00',544,46,'AI领域的百科全书，斯坦福等名校教材。','人民邮电出版社','9787115598103','/static/img/book/ai.avif',5),(16,'机器学习','周志华','88.00',9200,200,'俗称“西瓜书”，国内机器学习入门首选。','清华大学出版社','9787302423287','/static/img/book/ml.avif',5),(17,'深度学习','Ian Goodfellow','168.00',1800,60,'俗称“花书”，深度学习领域的圣经级教材。','人民邮电出版社','9787115461476','/static/img/book/dl.avif',5),(18,'动手学深度学习','李沐','85.00',2100,140,'基于PyTorch/MXNet，理论与实践结合极好。','人民邮电出版社','9787115505835','/static/img/book/pdl.avif',5),(19,'Java编程思想（第4版）','Bruce Eckel','108.00',5600,120,'虽然有点老，但依然是Java领域的思想巨著。','机械工业出版社','9787111213826','/static/img/book/tij.avif',6),(20,'Effective Java中文版（第3版）','Joshua Bloch','119.00',3200,95,'Java进阶必读，包含90条实用的最佳实践。','机械工业出版社','9787111612728','/static/img/book/ej.avif',6),(21,'Java核心技术 卷I（第11版）','Cay S. Horstmann','119.00',4100,150,'系统全面，适合作为Java学习的案头参考书。','机械工业出版社','9787111636663','/static/img/book/cj.avif',6),(22,'C程序设计语言（第2版）','Brian W. Kernighan','30.00',2800,100,'K&R C，C语言之父撰写，简洁精炼。','机械工业出版社','9787111128069','/static/img/book/cd.avif',7),(23,'C Primer Plus（第6版）','Stephen Prata','89.00',7500,300,'内容详尽，非常适合零基础自学C语言。','人民邮电出版社','9787115390592','/static/img/book/cpp.avif',7),(24,'C和指针','Kenneth A. Reek','65.00',1200,80,'彻底搞懂C语言指针的经典之作。','人民邮电出版社','9787115172013','/static/img/book/cp.avif',7),(25,'C专家编程','Peter van der Linden','45.00',890,60,'深入揭示C语言内部工作机制，风格幽默。','人民邮电出版社','9787115171726','/static/img/book/ce.avif',7),(26,'强化学习的数学原理','赵世钰','80.00',0,200,'本书从零开始介绍，从数学角度循序渐进地揭示强化学习的基本原理。如果你对强化学习感兴趣，却不知道如何入门；如果你对强化学习一直有云里雾里、似懂非懂的感觉，那么相信本书能帮助你拨开迷雾，看清强化学习的本质，知其然，更知其所以然！','清华大学出版社',' 9787302685678','/static/img/book/63cccff0ef1c432a98de1ddb6f268206.jpg',5),(27,'深度强化学习','王树森','65.00',10000,150,'本书基于备受读者推崇的王树森“深度强化学习”系列公开视频课，专门解决“入门深度强化学习难”的问题。','人民邮电出版社','9787115600691','/static/img/book/ad3bcc2b89ff405a878769e780a5f725.jpg',5),(28,'测试书籍','阿道思','60.00',0,-1,'暂无介绍','机械工业出版社','9787111407111','/static/img/book/defaultCover.jpg',7),(29,'测试书籍2','测试作者','34.00',0,-1,'测试简介','清华大学出版社',' 9787302685467','/static/img/book/defaultCover.jpg',3),(30,'测试书籍3','测试作者3','45.00',0,-1,'测试简介3','机械工业出版社','9787111407012','/static/img/book/defaultCover.jpg',6),(31,'测试书籍4','测试作者4','67.00',0,-1,'测试简介4','人民邮电出版社',' 9787302684275','/static/img/book/defaultCover.jpg',7),(32,'测试简介5','测试作者5','67.00',0,-1,'测试简介5','人民邮电出版社','9787115608271','/static/img/book/defaultCover.jpg',1);

/*Table structure for table `cart_item` */

DROP TABLE IF EXISTS `cart_item`;

CREATE TABLE `cart_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '购物车项ID',
  `user_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `count` int(11) DEFAULT '1' COMMENT '购买数量',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `book_id` (`book_id`),
  CONSTRAINT `cart_item_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_info` (`id`),
  CONSTRAINT `cart_item_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `book` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4;

/*Data for the table `cart_item` */

insert  into `cart_item`(`id`,`user_id`,`book_id`,`count`) values (6,2,3,10),(7,2,4,4),(8,2,2,2),(9,2,16,1),(12,5,6,3),(13,5,16,1),(14,5,19,1),(15,2,18,1),(16,2,24,4),(17,2,28,3),(22,2,14,3),(27,7,2,2),(31,7,18,1);

/*Table structure for table `category` */

DROP TABLE IF EXISTS `category`;

CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

/*Data for the table `category` */

insert  into `category`(`id`,`name`) values (7,'C语言'),(6,'Java'),(5,'人工智能'),(3,'数据库'),(1,'数据结构与算法'),(4,'计算机组成原理'),(2,'计算机网络');

/*Table structure for table `order_item` */

DROP TABLE IF EXISTS `order_item`;

CREATE TABLE `order_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '订单项ID',
  `order_id` varchar(50) DEFAULT NULL COMMENT '归属订单',
  `book_id` int(11) DEFAULT NULL COMMENT '书籍ID',
  `name` varchar(100) NOT NULL COMMENT '书名快照',
  `price` decimal(10,2) NOT NULL COMMENT '单价快照',
  `count` int(11) NOT NULL COMMENT '数量',
  `total_price` decimal(10,2) NOT NULL COMMENT '项总价',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_item_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `user_order` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4;

/*Data for the table `order_item` */

insert  into `order_item`(`id`,`order_id`,`book_id`,`name`,`price`,`count`,`total_price`) values (5,'6a376bc569dd4e2ca845db79fb863718',9,'高性能MySQL（第4版）','128.00',1,'128.00'),(6,'6a376bc569dd4e2ca845db79fb863718',15,'人工智能：一种现代的方法（第4版）','198.00',4,'792.00'),(7,'8c18ab9ba1574720b4cde40fc4f4f3e0',5,'计算机网络（第8版）','59.80',3,'179.40'),(8,'8c18ab9ba1574720b4cde40fc4f4f3e0',11,'Redis设计与实现','79.00',2,'158.00'),(9,'df4bca2487c44bbb81e003105ca1dec2',3,'算法（第4版）','99.00',3,'297.00'),(10,'df4bca2487c44bbb81e003105ca1dec2',4,'大话数据结构','59.00',3,'177.00'),(11,'656c9637de9e4cec9c5cc78d80595ce0',3,'算法（第4版）','99.00',3,'297.00'),(12,'656c9637de9e4cec9c5cc78d80595ce0',4,'大话数据结构','59.00',4,'236.00'),(13,'32fc55f777734ea3b4a274d71667aaa3',6,'计算机网络：自顶向下方法（原书第7版）','89.00',3,'267.00'),(14,'32fc55f777734ea3b4a274d71667aaa3',7,'TCP/IP详解 卷1：协议','98.00',2,'196.00');

/*Table structure for table `user_info` */

DROP TABLE IF EXISTS `user_info`;

CREATE TABLE `user_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(50) NOT NULL COMMENT '密码',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `balance` decimal(10,2) DEFAULT '0.00' COMMENT '账户余额',
  `address` varchar(255) DEFAULT NULL COMMENT '收货地址',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `avatar` varchar(200) DEFAULT '/static/img/avatar/default.jpg' COMMENT '头像路径',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

/*Data for the table `user_info` */

insert  into `user_info`(`id`,`username`,`password`,`email`,`balance`,`address`,`phone`,`avatar`) values (2,'个别的十一人','12345678','ghost@gmail.com','2500.00','武汉理工大学','18888888888','/static/img/avatar/Batman.jpg'),(3,'GhostInTheShell','12345678','ghost@gmail.com','0.00',NULL,NULL,'/static/img/avatar/default.jpg'),(4,'Jupiter','12345678','Jupter@gmail.com','0.00',NULL,NULL,'/static/img/avatar/default.jpg'),(5,'Mars','12345678','Mars@gmail.com','0.00',NULL,NULL,'/static/img/avatar/default.jpg'),(6,'venus','12345678','venus@gmail.com','1004.00','武汉城市学院','18828736281','/static/img/avatar/Wonder Woman.jpg'),(7,'mercury','12345678','mercury@gmail.com','1188.60','武汉城市学院','18938763029','/static/img/avatar/Flash.jpg');

/*Table structure for table `user_order` */

DROP TABLE IF EXISTS `user_order`;

CREATE TABLE `user_order` (
  `order_id` varchar(50) NOT NULL COMMENT '订单号(UUID)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `total_money` decimal(10,2) NOT NULL COMMENT '订单总金额',
  `status` int(11) DEFAULT '0' COMMENT '状态：0-未付款, 1-已付款未发货, 2-已发货，3-已收货',
  `user_id` int(11) DEFAULT NULL COMMENT '下单用户',
  `receiver_address` varchar(255) DEFAULT NULL COMMENT '收货地址快照',
  `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货电话快照',
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_info` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Data for the table `user_order` */

insert  into `user_order`(`order_id`,`create_time`,`total_money`,`status`,`user_id`,`receiver_address`,`receiver_phone`) values ('32fc55f777734ea3b4a274d71667aaa3','2025-12-29 10:33:57','463.00',2,6,'武汉城市学院','18828736281'),('656c9637de9e4cec9c5cc78d80595ce0','2025-12-29 10:33:28','533.00',2,6,'武汉城市学院','18828736281'),('6a376bc569dd4e2ca845db79fb863718','2025-12-23 23:39:27','920.00',3,2,'武汉理工大学','18888888888'),('8c18ab9ba1574720b4cde40fc4f4f3e0','2025-12-29 09:40:38','337.40',2,7,'武汉城市学院','18938763029'),('df4bca2487c44bbb81e003105ca1dec2','2025-12-29 09:41:18','474.00',2,7,'武汉城市学院','18938763029');

/*Table structure for table `user_preference` */

DROP TABLE IF EXISTS `user_preference`;

CREATE TABLE `user_preference` (
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`category_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `user_preference_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_info` (`id`),
  CONSTRAINT `user_preference_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Data for the table `user_preference` */

insert  into `user_preference`(`user_id`,`category_id`) values (2,1),(7,2),(6,3),(7,4),(2,5),(6,6);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
