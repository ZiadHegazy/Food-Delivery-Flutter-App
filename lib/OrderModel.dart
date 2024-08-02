class OrderItem{
  String productId;
  int quantity;
  double price;
  String image;
  OrderItem({required this.productId,required this.quantity,required this.price,required this.image});
}
class OrderModel{
  String userId;
  List<OrderItem> items;
  String status="pending";
  double total;
  String address;
  OrderModel({required this.userId,required this.items,required this.status,required this.total,required this.address});
}