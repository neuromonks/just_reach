
class DeliveryBoyReview{

  int id,rating,userId,deliveryBoyId,orderId;
  String review;
  DateTime createdAt;

  DeliveryBoyReview(this.id, this.rating, this.deliveryBoyId, this.userId, this.orderId,
      this.review,this.createdAt);

  DeliveryBoyReview.forOrder(this.id, this.rating, this.deliveryBoyId, this.review);

  static DeliveryBoyReview fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    int rating = int.parse(jsonObject['rating'].toString());
    int deliveryBoyId = int.parse(jsonObject['delivery_boy_id'].toString());
    int userId = int.parse(jsonObject['user_id'].toString());
    int orderId = int.parse(jsonObject['order_id'].toString());

    DateTime createdAt = DateTime.parse(jsonObject['created_at'].toString());

    String review;
    if(jsonObject['review']!=null)
      review = jsonObject['review'].toString();



    return DeliveryBoyReview(id, rating, deliveryBoyId,  userId,orderId, review,createdAt);
  }

  static List<DeliveryBoyReview> getListFromJson(List<dynamic> jsonArray) {
    List<DeliveryBoyReview> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(DeliveryBoyReview.fromJson(jsonArray[i]));
    }
    return list;
  }



}