
import 'package:EMallApp/utils/TextUtils.dart';

class Category {
  int id;
  String title;
  String description;
  String imageUrl;

  Category(this.id, this.title, this.description, this.imageUrl);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String title = jsonObject['title'].toString();
    String description = jsonObject['description'].toString();
    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());
    return Category(id, title, description, imageUrl);
  }

  static List<Category> getListFromJson(List<dynamic> jsonArray) {
    List<Category> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Category.fromJson(jsonArray[i]));
    }
    return list;
  }


  @override
  String toString() {
    return 'Category{id: $id, title: $title, description: $description, imageUrl: $imageUrl}';
  }
}
