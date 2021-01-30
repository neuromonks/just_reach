import 'package:EMallApp/utils/TextUtils.dart';

class Coupon{

  int id;
  String code;
  String description;
  int offer;
  double minOrder,maxDiscount;
  bool isActivate;
  DateTime startedAt,expiredAt;


  Coupon(this.id, this.code, this.description, this.offer, this.minOrder,
      this.maxDiscount, this.isActivate, this.startedAt, this.expiredAt);

  static Coupon fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String code = jsonObject['code'].toString();
    String description = jsonObject['description'].toString();
    int offer = int.parse(jsonObject['offer'].toString());
    double minOrder = double.parse(jsonObject['min_order'].toString());
    double maxDiscount = double.parse(jsonObject['max_discount'].toString());
    bool isActivate = TextUtils.parseBool(jsonObject['is_activate'].toString());
    DateTime startedAt = DateTime.parse(jsonObject['started_at'].toString());
    DateTime expiredAt = DateTime.parse(jsonObject['expired_at'].toString());
    return Coupon(id, code, description, offer, minOrder, maxDiscount, isActivate, startedAt, expiredAt);
  }

  static List<Coupon> getListFromJson(List<dynamic> jsonArray) {
    List<Coupon> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Coupon.fromJson(jsonArray[i]));
    }
    return list;
  }

  double getDiscountValue(double order){
    double discount = (order*offer /100);
    if(discount>maxDiscount){
      return maxDiscount;
    }else{
      return discount;
    }
  }

  static getDiscountedOrderValueByCoupon(Coupon coupon,double order){
    return coupon.getDiscountValue(order);
  }

}