import 'package:flutter/material.dart';
import 'package:food_deliver/ProductModel.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Searchresult extends StatefulWidget {
  @override
  SearchresultState createState() => SearchresultState();
}
class SearchresultState extends State<Searchresult>
{
  List<ProductModel> products=[];
  bool loading=false;
  int first=0;


  Future<void> fetchProducts(BuildContext context) async{
    final args = ModalRoute.of(context)!.settings.arguments as String;
    
    setState(() {
      loading=true;
    });
    final response = await http.get(Uri.parse('https://food-backend-purple-sun-8746.fly.dev/product/searchProducts/$args'));
    
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
                      products[i].price.toString()+"EGP",
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
      if(i<products.length-1){
        items.add(SizedBox(height: 15));
      }
    }
    return items;
  }
  
  @override
  Widget build(BuildContext context) {
    final screensize=MediaQuery.of(context).size;
    final prefsService=Provider.of<SharedPreferencesService>(context);
    final args = ModalRoute.of(context)!.settings.arguments as String;
    if(first==0){
      fetchProducts(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Result'),
      ),
      body: Center(
        child: Padding(padding: EdgeInsets.all(15),child: Container(
         // height: screensize.height/2,
          child: SingleChildScrollView(child:Column(children: [
          Text("Results for: "+args,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          loading?CircularProgressIndicator():products.length==0?Text("No items found",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),):Container(),
          //Text("No items found",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

          ...itemCards(screensize)
        ],) ,),)),
      ),
    );
  }
}