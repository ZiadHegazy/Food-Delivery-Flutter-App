import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_deliver/BottomNavBar.dart';
import 'package:food_deliver/CategoryModel.dart';
import 'package:food_deliver/util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}
class HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  String search="";
  bool loading=false;
  List<String> cart=[];

  
  @override
  void initState() {
    super.initState();
    categories = [];
    fetchData();
    loadPreferences();
  }

  // Future<void> uploadToFirebase() async {
    
  //   File file = File("assets/burger.png");
  //   try {
  //     FirebaseStorage storage = FirebaseStorage.instance;
  //     Reference ref = storage.ref().child('./${file.uri.pathSegments.last}');
  //     await ref.putFile(file);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('File uploaded to Firebase Storage')),
  //     );
  //   } catch (e) {
  //     print('Error uploading file: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error uploading file')),
  //     );
  //   }
  // }

  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cart = (prefs.getStringList('cart') ?? []);
      
      

    });
    
  }
    
  Future<void> fetchData() async {
    setState(() {
      loading=true;
    });
    final response = await http.get(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/category/allCategories'));
    
    setState(() {
      loading=false;
    });
    if (response.statusCode == 200) {
      //final List<Object> jsonData = json.decode(response.body);
      final List<dynamic> jsonData = json.decode(response.body);
      List<CategoryModel> temp = [];
      for (int i = 0; i < jsonData.length; i++) {
        List<dynamic> dynamicProducts=  jsonData[i]['productList'];
        List<String> products = [];
        for(int j=0;j<dynamicProducts.length;j++){
          products.add(dynamicProducts[j].toString());
        }
        CategoryModel category = new CategoryModel(id: jsonData[i]['_id'], name: jsonData[i]['name'], products:products);
        temp.add(category);
      }
      setState(() {
        
        categories=temp;
      });
    } else {
      print('Failed to load data!');
    }
  }
   List getCategories(){
    List<Widget> categories2 = [];
    for(int i=0;i<categories.length;i++){
      categories2.add(ElevatedButton(onPressed: (){Navigator.pushNamed(context, "/category",arguments:categories[i]) ;},
      child: Text(categories[i].name)));
      if(i<categories.length-1){
        categories2.add(SizedBox(width: 10));
      }
    }
    return categories2;
  }
  void submitSearch(String search){
    if(search.isNotEmpty){
      Navigator.pushNamed(context, "/search",arguments: search);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      
      appBar: AppBar(
        title: Text('Home'),
      ),
      //backgroundColor: const Color.fromARGB(255, 193, 191, 191),
      body: Padding( padding: EdgeInsets.all(10),
      child:Center(
        child: Center(
          child: Column(
            children: [
              Container(width:MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height/3,
              child:Image.asset("assets/home.jpg") ,),
              TextField(
              onSubmitted: (value) => submitSearch(value),
              style: TextStyle(color: Colors.black,backgroundColor: Colors.white),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: IconButton(icon:Icon(Icons.search,color: Colors.black),onPressed: (){submitSearch(search);}),
                hintText: 'Enter Category or food',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
              Expanded(
                //mainAxisDirection: Axis.horizontal,
                flex: 1,
                child:  Column(
                  
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Categories", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                   SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: loading? MainAxisAlignment.center:MainAxisAlignment.spaceEvenly,
                    
                    children: loading? [Container(width: MediaQuery.of(context).size.width,child: Center(child: CircularProgressIndicator(),),)]:getCategories() as List<Widget>,
                  )
                   )
                  ],),
                ),
                  
                
  
                ]),
            
            ),
      ),
       ),
      bottomNavigationBar: BottomNavBar(index:0),
    );
  }
}