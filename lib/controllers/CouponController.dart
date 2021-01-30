import 'dart:convert';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Coupon.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:http/http.dart' as http;
import 'AuthController.dart';

class CouponController {
  //------------------------ Get all coupons -----------------------------------------//
  static Future<MyResponse<List<Coupon>>> getAllCoupon() async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.COUPONS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Coupon>>();
    }

    try {
      http.Response response = await http.get(
        url,
        headers: headers,
      );
      MyResponse<List<Coupon>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Coupon.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Coupon>>();
    }
  }

  static Future<MyResponse<List<Coupon>>> getCouponForShop(int shopId) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.SHOPS +
        "/" +
        shopId.toString() +
        "/" +
        ApiUtil.COUPONS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Coupon>>();
    }

    try {
      http.Response response = await http.get(
        url,
        headers: headers,
      );
      MyResponse<List<Coupon>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Coupon.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Coupon>>();
    }
  }
}
