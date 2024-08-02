import 'package:flutter/material.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username="";
  String password="";
  String address="";
  String phone="";
  bool loading=false;

  Future<void> handleRegister(SharedPreferencesService prefsService) async {
    setState(() {
      loading=true;
    });
    final response = await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/auth/register'),body: jsonEncode({
      'username': username,
      'password': password,
      'address': address,
      'phone': phone
    }),headers: {
      'Content-Type': 'application/json'
    });
    if(response.statusCode==200){
      final jsonData=json.decode(response.body);
      prefsService.updateStringData('token', jsonData['token']);
      prefsService.updateBoolData("login", true);
      String token=jsonData['token'];
      List<String>? tempCart=prefsService.getListData("cart");
      for(int i=0;i<tempCart!.length;i++){
        final Map<String,dynamic> cartItemData = json.decode(tempCart[i]);
        final response2 = await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/cart/addToCart'),body: {
          "productId":cartItemData['id'],
          "quantity":cartItemData['quantity'].toString(),
          "token":token,
          "price":cartItemData['price'].toString(),
          "image":cartItemData['image'],
          "name":cartItemData['name'],
        });
      }
      final cartFinal=await http.get(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/cart/userCart/$token'));
      final Map<String,dynamic> jsonDataFinal = json.decode(cartFinal.body);
      String userId=jsonDataFinal['userId'];
      List<dynamic> items=jsonDataFinal['items'];
      List<String> temp = [];
      for (int i = 0; i < items.length; i++) {
        String itemString=jsonEncode({"id":items[i]['_id'],"name":items[i]['name'],"price":double.parse(items[i]['price'].toString()),"image":items[i]['image'],"description":items[i]['description'],"quantity":items[i]['quantity'].toString()});
        temp.add(itemString);
      }
      prefsService.updateListData("cart", temp);
      Navigator.pushNamed(context, '/');

    }
    setState(() {
      loading=false;
    });

  }

  @override
  Widget build(BuildContext context) {
    final prefsService=Provider.of<SharedPreferencesService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(

          children: [
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => setState(() {
                username = value;
              }),
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => setState(() {
                password = value;
              }),
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => setState(() {
                address = value;
              }),
              decoration: InputDecoration(
                labelText: 'Address',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => setState(() {
                phone = value;
              }),
              decoration: InputDecoration(
                labelText: 'Phone',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width /3,
              child: ElevatedButton(
              onPressed: () {
                  handleRegister(prefsService);
                },
              child: Text('Register'),
            ),)
          ],
        ),
      ),
    );
  }
}