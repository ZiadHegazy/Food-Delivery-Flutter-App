import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';


int totalCartItems(List<String> cart){
  int total=0;
  for(int i=0;i<cart.length;i++){
    Map<String,dynamic> item = jsonDecode(cart[i]);
    total+=int.parse(item["quantity"].toString());

  }
  return total;
}
double totalCartPrice(List<String> cart){
  double total=0;
  for(int i=0;i<cart.length;i++){
    Map<String,dynamic> item = jsonDecode(cart[i]);
    total+=double.parse(item["price"].toString())*int.parse(item["quantity"].toString());

  }
  return total;
}


Future<String> getImageUrl(String imagePath) async {
  final ref = FirebaseStorage.instance.ref().child(imagePath);
  String imageUrl = await ref.getDownloadURL();
  return imageUrl;
}