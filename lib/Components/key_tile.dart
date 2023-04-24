import 'package:flutter/material.dart';

class KeyTile extends StatefulWidget {
  final String alias;
  final String secretKey;
  // final Keys? keysList;
  // final String? activeKey;
  final Function callbackAdd;
  final Function callbackDelete;

  const KeyTile(
      {Key? key,
      required this.alias,
      required this.secretKey,
      // required this.keysList,
      // required this.activeKey,
      required this.callbackAdd,
      required this.callbackDelete})
      : super(key: key);

  @override
  State<KeyTile> createState() => _KeyTileState();
}

class _KeyTileState extends State<KeyTile> {
  final TextStyle style = const TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Text(widget.alias),
      onPressed: () => widget.callbackAdd(widget.secretKey, widget.alias),
      onLongPress: () => widget.callbackDelete(widget.alias,context),
    );
  }
}
