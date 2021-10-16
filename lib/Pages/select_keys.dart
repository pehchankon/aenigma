import 'package:flutter/material.dart';
import '../Database/keys.dart';
import '../Model/key_tile.dart';
import '../Components/input_field.dart';
import '../Components/rounded_button.dart';

class SelectKeys extends StatefulWidget {
  const SelectKeys({
    Key? key,
  }) : super(key: key);

  @override
  State<SelectKeys> createState() => _SelectKeysState();
}

class _SelectKeysState extends State<SelectKeys> {
  Keys keys = Keys();
  List<Widget>? keysList;

  @override
  Widget build(BuildContext context) {
    keysList = keys.get().map((key) => KeyTile(listElement: key)).toList();
    String? keyName, keyValue;

    return Scaffold(
      appBar: AppBar(title: const Text('Encrypt0')),
      body: ListView(
        children: keysList!,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    RoundedInputField(
                      hintText: 'Key Alias',
                      onChanged: (value) => keyName = value,
                    ),
                    RoundedInputField(
                      hintText: 'Secret Key',
                      onChanged: (value) => keyValue = value,
                    ),
                    RoundedButton(
                      text: 'Add Key',
                      press: () {
                          setState(() => keys.add(keyName!, keyValue!)); print('helo');},
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
