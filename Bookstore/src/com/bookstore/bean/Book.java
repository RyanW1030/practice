package com.bookstore.bean;


import java.math.BigDecimal;

public class Book {

  private int id;
  private String name;
  private String author;
  private BigDecimal price;
  private int sales;
  private int stock;
  private String intro;
  private String publisher;
  private String isbn;
  private String img_path;
  private int category_id;


  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }


  public String getAuthor() {
    return author;
  }

  public void setAuthor(String author) {
    this.author = author;
  }


  public BigDecimal getPrice() {
    return price;
  }

  public void setPrice(BigDecimal price) {
          this.price = price;
  }


  public int getSales() {
    return sales;
  }

  public void setSales(int sales) {
    this.sales = sales;
  }

  public int getStock() {
    return stock;
  }

  public void setStock(int stock) {
    this.stock = stock;
  }

  public String getIntro() {
    return intro;
  }

  public void setIntro(String intro) {
    this.intro = intro;
  }


  public String getPublisher() {
    return publisher;
  }

  public void setPublisher(String publisher) {
    this.publisher = publisher;
  }


  public String getIsbn() {
    return isbn;
  }

  public void setIsbn(String isbn) {
    this.isbn = isbn;
  }

  public String getImg_path() {
    return img_path;
  }

  public void setImg_path(String img_path) {
    this.img_path = img_path;
  }

  public int getCategory_id() {
    return category_id;
  }

  public void setCategory_id(int category_id) {
    this.category_id = category_id;
  }

  @Override
  public String toString() {
    return "Book{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", author='" + author + '\'' +
            ", price=" + price +
            ", sales=" + sales +
            ", stock=" + stock +
            ", intro='" + intro + '\'' +
            ", publisher='" + publisher + '\'' +
            ", isbn='" + isbn + '\'' +
            ", imgPath='" + img_path + '\'' +
            ", categoryId=" + category_id +
            '}';
  }
}
