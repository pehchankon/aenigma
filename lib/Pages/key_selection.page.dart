import 'package:aenigma/Pages/key_generation.page.dart';
import 'package:flutter/material.dart';
import '../Components/key_tile.dart';
import '../Controllers/crypto_keys.controller.dart';
import 'package:flutter/services.dart';
import '../Controllers/settings.controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'settings.page.dart';

class KeySelectionPage extends StatefulWidget {
  const KeySelectionPage({
    Key? key,
  }) : super(key: key);

  @override
  State<KeySelectionPage> createState() => _KeySelectionPageState();
}

class _KeySelectionPageState extends State<KeySelectionPage> {
  static const platform = MethodChannel('testing/keys');
  late SettingsController settings = SettingsController();
  late CryptoKeys cryptoKeys;
  String? activeKey;
  List<Widget> keysList = [];

  @override
  void initState() {
    super.initState();
    cryptoKeys = CryptoKeys();
    _ini();
  }

  void _ini() async {
    await settings.init();
    await cryptoKeys.init();
    setState(() {});
  }

  void updateActiveKey(String key, String alias) async {
    try {
      final result = await platform
          .invokeMethod('setKey', {"password": key, "alias": alias});
      print(key);
      Fluttertoast.showToast(
        msg: "set active key alias: $alias",
        toastLength: Toast.LENGTH_SHORT,
      );
      // print('set key to $result');
    } on PlatformException catch (e) {
      print(e.message);
    }
    setState(() => activeKey = key);
  }

  void showAlertDialog(String key, BuildContext context) {
    Widget cancelButton = OutlinedButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = OutlinedButton(
      child: Text("Yes"),
      onPressed: () {
        deleteKey(key);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Key"),
      content: Text("Would you like to delete the key \"$key\"?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteKey(String key) async {
    await cryptoKeys.delete(key);

    setState(() {});
  }

  Future<bool> addKey(
      {required String keyName, required String keyValue}) async {
    // keys?.add(keyName!, keyValue!);
    final res = await cryptoKeys.add(keyName, keyValue);
    if (res) setState(() => Navigator.pop(context));
    return res;
    // keys?.clean();
  }

  void toggleInputBuffer(bool val) async {
    try {
      final result = await platform.invokeMethod('setBuffer', {"set": val});

      print('set buffer to $val');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    keysList = [];
    for (var e in cryptoKeys.cryptoKeyList.entries) {
      keysList.add(KeyTile(
          alias: e.key,
          secretKey: e.value,
          callbackAdd: updateActiveKey,
          callbackDelete: showAlertDialog));
    }

    String? keyName, keyValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aenigma'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<bool>(
                      builder: (BuildContext context) => SettingsPage())),
              icon: Icon(Icons.settings, color: Colors.white))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a key: '),
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: keysList),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 100,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<bool>(
                            builder: (BuildContext context) =>
                                KeyGenerationPage(callback: addKey))),
                    icon: Column(
                      children: [
                        Expanded(
                            child: Image.asset('assets/single.png',
                                fit: BoxFit.fitHeight)),
                        SizedBox(height: 10),
                        Text('Personal'),
                      ],
                    ),
                  ),
                  IconButton(
                    iconSize: 100,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (BuildContext context) => KeyGenerationPage(
                              callback: addKey, isDoubleKeyGeneration: true),
                        )),
                    icon: Column(
                      children: [
                        Expanded(child: Image.asset('assets/double.png')),
                        SizedBox(height: 10),
                        Text('Exchange'),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
        icon: Icon(Icons.add),
        label: Text('Add New key'),
      ),
    );
  }
}
