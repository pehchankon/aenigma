import 'package:flutter/material.dart';
import '../Database/keys.dart';

class KeyTile extends StatelessWidget {
  final TextStyle style = const TextStyle(fontSize: 20);
  final Pair? listElement;

  const KeyTile({Key? key, @required this.listElement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(listElement?.a, style: style),
            Text(listElement?.b, style: style),
          ],
        ));
  }
}
