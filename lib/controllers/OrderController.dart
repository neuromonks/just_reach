import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Cart.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/models/OrderReview.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'AuthController.dart';
import 'package:http/http.dart' as http;

class OrderController {
  //------------------------ Add order from carts -----------------------------------------//
  static Future<MyResponse<Order>> addOrder(
      double order,
      double tax,
      double deliveryFee,
      double total,
      List<Cart> carts,
      int paymentType,
      int status,
      int orderType,
      {int addressId,
      int couponId,
      double couponDiscount}) async {
    //Create body data
    String cartsList = "";
    for (int i = 0; i < carts.length; i++) {
      cartsList += carts[i].id.toString();
      if (i < carts.length - 1) {
        cartsList += ",";
      }
    }

    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body Data
    Map data = {
      'payment_type': paymentType,
      'address_id': addressId,
      'order': order,
      'tax': tax,
      'coupon_discount': couponDiscount,
      'delivery_fee': deliveryFee,
      'total': total,
      'carts': cartsList,
      'status': status,
      'order_type': orderType
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response =
          await http.post(url, headers: headers, body: body);
      MyResponse<Order> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Order.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }

  //------------------------ Get all orders -----------------------------------------//
  static Future<MyResponse<List<Order>>> getAllOrder() async {
    //Get API Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);

      MyResponse<List<Order>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Order.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Order>>();
    }
  }

  //------------------------ Get single order -----------------------------------------//
  static Future<MyResponse<Order>> getSingleOrder(int id) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + "/" + id.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Order> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Order.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }

  //------------------------ Get single order review -----------------------------------------//
  static Future<MyResponse<OrderReview>> getSingleOrderReview(int id) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.ORDERS +
        "/" +
        id.toString() +
        "/" +
        ApiUtil.REVIEWS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<OrderReview> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = OrderReview.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...

      return MyResponse.makeServerProblemError<OrderReview>();
    }
  }

  //------------------------ Update payment status -----------------------------------------//
  static Future<MyResponse> updatePayment(
      int orderId, bool success, String razorpayId) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url =
        ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + "/" + orderId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = ApiUtil.getPatchRequestBody();
    data['success'] = TextUtils.boolToString(success);
    data['razorpay_id'] = razorpayId;

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response =
          await http.post(url, headers: headers, body: body);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }

  //------------------------- update order for -----------------------------//
  static Future<MyResponse> updateOrder(int orderId, int status) async {
    //Get Token
    String token = await AuthController.getApiToken();
    String url =
        ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + "/" + orderId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = ApiUtil.getPatchRequestBody();
    data['status'] = status;

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response =
          await http.post(url, headers: headers, body: body);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      return MyResponse.makeServerProblemError();
    }
  }
}
