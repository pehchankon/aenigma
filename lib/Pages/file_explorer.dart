import 'dart:io';
import 'package:encrypto/presentation/app_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'select_keys.dart';
import '../Components/rounded_button.dart';

class FileExplorer extends StatefulWidget {
  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  bool _isGranted = true;
  final myController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _fileName = "File Not Selected";
  PlatformFile? _fileInfo;
  File? superFile;
  final int fileLimitation = 2000000000;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.size < fileLimitation) {
        setState(() {
          _fileName = file.name;
          _fileInfo = file;
        });
      } else {
        setState(() {
          _fileName = "File Size Exceeded 2 GB";
          _fileInfo = null;
        });
      }
      print(file.name);
    } else {}
  }

  Future<Directory> get getExternalVisibleDir async {
    // if (await Directory('/storage/emulated/0/Documents').exists()) {
    //   final externalDir = Directory('/storage/emulated/0/Documents');
    //   return externalDir;
    // } else {
    //   await new Directory('/storage/emulated/0/Documents')
    //       .create(recursive: true);
    //   final externalDir = Directory('/storage/emulated/0/Documents');
    //   return externalDir;
    // }

    final folderName = "Encrypto";
    final path = Directory("/storage/emulated/0/" + folderName);
    if ((await path.exists())) {
    } else {
      print('doesnt exist');
    }
    await Directory(path.path + '/Encrypted').create(recursive: true);
    await Directory(path.path + '/Decrypted').create(recursive: true);
    return path;
  }

  requestStoragePermission() async {
    if (!await Permission.manageExternalStorage.isGranted) {
      PermissionStatus result =
          await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        setState(() {
          _isGranted = true;
        });
      } else {
        setState(() {
          _isGranted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    requestStoragePermission();

    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 242, 234, 223),
      appBar: AppBar(
        title: Text('Encrypt0'),
        // backgroundColor: Colors.grey[850],
        // backgroundColor: Color.fromARGB(255, 199, 191, 179),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                      image: AssetImage('assets/iconmonstr-shield-27-240.png'),
                      fit: BoxFit.cover)),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: const Text('Keys selection'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SelectKeys()));
              },
            ),
            ListTile(
                title: const Text('File encryption'),
                onTap: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
      body: Center(
        child: Container(
          // padding: EdgeInsets.all(16.0),
          height: 550.0,
          width: 400.0,

          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,

            // FileName
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: Text(
                    _fileName,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),

                // Password Field
                Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: myController,
                    style: TextStyle(color: Colors.black),
                    obscureText: true,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        labelText: 'Password',
                        labelStyle:
                            TextStyle(fontSize: 20.0, color: Colors.black)),
                    keyboardType: TextInputType.text,
                  ),
                ),

                // Encrypt Button
                Container(
                  margin: EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: ElevatedButton(
                      key: Key('encrypt'),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child:
                            Text('Encrypt', style: TextStyle(fontSize: 28.0)),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ))),
                      onPressed: () async {
                        if (_isGranted) {
                          Directory d = await getExternalVisibleDir;
                          print(d);
                          if (_formKey.currentState!.validate() &&
                              _fileInfo?.extension != null) {
                            var crypt = AesCrypt();
                            crypt.setPassword(myController.text);
                            crypt.setOverwriteMode(AesCryptOwMode.on);
                            crypt.encryptFileSync(_fileInfo?.path ?? 'null',
                                '${d.path}/Encrypted/$_fileName.aes');
                            print("file encrypted successfully");
                          } else {
                            print("file encryption unsuccessful");
                          }
                        } else {
                          print("Permission not granted");
                        }
                      }),
                ),

                //Decrypt Button
                Container(
                  child: ElevatedButton(
                      key: Key('decrypt'),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child:
                            Text('Decrypt', style: TextStyle(fontSize: 28.0)),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ))),
                      onPressed: () async {
                        if (_isGranted) {
                          Directory d = await getExternalVisibleDir;
                          var crypt = AesCrypt();
                          crypt.setPassword(myController.text);
                          crypt.setOverwriteMode(AesCryptOwMode.on);
                          // crypt.decryptFileSync(_fileInfo?.path ?? 'null',
                          // '${d.path}/Decrypted/');
                          crypt.decryptFileSync(
                              '${d.path}/Encrypted/$_fileName',
                              '${d.path}/Decrypted/${_fileName.substring(0, _fileName.length - 4)}');
                          print("file decrypted successfully");
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),

      // floatingActionButton
      floatingActionButton: FloatingActionButton.extended(
        // Moved FloatingActionButton to bottom right
        onPressed: () => _openFileExplorer(),
        label: const Text('Select File'), // Added Custom Text
        icon: const Icon(Icons.add), // Added Custom Icon
      ),
    );
  }
}
