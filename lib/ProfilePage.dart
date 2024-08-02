import 'package:flutter/material.dart';
import 'package:food_deliver/BottomNavBar.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:food_deliver/util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}
class ProfilePageState extends State<ProfilePage>{
  List<String> cart=[];


  
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final prefsService=Provider.of<SharedPreferencesService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(child:prefsService?.getBoolData("login")==false? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("You are not logged in",style: TextStyle(fontSize: 20),),
        Container(
          width: MediaQuery.of(context).size.width/3,
          child: ElevatedButton(onPressed: (){
          Navigator.pushNamed(context, '/login');
        }, child: Text("Login")),),
       Container(
          width: MediaQuery.of(context).size.width/3,
        child:  ElevatedButton(onPressed: (){
          Navigator.pushNamed(context, '/register');
        }, child: Text("Register")),),
      ],):Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("Hello",style: TextStyle(fontSize: 20) ,),
        Container(
          width: MediaQuery.of(context).size.width/2,
          child: ElevatedButton(onPressed: (){
          Navigator.pushNamed(context, '/order');
        }, child: Text("See Your Orders")),),

      ],))
      ,bottomNavigationBar: BottomNavBar(index: 3,),
    );
  }
}