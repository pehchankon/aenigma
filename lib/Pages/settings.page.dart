import 'dart:ffi';

import 'package:flutter/material.dart';
import '../Controllers/settings.controller.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});
  late SettingsController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool buffer = false;
  bool timer = false;
  bool isLoading = true;
  bool error = false;
  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller = SettingsController();
    _init();
  }

  void _init() async {
    await widget.controller.init();
    setState(() {
      buffer = widget.controller.bufferInput;
      timer = widget.controller.timer;
      if (widget.controller.timerValue != null) {
        txtController.text = widget.controller.timerValue.toString();
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Text Buffer: '),
                      Switch(
                          value: buffer,
                          onChanged: (value) {
                            widget.controller.setBuffer(value);
                            setState(() => buffer = value);
                          }),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Auto-deselect active key:'),
                      Switch(
                          value: timer,
                          onChanged: (isEnabled) {
                            final res = int.tryParse(txtController.text);
                            if (res == null) {
                              setState(() => error = true);
                              return;
                            }
                            setState(() => error = false);
                            widget.controller.setTimer(isEnabled, value: res);
                            setState(() => timer = isEnabled);
                          }),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            maxLength: 4,
                            enabled: !timer,
                            keyboardType: TextInputType.number,
                            controller: txtController,
                            decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Time in s',
                                constraints: BoxConstraints(maxWidth: 80)),
                          ),
                          error
                              ? Text('enter time in seconds',
                                  style: TextStyle(color: Colors.red))
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
