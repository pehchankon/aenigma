import 'package:flutter/material.dart';
import '../Database/keys.dart';

class KeyTile extends StatefulWidget {
  final Pair? listElement;
  final Keys? keysList;
  final String? activeKey;
  final Function? callback;
  const KeyTile(
      {Key? key,
      @required this.listElement,
      @required this.keysList,
      @required this.activeKey,
      @required this.callback,})
      : super(key: key);

  @override
  State<KeyTile> createState() => _KeyTileState();
}

class _KeyTileState extends State<KeyTile> {
  final TextStyle style = const TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          RadioListTile<dynamic>(
        title: Text(widget.listElement?.a),
        value: widget.listElement?.b,
        groupValue: widget.activeKey,
        onChanged: (value) async {
          await widget.keysList?.setActiveKey(widget.listElement?.b);
          widget.callback!(value);
        },
      ),
    );
  }
}
