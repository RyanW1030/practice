package com.bookstore.bean;


import java.math.BigDecimal;

public class OrderItem {

  private int id;
  private String order_id;
  private int book_id;
  private String name;
  private BigDecimal price;
  private int count;
  private BigDecimal total_price;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getOrder_id() {
    return order_id;
  }

  public void setOrder_id(String order_id) {
    this.order_id = order_id;
  }

  public int getBook_id() {
    return book_id;
  }

  public void setBook_id(int book_id) {
    this.book_id = book_id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public BigDecimal getPrice() {
    return price;
  }

  public void setPrice(BigDecimal price) {
    this.price = price;
  }

  public int getCount() {
    return count;
  }

  public void setCount(int count) {
    this.count = count;
  }

  public BigDecimal getTotal_price() {
    return total_price;
  }

  public void setTotal_price(BigDecimal total_price) {
    this.total_price = total_price;
  }
}
