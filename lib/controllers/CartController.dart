import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Cart.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:http/http.dart' as http;
import 'AuthController.dart';

class CartController {
  //------------------------ Add into cart -----------------------------------------//
  static Future<MyResponse> addIntoCart(int productId,
      {int quantity = 1}) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Make body options
    Map data = {
      'product_id': productId,
      'quantity': quantity,
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

  //------------------------ Get all cart product -----------------------------------------//
  static Future<MyResponse> getAllCartProduct() async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Cart>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Cart.getListFromJson(json.decode(response.body));
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Cart>>();
    }
  }

  //------------------------ Change cart quantity -----------------------------------------//
  static Future<MyResponse> changeCartQuantity(int cartId, int quantity) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS + "/" + cartId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = ApiUtil.getPatchRequestBody();
    data['quantity'] = quantity.toString();

    //Encoded
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

  //------------------------ Delete cart -----------------------------------------//
  static Future<MyResponse> deleteCart(int cartId) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS + "/" + cartId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.delete(url, headers: headers);
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
}
