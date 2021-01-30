import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:http/http.dart' as http;
import 'AuthController.dart';

class AddressController {
  //-------------------- Add user address --------------------------------//
  static Future<MyResponse> addAddress(
      {double latitude,
      double longitude,
      String address,
      String address2,
      String city,
      int pincode}) async {
    //Get Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body Data
    Map data = {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'address2': address2,
      'city': city,
      'pincode': pincode
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
      if (response.statusCode == 200) {
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

  //-------------------- Get all address for currently login user --------------------------------//
  static Future<MyResponse<List<UserAddress>>> getMyAddresses() async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<UserAddress>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);

      MyResponse<List<UserAddress>> myResponse =
          MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data =
            UserAddress.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<UserAddress>>();
    }
  }

  //-------------------- Delete user address --------------------------------//
  static Future<MyResponse> deleteAddress(int addressId) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url =
        ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES + "/" + addressId.toString();
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
