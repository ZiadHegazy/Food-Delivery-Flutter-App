import 'package:flutter/material.dart';
import 'package:food_deliver/BottomNavBar.dart';
import 'package:food_deliver/OrderModel.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:food_deliver/util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Cart extends StatefulWidget {
  @override
  CartState createState() => CartState();
}
class CartState extends State<Cart>{
  List<String> cart=[];
  int first=0;
  String address="";
  bool orderPlaced=false;
  bool loading=false;


  @override
  void initState() {
    super.initState();
  }
  void handleUpdateItemCount(Map<String,dynamic> item,int count,SharedPreferencesService prefs) async {
    String? token=prefs.getStringData("token");
    bool? login=prefs.getBoolData("login");
    if(login==true && token!=null){
      final response=await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/cart/updateItemQuantity'),body: {"token":token,"productId":item['id'],"quantity":count.toString()});
      if(response.statusCode==200){
        List<String> newCart=[];
        for(int i=0;i<cart.length;i++){
          Map<String,dynamic> cartItemData = json.decode(cart[i]);
          if(cartItemData['id']==item['id']){
            cartItemData['quantity']=count.toString();
            newCart.add(jsonEncode(cartItemData));
          }else{
            newCart.add(cart[i]);
          }
        }
        setState(() {
          cart=newCart;
          prefs.updateListData("cart", newCart);
        });
      }
    }else{
      List<String> newCart=[];
      for(int i=0;i<cart.length;i++){
        Map<String,dynamic> cartItemData = json.decode(cart[i]);
        if(cartItemData['id']==item['id']){
          cartItemData['quantity']=count.toString();
          newCart.add(jsonEncode(cartItemData));
        }else{
          newCart.add(cart[i]);
        }
      }
      setState(() {
        cart=newCart;
        prefs.updateListData("cart", newCart);
      });
    }
  }
  
  void handleDeleteItem(Map<String,dynamic> item,SharedPreferencesService prefs) async {
    String? token=prefs.getStringData("token");
    bool? login=prefs.getBoolData("login");
    if(login==true && token!=null){
      final response=await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/cart/removeFromCart'),body: {"token":token,"productId":item['id']});
      if(response.statusCode==200){
        List<String> newCart=[];
        for(int i=0;i<cart.length;i++){
          Map<String,dynamic> cartItemData = json.decode(cart[i]);
          if(cartItemData['id']!=item['id']){
            newCart.add(cart[i]);
          }
        }
        setState(() {
          cart=newCart;
          prefs.updateListData("cart", newCart);
        });
      }
    }else{
      List<String> newCart=[];
      for(int i=0;i<cart.length;i++){
        Map<String,dynamic> cartItemData = json.decode(cart[i]);
        if(cartItemData['id']!=item['id']){
          newCart.add(cart[i]);
        }
      }
      setState(() {
        cart=newCart;
        prefs.updateListData("cart", newCart);
      });
    }
  }
  void placeOrder(SharedPreferencesService prefs,BuildContext context) async {
    String? token=prefs.getStringData("token");
    List<dynamic> items=[];
    for(int i=0;i<cart.length;i++){
      Map<String,dynamic> cartItemData = json.decode(cart[i]);
      // OrderItem tempItem=OrderItem(productId:cartItemData['id'],quantity:int.parse(cartItemData['quantity'].toString()),price:double.parse(cartItemData['price'].toString()),image:cartItemData['image']);
      items.add({"productId":cartItemData['id'],"quantity":int.parse(cartItemData['quantity'].toString()),"price":double.parse(cartItemData['price'].toString()),"image":cartItemData['image']});
    }
    double total=totalCartPrice(cart);
    final response=await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/order/placeOrder'),body: jsonEncode({"token":token,"items":items,"total":total,"address":address}),headers: {"Content-Type": "application/json"});
    setState(() {
      orderPlaced=true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Your order is placed successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pushNamed(context, "/order");
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> fetchCartData(SharedPreferencesService prefs) async{
    String? token=prefs.getStringData("token");
    bool? login=prefs.getBoolData("login");
    if(login==true && token!=null){
      setState(() {
        loading=true;
      });
      final response = await http.get(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/cart/userCart/$token'));
      if (response.statusCode == 200) {
        final Map<String,dynamic> jsonData = json.decode(response.body);
        String userId=jsonData['userId'];
        List<dynamic> items=jsonData['items'];

        List<String> temp = [];
        for (int i = 0; i < items.length; i++) {
          String itemString=jsonEncode({"id":items[i]['productId'],"name":items[i]['name'],"price":double.parse(items[i]['price'].toString()),"image":items[i]['image'],"quantity":items[i]['quantity']});
          temp.add(itemString);
        }
        setState(() {
          cart=temp;
          prefs.updateListData("cart", temp);
          first=1;
          loading=false;
        });
      } else {
        print('Failed to load data!');
      }
    }else{
      
      setState(() {
        cart=prefs.getListData("cart")??[];
        first=1;
        loading=false;
      });
    }
  }
  List<Widget> cartCards(SharedPreferencesService prefs){
    List<Widget> items=[];
    for(int i=0;i<cart.length;i++){
      Map<String,dynamic> cartItemData = json.decode(cart[i]);
      items.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 0.2*MediaQuery.of(context).size.width,
                child: Image.network(cartItemData['image']),
              ),
              Container(
                width: 0.28*MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cartItemData['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    Text(
                      cartItemData['price'].toString()+"EGP",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                
                child: Column(children: [
                  IconButton(onPressed: ()=>handleDeleteItem(cartItemData,prefs), icon: Icon(Icons.delete),color: Colors.red,),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () => handleUpdateItemCount(cartItemData,int.parse(cartItemData['quantity'].toString())-1,prefs),
                    ),
                    Text(
                      cartItemData['quantity'].toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => handleUpdateItemCount(cartItemData,int.parse(cartItemData['quantity'].toString())+1,prefs),
                    ),
                  ],
                )
                ],),
              ),
            ],
          ),
        ),
      );
      if(i<cart.length-1){
        items.add(SizedBox(height: 15));
      }
    }
    return items;

  }
  @override
  Widget build(BuildContext context) {
    final prefsService = Provider.of<SharedPreferencesService>(context);
    if(first==0){
      fetchCartData(prefsService);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child:loading? Center(child: CircularProgressIndicator(),): cart.length==0? Center(child: Text("No Items In Cart Yet",style: TextStyle(fontSize: 25),),):Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: MediaQuery.of(context).size.height*0.4,
                child:ListView(
                
                children: cartCards(prefsService),
              )),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.3,
              decoration: BoxDecoration(
                color: const Color.fromARGB(249, 240, 240, 240),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalCartPrice(cart).toString()+"EGP",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              onChanged: (value) => setState(() {address = value;}),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Enter Your Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed:orderPlaced? null: () => placeOrder(prefsService,context),
                child: Text("Checkout"),
              ),
            )
              ],)
              
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(index:1),
    );
  }
  List<Widget> itemCards(screensize){
    List<Widget> items=[];
    for(int i=0;i<10;i++){
      items.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: screensize.width,
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 0.2*screensize.width,
                child: Image.network("https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_960_720.jpg"),
              ),
              Container(
                width: 0.6*screensize.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Burger",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "20EGP",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      if(i<6-1){
        items.add(SizedBox(height: 15));
      }
    }
    return items;
  }
}