
import 'package:EMallApp/models/DeliveryBoy.dart';
import 'package:EMallApp/models/OrderPayment.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:flutter/material.dart';

import 'Cart.dart';
import 'Coupon.dart';
import 'Shop.dart';

class Order {
  int id, couponId, addressId, shopId, orderPaymentId,orderType;
  int status,otp;
  double order, tax, deliveryFee, total, couponDiscount;
  List<Cart> carts;
  DateTime createdAt;
  Shop shop;
  Coupon coupon;
  UserAddress address;
  OrderPayment orderPayment;
  DeliveryBoy deliveryBoy;


  Order(
      this.id,
      this.couponId,
      this.addressId,
      this.shopId,
      this.orderPaymentId,
      this.orderType,
      this.status,
      this.otp,
      this.order,
      this.tax,
      this.deliveryFee,
      this.total,
      this.couponDiscount,
      this.carts,
      this.createdAt,
      this.shop,
      this.coupon,
      this.address,
      this.orderPayment,
      this.deliveryBoy);

  static Order fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int orderType = int.parse(jsonObject['order_type'].toString());
    int addressId;
    if(jsonObject['address_id']!=null)
      addressId = int.parse(jsonObject['address_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int orderPaymentId = int.parse(jsonObject['order_payment_id'].toString());

    int status = int.parse(jsonObject['status'].toString());
    int otp = int.parse(jsonObject['otp'].toString());
    double order = double.parse(jsonObject['order'].toString());
    double tax = double.parse(jsonObject['tax'].toString());
    double deliveryFee = double.parse(jsonObject['delivery_fee'].toString());
    double total = double.parse(jsonObject['total'].toString());
    double couponDiscount =
        double.parse(jsonObject['coupon_discount'].toString());
    List<Cart> carts = Cart.getListFromJson(jsonObject['carts']);

    int couponId;
    if (jsonObject['coupon_id'] != null)
      couponId = int.parse(jsonObject['coupon_id'].toString());


    Coupon coupon;
    if (jsonObject['coupon'] != null)
      coupon = Coupon.fromJson(jsonObject['coupon']);


    UserAddress address;
    if (jsonObject['address'] != null)
      address = UserAddress.fromJson(jsonObject['address']);


    Shop shop;
    if (jsonObject['shop'] != null) shop = Shop.fromJson(jsonObject['shop']);


    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    OrderPayment orderPayment;
    if (jsonObject['order_payment'] != null)
      orderPayment = OrderPayment.fromJson(jsonObject['order_payment']);

    DeliveryBoy deliveryBoy;
    if(jsonObject['delivery_boy']!=null)
      deliveryBoy = DeliveryBoy.fromJson(jsonObject['delivery_boy']);

    return Order(id, couponId, addressId, shopId, orderPaymentId, orderType, status,otp, order, tax, deliveryFee, total, couponDiscount, carts, createdAt, shop, coupon, address, orderPayment, deliveryBoy);

  }

  static List<Order> getListFromJson(List<dynamic> jsonArray) {
    List<Order> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Order.fromJson(jsonArray[i]));
    }
    return list;
  }

  static String getTextFromOrderStatus(int status,int orderType) {

    if(Order.isPickUpOrder(orderType)){
      switch (status) {
        case 0:
          return Translator.translate("wait_for_payment");
        case 1:
          return Translator.translate("wait_for_confirmation");
        case 2:
          return Translator.translate("accepted_and_packaging");
        case 3:
          return Translator.translate("pickup_order_from_shop");
        case 4:
        case 5:
          return Translator.translate("delivered");
        case 6:
          return Translator.translate("reviewed");
        default:
          return getTextFromOrderStatus(1,orderType);
      }
    }else {
      switch (status) {
        case 0:
          return Translator.translate("wait_for_payment");
        case 1:
          return Translator.translate("wait_for_confirmation");
        case 2:
          return Translator.translate("accepted_and_packaging");
        case 3:
          return Translator.translate("wait_for_delivery_boy");
        case 4:
          return Translator.translate("on_the_way");
        case 5:
          return Translator.translate("delivered");
        case 6:
          return Translator.translate("reviewed");
        default:
          return getTextFromOrderStatus(1,orderType);
      }
    }
  }

  static String getTextFromOrderType(int type){
    switch(type){
      case 1:
        return Translator.translate("self_pickup");
      case 2:
        return  Translator.translate("home_delivery");
    }
    return getTextFromOrderType(1);
  }

  static Color getColorFromOrderStatus(int status) {
    switch (status) {
      case 1:
        return Color.fromRGBO(255, 170, 85, 1.0);
      case 2:
        return Color.fromRGBO(90, 149, 154, 1.0);
      case 3:
        return Color.fromRGBO(255, 170, 85, 1.0);
      case 4:
        return Color.fromRGBO(34, 187, 51, 1.0);
      case 5:
        return Color.fromRGBO(34, 187, 51, 1.0);
      default:
        return getColorFromOrderStatus(1);
    }
  }

  static bool checkWaitForPayment(int status) {
    return status == 0;
  }

  static bool checkStatusDelivered(int status) {
    return status == 5;
  }

  static bool checkStatusReviewed(int status) {
    return status == 6;
  }

  static String getPaymentTypeText(int paymentType) {
    switch (paymentType) {
      case 1:
        return  Translator.translate("cash_on_delivery");
      case 2:
        return  Translator.translate("razorpay");
    }
    return getPaymentTypeText(1);
  }

  static bool isPaymentByCOD(int paymentType) {
    return paymentType == 1;
  }
  static bool isOrderCompleteWithReview(int status) {
    return status == 6;
  }

  static double getDiscountFromCoupon(double originalOrderPrice, int offer) {
    return originalOrderPrice * offer / 100;
  }

  static bool isPickUpOrder(int orderType){
    return orderType==1;
  }

  @override
  String toString() {
    return 'Order{id: $id, couponId: $couponId, addressId: $addressId, shopId: $shopId, orderPaymentId: $orderPaymentId, orderType: $orderType, status: $status, order: $order, tax: $tax, deliveryFee: $deliveryFee, total: $total, couponDiscount: $couponDiscount, createdAt: $createdAt, shop: $shop, coupon: $coupon, address: $address, orderPayment: $orderPayment, deliveryBoy: $deliveryBoy}';
  }
}
