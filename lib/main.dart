import 'package:flutter/material.dart';
import 'Pages/key_selection.page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static const platform = MethodChannel('testing/keys');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ini();
  }

  void _ini() async {
    try {
      final result = await MyApp.platform.invokeMethod('checkInputMethods');
    } on PlatformException catch (e) {
      print(e.message);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: isLoading ? Container() : KeySelectionPage(),
    );
  }
}
