import 'package:flutter/material.dart';
import 'package:food_deliver/BottomNavBar.dart';
import 'package:food_deliver/CartItem.dart';
import 'package:food_deliver/CategoryModel.dart';
import 'package:food_deliver/ProductModel.dart';
import 'package:food_deliver/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class CategoryPage extends StatefulWidget {
  @override
  CategoryPageState createState() => CategoryPageState();
}
class CategoryPageState extends State<CategoryPage>
{
  String search="";
  List<ProductModel> products=[];
  bool loading=false;
  int first=0;
  List<String> cart=[];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPreferences();
    //fetchProducts(context);
    
  }
  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cart = (prefs.getStringList('cart') ?? []);
    });
  }
  
  Future<void> fetchProducts(BuildContext context) async{
    final args = ModalRoute.of(context)!.settings.arguments as CategoryModel;
    String id = args.id;
    setState(() {
      loading=true;
    });
    final response = await http.get(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/category/getCategoryProducts/$id'));
    
    setState(() {
      loading=false;
      first=1;
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      List<ProductModel> temp = [];
      for (int i = 0; i < jsonData.length; i++) {
        ProductModel product = new ProductModel(id: jsonData[i]['_id'], name: jsonData[i]['name'], price:double.parse(jsonData[i]['price'].toString()), image:jsonData[i]['image'],description:jsonData[i]['description']);
        temp.add(product);
      }
      setState(() {
        products=temp;
      });
    } else {
      print('Failed to load data!');
    }
    // Fetch products from the server
  }
  void submitSearch(String search){
    if(search.isNotEmpty){
      Navigator.pushNamed(context, "/search",arguments:search);
    }
  }
  List<Widget> itemCards(screensize){
    List<Widget> items=[];
    for(int i=0;i<products.length;i++){
      items.add(GestureDetector(
        onTap: () => Navigator.pushNamed(context, "/item",arguments:products[i]),
        child:Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: screensize.width, // Full width of the screen
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 0.2*screensize.width, // 20% width of the parent container
                child: Image.network(products[i].image),
              ),
              Container(
                width: 0.6*screensize.width, // 60% width of the parent container
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      products[i].name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      (products[i].price).toString()+"EGP",
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
      )
      

      );
      if(i<6-1){
        items.add(SizedBox(height: 15));
      }
    }
    if(items.length==0 ){
      items.add(Text("No Products found"));
    }
    return items;
  }
  
  @override
  Widget build(BuildContext context)  {
    final args = ModalRoute.of(context)!.settings.arguments as CategoryModel;
    if(first==0){
      fetchProducts(context);
    }
   
    final screensize=MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(args.name),
      ),
      body: Center(
        child: Padding(padding: EdgeInsets.all(10),child: Center(child: Column(
          children: [
          TextField(
              onSubmitted: (value) => submitSearch(value),
              style: TextStyle(color: Colors.black,backgroundColor: Colors.white),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: IconButton(icon:Icon(Icons.search,color: Colors.black),onPressed: (){submitSearch(search);}),
                hintText: 'Enter food',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
            SizedBox(height: 15),
            Container(
              width: screensize.width,
              height: screensize.height/2,
              child:SingleChildScrollView(child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:loading?[CircularProgressIndicator()] :itemCards(screensize)
                  
                ,),)

            )

        ],),),
      ),
    )
    ,bottomNavigationBar: BottomNavBar(index:0),
    );
  }
}