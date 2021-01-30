
class UserAddress {
  int id;
  String address;
  String address2;
  double latitude;
  double longitude;
  String city;
  int pincode;

  UserAddress(this.id, this.address, this.address2, this.latitude,
      this.longitude, this.city, this.pincode);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String address = jsonObject['address'].toString();
    String address2;
    if (jsonObject['address2'].toString().compareTo("null") != 0)
      address2 = jsonObject['address2'].toString();
    double latitude = double.parse(jsonObject['latitude'].toString());
    double longitude = double.parse(jsonObject['longitude'].toString());
    String city = jsonObject['city'].toString();
    int pincode = int.parse(jsonObject['pincode'].toString());
    return UserAddress(
        id, address, address2, latitude, longitude, city, pincode);
  }

  static List<UserAddress> getListFromJson(List<dynamic> jsonArray) {
    List<UserAddress> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(UserAddress.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'UserAddress{id: $id, address: $address, address2: $address2, latitude: $latitude, longitude: $longitude, city: $city, pincode: $pincode}';
  }
}
