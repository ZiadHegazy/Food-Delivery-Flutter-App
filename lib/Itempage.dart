import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_deliver/BottomNavBar.dart';
import 'package:food_deliver/ProductModel.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:food_deliver/util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class Itempage extends StatefulWidget {
  @override
  ItempageState createState() => ItempageState();
}
class ItempageState extends State<Itempage>
{
  int itemCount=1;
  bool addedToCart=false;


  @override
  void initState() {

    super.initState();
  }

  void handleAddToCart(item,SharedPreferencesService prefsService) async {
    List<String> cart = prefsService.getListData("cart") ?? [];
    String itemString=jsonEncode({"id":item.id,"name":item.name,"price":item.price,"image":item.image,"description":item.description,"quantity":itemCount.toString()});
    
    List<String> newCart=cart + [itemString];
    if(prefsService.getBoolData("login")==true){
      final response=await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/cart/addToCart'),
      body: jsonEncode({"productId":item.id,
      "quantity":itemCount,
      "token":prefsService.getStringData("token"),
      "price":item.price,
      "image":item.image,
      "name":item.name,
      }),headers: {"Content-Type": "application/json"});
      
    }
    prefsService.updateListData("cart", newCart);
    setState(() {
        addedToCart=true;
        
      });

  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final screenSize = MediaQuery.of(context).size;
    final prefsService = Provider.of<SharedPreferencesService>(context);


    return Scaffold(
      appBar: AppBar(
        title: Text(args.name+"Page"),
      ),
      body: Padding(padding: EdgeInsets.all(10),
      child:Center(
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Container(
            width: screenSize.width,
            height: screenSize.height/3,
            child:Image.network(args.image,fit: BoxFit.cover,),
          )
          ,
          Container(
            width: screenSize.width,
            height: screenSize.height/3,
            child:SingleChildScrollView(
              child:Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(args.name,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  Container(
                    child:Row(
                      
                      children: [
                      ElevatedButton(onPressed: (){setState(() {
                        if(itemCount>1){
                          itemCount--;
                        }
                      });}, child: Icon(Icons.remove)),
                      SizedBox(width: 5,),
                      Text(itemCount.toString(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                      SizedBox(width: 5,),
                      ElevatedButton(onPressed: (){setState(() {
                        itemCount++;
                      });}, child: Icon(Icons.add)),
                      
                    ],)
                  )

                ],)
                ,Container(
                  child:Text(args.description,style: TextStyle(fontSize: 20),)
                ),
                
              ],)
            ),
          ),

        Container(
                  width: screenSize.width,
                  //height: screenSize.height/6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child:Padding(padding: EdgeInsets.all(10),child: Center(child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text((itemCount*args.price).toString()+" EGP",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                    ElevatedButton(onPressed: addedToCart? null: ()=>handleAddToCart(args,prefsService), child: Text("Add to Cart",style: TextStyle(fontSize: 25),)),
                    
                  ],))),
                )
                
        ],),)
      ),
     
      )
    ,bottomNavigationBar: BottomNavBar(index: 0,)
    );
  }
}