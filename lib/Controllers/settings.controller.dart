import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SettingsController {
  SharedPreferences? _prefs;
  late bool _bufferInput;
  late bool _timer;
  int? _timerValue;
  static const platform = MethodChannel('testing/keys');
  static final SettingsController _instance = SettingsController._internal();
  factory SettingsController() => _instance;

  SettingsController._internal();

  void setBuffer(bool isEnabled) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs?.setBool('bufferInput', isEnabled);
  }

  void setTimer(bool isEnabled, {int value = 0}) async {
    try {
      final result = await platform
          .invokeMethod('setTimer', {"timer": value, "enabled": isEnabled});
      print('hhfgh');
      print(result);
    } on PlatformException catch (e) {
      print(e.message);
    }

    _prefs = await SharedPreferences.getInstance();
    await _prefs?.setBool('timer', isEnabled);
    await _prefs?.setInt('timerValue', value);
  }

  bool get bufferInput => _bufferInput;
  bool get timer => _timer;
  int? get timerValue => _timerValue;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final res = _prefs?.getBool('bufferInput') ?? false;
    _timer = _prefs?.getBool('timer') ?? false;
    _timerValue = _prefs?.getInt('timerValue');
    _bufferInput = res;
  }

  clean() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs?.clear();
  }
}
