import 'package:EMallApp/utils/TextUtils.dart';

class ProductImage {
  int id;
  String url;
  int productId;

  ProductImage(this.id, this.url, this.productId);

  static ProductImage fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString()) ;
    String url = TextUtils.getImageUrl(jsonObject['url'].toString());
    int productId = int.parse(jsonObject['product_id'].toString());

    return ProductImage(id, url, productId);
  }

  static List<ProductImage> getListFromJson(List<dynamic> jsonArray) {
    List<ProductImage> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ProductImage.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'ProductImage{id: $id, url: $url, productId: $productId}';
  }
}
