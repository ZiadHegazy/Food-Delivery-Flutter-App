import 'package:flutter/material.dart';
import 'package:food_deliver/BottomNavBar.dart';
import 'package:food_deliver/OrderModel.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
class OrderPage extends StatefulWidget {
  @override
  OrderPageState createState() => OrderPageState();
}
class OrderPageState extends State<OrderPage>{
  List<OrderModel> orders = [];
  int first=0;
  bool loading=false;


  Future<void> fetchOrdersData(SharedPreferencesService prefs) async {
    setState(() {
      loading=true;
    });

    String token = prefs.getStringData("token")?? "";
    bool login=prefs.getBoolData("login")??false;
    if(token!="" && login==true){
    final response=await http.get(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/order/userOrders/$token'));
    if(response.statusCode==200){
      final List<dynamic> jsonData=json.decode(response.body);
      List<OrderModel> temp=[];
      for(int i=0;i<jsonData.length;i++){
        List<dynamic> items=jsonData[i]['items'];
        List<OrderItem> orderItems=[];
        for(int j=0;j<items.length;j++){
          OrderItem orderItem=OrderItem(productId: items[j]['productId'], quantity: items[j]['quantity'], price: double.parse(items[j]['price'].toString()), image: items[j]['image']);
          orderItems.add(orderItem);
        }
        OrderModel order=OrderModel(userId: jsonData[i]['userId'], items: orderItems,status: jsonData[i]['status'], total: double.parse(jsonData[i]['total'].toString()), address: jsonData[i]['address']);
        temp.add(order);
      }
      setState(() {
        orders=temp;
      });
    }
    }else{
      setState(() {
        orders=[];
        loading=false;
      });
    }
    setState(() {
      loading=false;
    });
  }
  List<Widget> orderCards(){
    List<Widget> temp=[];
    for(int i=0;i<orders.length;i++){
      temp.add(Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:  BorderRadius.all(Radius.circular(10)), 
        ),
        width:MediaQuery.of(context).size.width,child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,children: [
      Container(width: MediaQuery.of(context).size.width*0.3,child: Icon(Icons.receipt_long)),
      Container(width: MediaQuery.of(context).size.width*0.6,child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        Text("Order Number: "+(i+1).toString()),
        Text("Total: "+orders[i].total.toString()),
        Text("Address: "+orders[i].address),
      ],))
      ],),));
      if(i<orders.length-1){
        temp.add(SizedBox(height: 10));
      }
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {

    final prefsService = Provider.of<SharedPreferencesService>(context);
    if(first==0){
      fetchOrdersData(prefsService);
      setState(() {
        first=1;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: Padding(padding: EdgeInsets.all(10),child: Center(
        child: loading? CircularProgressIndicator(): orders.length==0? Text("You have no orders yet",style: TextStyle(fontSize: 20),): Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: orderCards(),
        ),
      )),
    bottomNavigationBar: BottomNavBar(index:2),
    );
  }
}