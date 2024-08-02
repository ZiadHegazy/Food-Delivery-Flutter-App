class CategoryModel{
  String id;
  String name;
  List<String> products;
  CategoryModel({required this .id,required this.name,required this.products});
  
   String getId(){
    return id;
  }
   String getName(){
    return name;
  }
  List<String> getProducts(){
    return products;
  }
}