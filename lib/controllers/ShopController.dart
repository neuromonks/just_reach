import 'dart:convert';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AuthController.dart';

class ShopController {
  //------------------------ Get single shop -----------------------------------------//
  static Future<MyResponse<Shop>> getSingleShop(int shopId) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS + "/" + shopId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Shop>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<Shop> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Shop.fromJson(json.decode(response.body));
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<Shop>();
    }
  }

  //------------------------ Get all shop -----------------------------------------//
  static Future<MyResponse<List<Shop>>> getAllShop() async {
    //Getting User Api Token
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.SHOPS +
        // "?pinCode=411046";

        "?pinCode=${preferences.getString("pincode")}";
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);
    print('rohit');
    print(headers.toString());
    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Shop>>();
    }
    print(url);
    try {
      http.Response response = await http.get(url, headers: headers);

      MyResponse<List<Shop>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Shop.getListFromJson(json.decode(response.body));
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Shop>>();
    }
  }
}
