// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:libdsm/libdsm.dart';
// import 'package:http/http.dart' as http;

// ///
// /// SMB網路資料夾
// /// Date: 2022-02-07
// class SMBPage extends StatefulWidget {
//   static const String sName = "/";
//   const SMBPage({Key? key}) : super(key: key);

//   @override
//   _SMBPageState createState() => _SMBPageState();
// }

// class _SMBPageState extends State<SMBPage> {
//   String _platformVersion = 'Unknown';

//   Dsm dsm = Dsm();

//   Future<void> _create() async {
//     dsm.init();
//   }

//   Future<void> _release() async {
//     dsm.release();
//   }

//   Future<void> _startDiscovery() async {
//     dsm.onDiscoveryChanged.listen(_discoveryListener);
//     dsm.startDiscovery();
//   }

//   void _discoveryListener(String json) async {
//     debugPrint('Discovery : $json');
//   }

//   Future<void> _stopDiscovery() async {
//     dsm.onDiscoveryChanged.listen(null);
//     dsm.stopDiscovery();
//   }

//   void _resolve() async {
//     String name = 'kamoguai';
//     await dsm.resolve(name);
//   }

//   void _inverse() async {
//     String address = '192.168.50.100';
//     await dsm.inverse(address);
//   }

//   void _login() async {
//     await dsm.login("KAMOGUAIDE-MBP", "kamoguai", "0000");
//   }

//   void _logout() async {
//     await dsm.logout();
//   }

//   void _getShareList() async {
//     var res = await dsm.getShareList();
//     print("_getShareList -> $res");
//   }

//   int tid = 0;

//   void _treeConnect() async {
//     tid = await dsm.treeConnect("Runner 2022-01-27 22-26-27");
//   }

//   void _treeDisconnect() async {
//     int result = await dsm.treeDisconnect(tid);
//     tid = 0;
//   }

//   void _find() async {
//     var result = await dsm.find(tid, "\\*");
//     print("_find -> $result");

//     // result = await dsm.find(tid, "\\shares\\*");
//   }

//   void _fileStatus() async {
//     String result = await dsm.fileStatus(tid, "\\shares\\1.txt");
//   }

//   void _fileUpload() async {
//     // var result = await dsm.fileRead(tid, "\\shares\\1.txt");
//     // FilePickerResult? _result =
//     //     await FilePicker.platform.pickFiles(type: FileType.image);
//     // if (_result != null) {
//     //   var postUrl =
//     //       Uri.parse("smb://192.168.50.90/Runner 2022-01-27 22-26-27/");
//     //   http.MultipartRequest request = http.MultipartRequest("POST", postUrl);
//     //   http.MultipartFile mFile =
//     //       await http.MultipartFile.fromPath('file', _result.files.single.path!);
//     //   request.files.add(mFile);
//     //   http.StreamedResponse response = await request.send();
//     //   print(response.statusCode);
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter LIBDSM'),
//         ),
//         body: Column(
//           // <Widget> is the type of items in the list.
//           children: <Widget>[
//             RaisedButton(
//               onPressed: _create,
//               child: Text('create'),
//             ),
//             RaisedButton(
//               onPressed: _release,
//               child: Text('release'),
//             ),
//             RaisedButton(
//               onPressed: _startDiscovery,
//               child: Text('startDiscovery'),
//             ),
//             RaisedButton(
//               onPressed: _stopDiscovery,
//               child: Text('stopDiscovery'),
//             ),
//             RaisedButton(
//               onPressed: _resolve,
//               child: Text('resolve'),
//             ),
//             RaisedButton(
//               onPressed: _inverse,
//               child: Text('inverse'),
//             ),
//             RaisedButton(
//               onPressed: _login,
//               child: Text('login'),
//             ),
//             RaisedButton(
//               onPressed: _logout,
//               child: Text('logout'),
//             ),
//             RaisedButton(
//               onPressed: _getShareList,
//               child: Text('getShareList'),
//             ),
//             RaisedButton(
//               onPressed: _treeConnect,
//               child: Text('treeConnect'),
//             ),
//             RaisedButton(
//               onPressed: _treeDisconnect,
//               child: Text('treeDisconnect'),
//             ),
//             RaisedButton(
//               onPressed: _find,
//               child: Text('find'),
//             ),
//             RaisedButton(
//               onPressed: _fileStatus,
//               child: Text('fileStatus'),
//             ),
//             RaisedButton(
//               onPressed: _fileUpload,
//               child: Text('fileUpload'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
