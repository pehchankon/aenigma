import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

class Keys {

  SharedPreferences? prefs;  

  List<Pair<String, String>> _list = [Pair('key', 'value')];


  Keys()
  {
    _getKeys();
  }

  void add(String key, String value) async{
    _list.add(Pair(key, value));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('keys',json.encode(_list));
  }

  List get() {
    return _list;
  }

  _getKeys() async {
    prefs = await SharedPreferences.getInstance();
     = (prefs.getString('keys') ?? 'null');
  }

  setActiveKey(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeKey', key);
  }
  incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String counter = (prefs.getString('activeKey') ?? 'null');
    print(counter);
    counter='ha';
    await prefs.setString('activeKey', counter);
  }
}
