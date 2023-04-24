import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class KeyGenerationPage extends StatefulWidget {
  KeyGenerationPage(
      {super.key, required this.callback, this.isDoubleKeyGeneration = false});
  final Function callback;
  final remotePublicKeyController = TextEditingController();
  final keyNameKeyController = TextEditingController();
  final bool isDoubleKeyGeneration;

  @override
  State<KeyGenerationPage> createState() => _KeyGenerationPageState();
}

class _KeyGenerationPageState extends State<KeyGenerationPage> {
  KeyGenerator generator = KeyGenerator();
  // KeyGenerator bob = KeyGenerator();

  // late String bobPublicKey;
  late String publicKey;
  String? nameError;
  String? keyError;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final res = await generator.generateKeyPair();
    setState(() {
      publicKey = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Key'),
      ),
      body: isLoading
          ? Container(
              child: Text('generating keypair'),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 1: Assign a key name'),
                  TextField(
                    style: TextStyle(),
                    controller: widget.keyNameKeyController,
                    decoration: InputDecoration(hintText: 'Key Name'),
                  ),
                  if (nameError != null)
                    Column(children: [
                      SizedBox(height: 10),
                      Text(nameError!, style: TextStyle(color: Colors.red))
                    ]),
                  SizedBox(height: 30),
                  if (widget.isDoubleKeyGeneration)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Step 2: Your public key is given below. Please tap on it to copy and share it with the other party via a messaging app or email.'),
                        SizedBox(height: 10),
                        OutlinedButton(
                          child: Text(publicKey),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: publicKey));
                            // copied successfully
                          },
                        ),
                        SizedBox(height: 30),
                        Text('Step 3: Enter the other party\'s public key.'),
                        TextField(
                          controller: widget.remotePublicKeyController,
                          style: TextStyle(),
                          decoration: InputDecoration(hintText: 'Received Key'),
                        ),
                        if (keyError != null)
                          Column(children: [
                            SizedBox(height: 10),
                            Text(keyError!, style: TextStyle(color: Colors.red))
                          ]),
                        SizedBox(height: 30),
                      ],
                    ),
                  ElevatedButton(
                      onPressed: () async {
                        if (widget.keyNameKeyController.text == "") {
                          setState(() => nameError = "Name can't be empty.");
                          return;
                        }
                        if (widget.isDoubleKeyGeneration &&
                            widget.remotePublicKeyController == "") {
                          setState(() =>
                              keyError = "Remote public key can't be empty.");
                          return;
                        }
                        late final String secretKey;
                        try {
                          secretKey = widget.isDoubleKeyGeneration
                              ? await generator.generateDoubleSecretKey(
                                  widget.remotePublicKeyController.text)
                              : await generator.generateSingleSecretKey();
                        } catch (e) {
                          setState(() {
                            keyError = "Invalid key.";
                            nameError = "";
                          });
                          return;
                        }
                        final bool res = await widget.callback(
                            keyName: widget.keyNameKeyController.text,
                            keyValue: secretKey);
                        if (res)
                          Navigator.pop(context);
                        else
                          setState(() =>
                              nameError = "Key with this name already exists.");
                      },
                      child: Text('Save'))
                ],
              ),
            ),
    );
  }
}

class KeyGenerator {
  final algorithm = X25519();
  late SimpleKeyPair _keyPair;

  Future<String> generateKeyPair() async {
    _keyPair = await algorithm.newKeyPair();
    final bytes = (await _keyPair.extractPublicKey()).bytes;
    return base64.encode(bytes);
  }

  Future<String> generateDoubleSecretKey(String remotePublicKey) async {
    final bytes = base64.decode(remotePublicKey);
    final secretKey = await algorithm.sharedSecretKey(
        keyPair: _keyPair,
        remotePublicKey: SimplePublicKey(bytes, type: KeyPairType.x25519));
    final res = base64Encode(await secretKey.extractBytes());
    return res;
  }

  Future<String> generateSingleSecretKey() async {
    final res = base64Encode(await _keyPair.extractPrivateKeyBytes());
    return res;
  }
}
