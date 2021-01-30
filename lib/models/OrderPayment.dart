
import 'package:EMallApp/utils/TextUtils.dart';

class OrderPayment {
  int id;
  int  paymentType;
  bool success;
  String razorpayId;


  OrderPayment(this.id, this.paymentType, this.success, this.razorpayId);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int paymentType = int.parse(jsonObject['payment_type'].toString());
    bool success = TextUtils.parseBool(jsonObject['success'].toString());
    String razorpayId = jsonObject['razorpay_id'].toString();

    return OrderPayment(id, paymentType, success, razorpayId);
  }

  static List<OrderPayment> getListFromJson(List<dynamic> jsonArray) {
    List<OrderPayment> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(OrderPayment.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'OrderPayment{id: $id, paymentType: $paymentType, success: $success, razorpayId: $razorpayId}';
  }
}
