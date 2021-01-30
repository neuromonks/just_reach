import 'dart:convert';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Favorite.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:http/http.dart' as http;

import 'AuthController.dart';

class FavoriteController{


  //------------------------ Toggle favorite ----------------------------------------//
  static Future<MyResponse> toggleFavorite(int productId) async {

    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FAVORITES;
    Map<String, String> headers = ApiUtil.getHeader(
        requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = {
      'product_id': productId,
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      http.Response response = await http.post(
          url, headers: headers, body: body);
      MyResponse<dynamic> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = json.decode(response.body);
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }


  //------------------------ Get all orders  -----------------------------------------//
  static Future<MyResponse<List<Favorite>>> getAllOrder() async {

    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FAVORITES;
    Map<String, String> headers = ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);


    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if(!isConnected){
      return MyResponse.makeInternetConnectionError<List<Favorite>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Favorite>> myResponse = MyResponse(response.statusCode);

      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        myResponse.data = Favorite.getListFromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> data = json.decode(response.body);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<Favorite>>();
    }

  }
}