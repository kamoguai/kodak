import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:smblib/smblib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _hostName = '192.168.50.100';
  String _userName = 'kamoguai';
  String _password = "0000";
  String _loginResult = "";
  List<dynamic> resFileList = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await Smblib.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _login() async {
    var loginRes =  await Smblib.Login(_hostName, _userName, _password);
    print('dart login -> $loginRes');
    setState(() {
      _loginResult = '$loginRes';

    });
  }
  void _upload(String url, String localFilePath) async {
    String loginRes =  await Smblib.UploadFile(url, localFilePath);
    setState(() {
      if (loginRes=="ok") {
        _loginResult = 'upload success';
      }
      else {
        _loginResult = 'upload fails';
      }
    });
  }
  Future<PlatformFile?> pickImageFromLibrary() async {
    FilePickerResult? _result =
    await FilePicker.platform.pickFiles(type: FileType.image);
    if (_result != null) {
      print('path => ${_result.files.single.path}');
      print('filename => ${_result.files.single.name}');
      // return _result.files[0]
      String sambaDir = "/shares";
      String filePathUpload = sambaDir + "/" + _result.files.single.name;
      String url = "smb://" + _hostName + filePathUpload;
      print("url -> $url");
      print("localPath -> "+ _result.files.single.path);
       _upload(url ,_result.files.single.path);
      return _result.files.single;
    }
    return null;
  }
  Future<dynamic> getFileList() async {
    List res = await Smblib.GetFileList();
    resFileList = res;
    print("res -> ${res.length}");
  }

  Future<dynamic> getFilePath(String path) async {
    print("dart param path -> $path");
    List res = await Smblib.GetFilePath(path);
    print("res -> ${res.length}");
  }

  Future<dynamic> addFolder(String dirName) async{
    String url = "smb://" + _hostName + dirName;
    var res = await Smblib.AddFolder(url);
    print("add folder -> $res");
  }

  void _demo() async {
    String res = await Smblib.demo;

    setState(() {
      _loginResult = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child:Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children:[
            Text('Running on: $_platformVersion\n'),
            Text('Running on: $_loginResult\n'),
            FloatingActionButton(
              child: Text("Login"),
                onPressed: (){
               _login();
            }),
            SizedBox(height: 10,),
            FloatingActionButton(
                child: Text("fili"),
                onPressed: (){
                  var res = getFileList();
                  // getFileList();
                  // _demo();
                }),
            FloatingActionButton(
                child: Text("path"),
                onPressed: (){
                  var res = getFilePath('shares/');
                  // getFilePath(resFileList[0]);
                  // _demo();
                }),
            FloatingActionButton(
                child: Text("add"),
                onPressed: (){
                  var res = pickImageFromLibrary();
                  // getFilePath(resFileList[0]);
                  // _demo();
                })
          ]
        )),
      ),
    );
  }
}
