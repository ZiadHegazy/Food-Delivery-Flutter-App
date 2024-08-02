import 'package:flutter/material.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}
class LoginState extends State<Login>{
  String username="";
  String password="";
  bool loading=false;
  bool error=false;

  @override
  void initState() {
    super.initState();
    username="";
    password="";
    error=false;
  }
  @override
  Widget build(BuildContext context) {
    final prefsService=Provider.of<SharedPreferencesService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loading ? CircularProgressIndicator() : SizedBox(),
          error ? Text("Wrong Username or Password",style: TextStyle(color: Colors.red,fontSize: 15),) : SizedBox(),
          TextField(
            onChanged: (value) => setState(() {
              username = value;
            }),
            decoration: InputDecoration(
              hintText: 'Email',
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          SizedBox(height: 15),
          TextField(
            onChanged: (value) => setState(() {
              password = value;
            }),
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
              fillColor: Colors.white,
              filled: true,
              
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: MediaQuery.of(context).size.width/3,
            child:ElevatedButton(onPressed: () async {
            setState(() {
              loading=true;
            });
            final response = await http.post(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/auth/login'),body: {
              "username":username,
              "password":password
            }); 
            
            if(response.statusCode==200){
              prefsService.updateBoolData("login", true);
              final Map<String, dynamic> jsonData = json.decode(response.body);
              String token=jsonData['token'];
              prefsService.updateStringData("token", jsonData['token']);
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
            }else{
              setState(() {
                error=true;
              });
            }
            setState(() {
              loading=false;
            });

          }, child: Text('Login')),
         ),
          SizedBox(height: 15),
          Container(
            width: MediaQuery.of(context).size.width/3,
            child: ElevatedButton(onPressed: (){
            Navigator.pushNamed(context, '/register');
          }, child: Text('Register')
          ),),

        ],
      ),
    );
  }
}
