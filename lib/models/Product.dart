import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/models/Category.dart';
import 'package:EMallApp/models/ProductImage.dart';
import 'package:EMallApp/models/ProductReview.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:flutter/material.dart';

import 'Shop.dart';

class Product {
  int id, categoryId, shopId;
  String name;
  String description;
  int quantity;
  double price;
  double rating;
  int totalRating;
  int offer;
  bool isFavorite;
  Category category;
  Shop shop;
  List<ProductImage> productImages;
  List<ProductReview> reviews;


  Product(
      this.id,
      this.categoryId,
      this.shopId,
      this.name,
      this.description,
      this.quantity,
      this.price,
      this.rating,
      this.totalRating,
      this.offer,
      this.isFavorite,
      this.category,
      this.shop,
      this.productImages,
      this.reviews);

  static Product fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int categoryId = int.parse(jsonObject['category_id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    String name = jsonObject['name'];
    String description = jsonObject['description'];
    int quantity = int.parse(jsonObject['quantity'].toString());
    double price = double.parse(jsonObject['price'].toString());
    int offer = int.parse(jsonObject['offer'].toString());
    double rating = double.parse(jsonObject['rating'].toString());
    int totalRating = int.parse(jsonObject['total_rating'].toString());
    bool isFavorite =
        TextUtils.parseBool(jsonObject['is_favorite'].toString());

    Category category;
    if (jsonObject['category'] != null)
      category = Category.fromJson(jsonObject['category']);

    Shop shop;
    if (jsonObject['shop'] != null) shop = Shop.fromJson(jsonObject['shop']);

    List<ProductImage> productImages;
    if (jsonObject['product_images'] != null)
      productImages =
          ProductImage.getListFromJson(jsonObject['product_images']);

    List<ProductReview> reviews;
    if(jsonObject['product_reviews']!=null)
      reviews = ProductReview.getListFromJson(jsonObject['product_reviews']);

    return Product(id, categoryId, shopId, name, description, quantity, price, rating, totalRating, offer, isFavorite, category, shop, productImages, reviews);
  }

  static List<Product> getListFromJson(List<dynamic> jsonArray) {
    List<Product> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Product.fromJson(jsonArray[i]));
    }
    return list;
  }


  @override
  String toString() {
    return 'Product{id: $id, categoryId: $categoryId, shopId: $shopId, name: $name, description: $description, quantity: $quantity, price: $price, rating: $rating, totalRating: $totalRating, offer: $offer, isFavorite: $isFavorite, category: $category, shop: $shop, productImages: $productImages, reviews: $reviews}';
  }

  static Text getTextFromQuantity(int quantity, TextStyle style, ThemeData themeData,CustomAppTheme customAppTheme){
    Color color;
    String text;
    if(quantity>8){
      color = themeData.colorScheme.onBackground;
      text = Translator.translate("in_stock");
    }else if(quantity>4){
      color = customAppTheme.colorInfo;
      text = Translator.translate("few_items_available");
    }else if(quantity>0){
      color = customAppTheme.colorError;
      text= Translator.translate("only")+ " " +quantity.toString()+ " " + Translator.translate("items_available");
    }else{
      color = customAppTheme.colorError;
      text=Translator.translate("stock_out");
    }

    return Text(text,style: style.copyWith(color: color),);
  }

  static Widget offerTextWidget(
      {double originalPrice,
        int offer,
        ThemeData themeData,
        CustomAppTheme customAppTheme,
        double fontSize = 18}) {
    if (offer == 0) {
      return Text(CurrencyApi.getSign(afterSpace: true) + originalPrice.toString(),
          style: AppTheme.getTextStyle(themeData.textTheme.caption,
              color: themeData.colorScheme.onBackground,
              fontSize: fontSize,
              fontWeight: 600,
              letterSpacing: 0,
              wordSpacing: -1));
    } else {
      double discountedPrice = getOfferedPrice(originalPrice, offer);

      return Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyApi.getSign(afterSpace: true) +  CurrencyApi.doubleToString(discountedPrice),
                style: AppTheme.getTextStyle(themeData.textTheme.caption,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600,
                    fontSize: fontSize, letterSpacing: 0.2, height: 0),
            ),
            Container(
              margin: Spacing.left(4),
              child: Text( CurrencyApi.getSign(afterSpace: true) +  CurrencyApi.doubleToString(originalPrice),
                  style: AppTheme.getTextStyle(themeData.textTheme.caption,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: fontSize * 0.6,
                      letterSpacing: 0,
                      wordSpacing: -1,height: 0,muted: true,
                      decoration: TextDecoration.lineThrough)),
            ),
          ],
        ),
      );
    }
  }


  static double getOfferedPrice(double originalPrice,int offer){
    return originalPrice * (1 - offer / 100);
  }



  static String getPlaceholderImage(){
    return './assets/images/placeholder/no-product-image.png';
  }




}
