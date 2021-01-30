import 'Cart.dart';

class CustomCart {
  int shopId;
  String shopName;
  List<Cart> carts;

  CustomCart(this.shopId, this.shopName, this.carts);

  static fromCarts(List<Cart> carts) {
    List<CustomCart> customCarts = [];
    for (int i = 0; i < carts.length; i++) {
      customCarts = _addSingle(customCarts, carts[i]);
    }
    return customCarts;
  }

  static _addSingle(List<CustomCart> customCarts, Cart singleCart) {
    for (int i = 0; i < customCarts.length; i++) {
      if (customCarts[i].shopId == singleCart.product.shop.id) {
        customCarts[i].carts.add(singleCart);
        return customCarts;
      }
    }
    customCarts.add(CustomCart(singleCart.product.shop.id,
        singleCart.product.shop.name, [singleCart]));
    return customCarts;
  }

  @override
  String toString() {
    return 'CustomCart{shopId: $shopId, shopName: $shopName, carts: $carts}';
  }
}
