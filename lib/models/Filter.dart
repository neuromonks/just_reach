class Filter {

  List<int> categories;
  String name = "";
  bool isInOffer;

  Filter(){
    categories=[];
    isInOffer = false;
  }

  Filter.clear() {
    categories = [];
    isInOffer = false;
  }

  clearCategory(){
    this.categories = [];
  }

  toggleCategory(int categoryId) {
    if (categories.contains(categoryId)) {
      categories.remove(categoryId);
    } else {
      categories.add(categoryId);
    }
  }

  setIsInOffer(bool isInOffer){
    this.isInOffer = isInOffer;
  }
}
