
class ShopReview{

  int id,rating,userId,shopId;
  String review;
  DateTime createdAt;

  ShopReview(this.id, this.rating, this.shopId, this.userId,
      this.review,this.createdAt);

  static ShopReview fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    int rating = int.parse(jsonObject['rating'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    int userId = int.parse(jsonObject['user_id'].toString());

    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    String review;
    if(jsonObject['review']!=null)
      review = jsonObject['review'].toString();



    return ShopReview(id, rating, shopId,  userId, review,createdAt);
  }

  static List<ShopReview> getListFromJson(List<dynamic> jsonArray) {
    List<ShopReview> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ShopReview.fromJson(jsonArray[i]));
    }
    return list;
  }



}