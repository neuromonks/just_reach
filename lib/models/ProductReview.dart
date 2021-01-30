import 'package:EMallApp/models/User.dart';

class ProductReview{

  int id,rating,orderId,productId,userId;
  String review;
  DateTime createdAt;

  User user;


  ProductReview(this.id, this.rating, this.orderId, this.productId, this.userId,
      this.review,this.createdAt,this.user);

  ProductReview.dummy(this.id, this.rating, this.orderId, this.productId, this.userId,
      this.review);

  static ProductReview fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    int rating = int.parse(jsonObject['rating'].toString());
    int productId = int.parse(jsonObject['product_id'].toString());
    int orderId = int.parse(jsonObject['order_id'].toString());
    int userId = int.parse(jsonObject['user_id'].toString());

    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    String review = "No review";
    if(jsonObject['review']!=null)
      review = jsonObject['review'].toString();


    User user;
    if(jsonObject['user']!=null){
      user = User.fromJson(jsonObject['user']);
    }

    return ProductReview(id, rating, orderId, productId, userId, review,createdAt,user,);
  }

  static List<ProductReview> getListFromJson(List<dynamic> jsonArray) {
    List<ProductReview> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ProductReview.fromJson(jsonArray[i]));
    }
    return list;
  }



}