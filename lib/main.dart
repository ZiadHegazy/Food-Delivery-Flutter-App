import 'package:flutter/material.dart';
import 'package:food_deliver/Cart.dart';
import 'package:food_deliver/CartItem.dart';
import 'package:food_deliver/CategoryPage.dart';
import 'package:food_deliver/Home.dart';
import 'package:food_deliver/ItemPage.dart';
import 'package:food_deliver/Login.dart';
import 'package:food_deliver/OrderPage.dart';
import 'package:food_deliver/ProfilePage.dart';
import 'package:food_deliver/Register.dart';
import 'package:food_deliver/SearchResult.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:food_deliver/VoiceRecorder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void  main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  final sharedPreferencesService = SharedPreferencesService();
  
  

  
   runApp(
    ChangeNotifierProvider(
      create: (context) => sharedPreferencesService,
      child: MyApp(),
    ),
  );
  //runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  MyAppState createState() => MyAppState();
  
}

class MyAppState extends State<MyApp> {

  List<String> cart=[];
  @override
  void  initState()  {
    super.initState();
    loadPreferences();
    
    
  }

  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    bool login=prefs.getBool("login")??false;
    setState(() {
      cart = (prefs.getStringList('cart') ?? []);
      if(cart.length==0)
        prefs.setStringList("cart", []);
      if(login==false)
        prefs.setBool("login", false);
      

    });
  }

  @override
  Widget build(BuildContext context) {
    final prefsService=Provider.of<SharedPreferencesService>(context);

    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/search': (context) => Searchresult(),
        '/item': (context) => Itempage(),
        '/category': (context) => CategoryPage(),
        '/cart': (context) => Cart(),
        '/order': (context) => OrderPage(),
        '/profile':(context)=>ProfilePage(),
        '/login':(context)=>Login(),
        '/register':(context)=>Register(),
      },
    );
  }
}

