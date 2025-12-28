package com.bookstore.bean;


import java.math.BigDecimal;
import java.sql.Timestamp;

public class UserOrder {

  private String order_id;
  private java.sql.Timestamp create_time;
  private BigDecimal total_money;
  private int status;
  private int user_id;
  private String receiver_address;
  private String receiver_phone;

  public String getOrder_id() {
    return order_id;
  }

  public void setOrder_id(String order_id) {
    this.order_id = order_id;
  }

  public Timestamp getCreate_time() {
    return create_time;
  }

  public void setCreate_time(Timestamp create_time) {
    this.create_time = create_time;
  }

  public BigDecimal getTotal_money() {
    return total_money;
  }

  public void setTotal_money(BigDecimal total_money) {
    this.total_money = total_money;
  }

  public int getStatus() {
    return status;
  }

  public void setStatus(int status) {
    this.status = status;
  }

  public int getUser_id() {
    return user_id;
  }

  public void setUser_id(int user_id) {
    this.user_id = user_id;
  }

  public String getReceiver_address() {
    return receiver_address;
  }

  public void setReceiver_address(String receiver_address) {
    this.receiver_address = receiver_address;
  }

  public String getReceiver_phone() {
    return receiver_phone;
  }

  public void setReceiver_phone(String receiver_phone) {
    this.receiver_phone = receiver_phone;
  }
}
