import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/utils/TextUtils.dart';

class Cart {

  int id;
  int quantity;
  bool active;
  int productId;
  Product product;


  Cart(this.id, this.quantity, this.active, this.productId, this.product);

  static Cart fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int productId = int.parse(jsonObject['product_id'].toString());
    int quantity = int.parse(jsonObject['quantity'].toString());
    bool active = TextUtils.parseBool(jsonObject['active'].toString());
    Product product;
    if(jsonObject['product']!=null) {
      product = Product.fromJson(jsonObject['product']);
      if(!active){
        product.name = jsonObject['p_name'];
        product.description = jsonObject['p_description'];
        product.price = double.parse(jsonObject['p_price'].toString());
        product.offer = int.parse(jsonObject['p_offer'].toString());
      }
    }

    return Cart(id, quantity, active, productId, product);
  }

  static List<Cart> getListFromJson(List<dynamic> jsonArray) {
    List<Cart> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Cart.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'Cart{id: $id, quantity: $quantity, active: $active, product: $product}';
  }
}