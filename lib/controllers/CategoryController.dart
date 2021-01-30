import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/Category.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/utils/InternetUtils.dart';

import 'package:http/http.dart' as http;

class CategoryController {

  //------------------------ Get all categories -----------------------------------------//
  static Future<MyResponse<List<Category>>> getAllCategory() async {

    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CATEGORIES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Category>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Category>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        List<Category> list =
            Category.getListFromJson(json.decode(response.body));
        myResponse.success = true;
        myResponse.data = list;
      } else {
        myResponse.setError(json.decode(response.body));
      }

      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Category>>();
    }
  }
}
