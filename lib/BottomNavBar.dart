import 'package:flutter/material.dart';
import 'package:food_deliver/SharedPreferencesService.dart';
import 'package:food_deliver/util.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  int index;
  BottomNavBar({required this.index});
  
  @override
  BottomNavBarState createState() => BottomNavBarState();
}
class BottomNavBarState extends State<BottomNavBar>{
  int totalItems = 0;
  int selectedIndex = 0;
  

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
    
  }
  @override
  Widget build(BuildContext context) {
    final prefsService = Provider.of<SharedPreferencesService>(context);
    setState(() {
      totalItems = totalCartItems(prefsService.getListData("cart")!);
    });

    return BottomNavigationBar(
        currentIndex: selectedIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: Colors.blue),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        onTap: (index) {
          if (index == 0) {
            setState(() {
              selectedIndex = 0;
            });
            Navigator.pushNamed(context, '/', arguments: 0);
          } else if (index == 1) {
            setState(() {
              selectedIndex = 1;
            });
            Navigator.pushNamed(context, '/cart', arguments: 1);
          } else if (index == 2) {
            setState(() {
              selectedIndex = 2;
            });
            Navigator.pushNamed(context, '/order',arguments: 2);
          }else if (index == 3) {
            setState(() {
              selectedIndex = 3;
            });
            Navigator.pushNamed(context, '/profile',arguments: 3);
          }
        },
        
        
        items: [
          BottomNavigationBarItem(
          
            icon: Icon(Icons.home),
            label: 'Home',
            
          ),
            BottomNavigationBarItem(
            icon: Stack(
              children: [
              Icon(Icons.shopping_cart),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  totalItems.toString(), // Replace with the actual number of items
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                ),
              ),
              ],
            ),
            label: 'Cart',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );
    
  }
}