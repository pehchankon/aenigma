import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import 'dart:convert';

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

class Keys {
  SharedPreferences? prefs;

  List<Pair<String, String>> _list = [Pair('KeyName', 'SecretValue')];
  LinkedHashMap<String,dynamic> _hash = LinkedHashMap.of({"KeyName":"SecretValue"});


  void add(String key, String value) async {
    // _list.add(Pair(key, value));
    _hash.addAll({key:value});
    prefs = await SharedPreferences.getInstance();
    prefs?.setString('keys_test6', json.encode(_hash));
  }

  LinkedHashMap get() {
    // return _list;
    return _hash;
  }

  getKeys() async {
    prefs = await SharedPreferences.getInstance();
    String temp = (prefs?.getString('keys_test6') ?? 'null');
    if (temp != 'null') {
      _hash = json.decode(temp);
    }
    else {
      await prefs?.setString('keys_test6', json.encode(_hash));
      await prefs?.setString('activeKey', 'SecretValue');
    }
    print(_hash);

  }

  setActiveKey(String key) async {
    prefs = await SharedPreferences.getInstance();
    await prefs?.setString('activeKey', key);
  }

  Future<String?> getActiveKey() async {
    prefs = await SharedPreferences.getInstance();
    return prefs?.getString('activeKey');
  }
  clean() async{
    prefs = await SharedPreferences.getInstance();
    await prefs?.clear();

  }
}
