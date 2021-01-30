import 'package:EMallApp/models/Manager.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/utils/TextUtils.dart';

class Shop {
  int id, managerId;
  String name;
  String description;
  String email;
  String mobile;
  double latitude, longitude;
  String address;
  String imageUrl;
  int totalRating;
  double rating;
  double tax;

  bool availableForDelivery;
  bool isOpen;
  double deliveryFee;
  Manager manager;
  List<Product> products;


  Shop(
      this.id,
      this.managerId,
      this.name,
      this.description,
      this.email,
      this.mobile,
      this.latitude,
      this.longitude,
      this.address,
      this.imageUrl,
      this.totalRating,
      this.rating,
      this.tax,
      this.availableForDelivery,
      this.isOpen,
      this.deliveryFee,
      this.manager,
      this.products);

   static fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    String name = jsonObject['name'].toString();
    String description = jsonObject['description'].toString();
    String email = jsonObject['email'].toString();
    String mobile = jsonObject['mobile'].toString();
    double latitude = double.parse(jsonObject['latitude'].toString());
    double longitude = double.parse(jsonObject['longitude'].toString());
    String address = jsonObject['address'].toString();
    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());

    int totalRating = int.parse(jsonObject['total_rating'].toString());
    double rating = double.parse(jsonObject['rating'].toString());

    double tax = double.parse(jsonObject['default_tax'].toString());
    bool availableForDelivery =
        TextUtils.parseBool(jsonObject['available_for_delivery'].toString());
    bool isOpen = TextUtils.parseBool(jsonObject['open']);
    double deliveryFee = double.parse(jsonObject['delivery_fee'].toString());

    int managerId;
    if(jsonObject['manager_id']!=null)
      managerId = int.parse(jsonObject['manager_id'].toString());


    Manager manager;
    if(jsonObject['manager']!=null)
      manager = Manager.fromJson(jsonObject['manager']);

    List<Product> products = [];
    if(jsonObject['products']!=null)
      products = Product.getListFromJson(jsonObject['products']);

    return Shop(id, managerId, name, description, email, mobile, latitude, longitude, address, imageUrl, totalRating,rating, tax,  availableForDelivery, isOpen, deliveryFee, manager, products);
  }

  static List<Shop> getListFromJson(List<dynamic> jsonArray) {
    List<Shop> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Shop.fromJson(jsonArray[i]));
    }
    return list;
  }




  @override
  String toString() {
    return 'Shop{id: $id, name: $name, description: $description, email: $email, mobile: $mobile, latitude: $latitude, longitude: $longitude, address: $address, imageUrl: $imageUrl, tax: $tax, availableForDelivery: $availableForDelivery, isOpen: $isOpen, deliveryFee: $deliveryFee, manager: $manager}';
  }


  static String getPlaceholderImage(){
    return './assets/images/placeholder/no-shop-image.png';
  }

}
