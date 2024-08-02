import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService with ChangeNotifier {
  SharedPreferences? _prefs;
  


  SharedPreferencesService() {
    _loadPreferences();
  }


  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs?.setStringList("cart", []);
    _prefs?.setBool("login", false);
    
    notifyListeners();
  }

  Future<void> updateStringData(String key,String newData) async {
    await _prefs?.setString(key, newData);
    notifyListeners();
  }
  Future<void> updateBoolData(String key,bool newData) async {
    await _prefs?.setBool(key, newData);
    notifyListeners();
  }
  Future<void> updateListData(String key,List<String> newData) async {
    await _prefs?.setStringList(key, newData);
    notifyListeners();
  }
  String? getStringData(String key) {
    return _prefs?.getString(key);
  }
  bool? getBoolData(String key) {
    return _prefs?.getBool(key);
  }
  List<String>? getListData(String key) {
    return _prefs?.getStringList(key);
  }
}
