
import 'package:EMallApp/models/DeliveryBoy.dart';
import 'package:EMallApp/models/DeliveryBoyReview.dart';
import 'package:EMallApp/models/OrderPayment.dart';
import 'package:EMallApp/models/ProductReview.dart';
import 'package:EMallApp/models/ShopReview.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:flutter/material.dart';

import 'Cart.dart';
import 'Coupon.dart';
import 'Shop.dart';

class OrderReview {
  int id, couponId, addressId, shopId, orderPaymentId,orderType;
  int status;
  double order, tax, deliveryFee, total, couponDiscount;
  List<Cart> carts;
  DateTime createdAt;
  Shop shop;
  Coupon coupon;
  UserAddress address;
  OrderPayment orderPayment;
  DeliveryBoy deliveryBoy;
  List<ProductReview> productReviews;
  ShopReview shopReview;
  DeliveryBoyReview deliveryBoyReview;



  OrderReview(
      this.id,
      this.couponId,
      this.addressId,
      this.shopId,
      this.orderPaymentId,
      this.orderType,
      this.status,
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
      this.deliveryBoy,
      this.productReviews,
      this.shopReview,
      this.deliveryBoyReview);

  static OrderReview fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int orderType = int.parse(jsonObject['order_type'].toString());
    int addressId;
    if(jsonObject['address_id']!=null)
      addressId = int.parse(jsonObject['address_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int orderPaymentId = int.parse(jsonObject['order_payment_id'].toString());

    int status = int.parse(jsonObject['status'].toString());
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

    List<ProductReview> productReviews;
    if(jsonObject['product_reviews']!=null)
        productReviews = ProductReview.getListFromJson(jsonObject['product_reviews']);



    ShopReview shopReview;
    if(jsonObject['shop_review']!=null)
      shopReview = ShopReview.fromJson(jsonObject['shop_review']);


    DeliveryBoyReview deliveryBoyReview;
    if(jsonObject['delivery_boy_review']!=null)
      deliveryBoyReview = DeliveryBoyReview.fromJson(jsonObject['delivery_boy_review']);

    return OrderReview(id, couponId, addressId, shopId, orderPaymentId, orderType,
        status, order, tax, deliveryFee, total, couponDiscount, carts, createdAt, shop, coupon, address,
        orderPayment, deliveryBoy,productReviews,shopReview,deliveryBoyReview);

  }

  static List<OrderReview> getListFromJson(List<dynamic> jsonArray) {
    List<OrderReview> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(OrderReview.fromJson(jsonArray[i]));
    }
    return list;
  }

  static String getTextFromOrderStatus(int status,int orderType) {

    if(OrderReview.isPickUpOrder(orderType)){
      switch (status) {
        case 0:
          return Translator.translate("wait_for_payment");
        case 1:
          return Translator.translate("wait_for_confirmation");
        case 2:
          return Translator.translate("accepted");
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
          return Translator.translate("accepted");
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


  ProductReview getProductReviewFromId(int id){
    for(ProductReview productReview in productReviews){
      if(productReview.productId==id)
        return productReview;
    }
    return null;
  }

}
