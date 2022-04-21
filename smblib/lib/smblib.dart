import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Smblib {
  static const MethodChannel _channel = MethodChannel('smblib');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> Login(
      String hostName, String loginName, String password) async {
    final String? res = await _channel.invokeMethod('Login', <String, dynamic>{
    'hostName': hostName,
      'userName': loginName,
      'password': password,
    });

    print("flutter Login res: $res");
    return res;
  }

  static Future<dynamic> UploadFile(String url, String localFilePath) async {
    final String? res = await _channel.invokeMethod('UploadFile',
        <String, dynamic>{'url': url, 'localFilePath': localFilePath});

    return res;
  }

  static Future<dynamic> AddFolder(String url) async {
    final String? res =
        await _channel.invokeMethod('Addfolder', <String, dynamic>{'url': url});

    return res;
  }

  static Future<List> GetFileList() async {
    List list = [];
    List folderList = [];
    var res = await _channel.invokeMethod('GetFileList');
    print("flutter getFiles res: $res");
    List<String> splitStr = res
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(" ", "")
        .split(",");
    splitStr.sort((a, b) => b.compareTo(a));
    if (res.isNotEmpty) {
      for (var dic in splitStr) {
        if (dic.contains("/")) {
          folderList.add(dic);
        } else {
          list.add(dic);
        }
      }
      // for(var f in folderList) {
      //   list.add(f);
      // }
      list.addAll(folderList);
    }
    return list;
  }

  static Future<List> GetFilePath(String path) async {
    print('call smb GetFilePath dart -> $path');
    List list = [];
    List folderList = [];
    var res = await _channel.invokeMethod('GetFilePath', <String, dynamic>{
      'path': path,
    });
    print("flutter getFilesPath res: $res");
    List<String> splitStr = res
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(" ", "")
        .split(",");
    splitStr.sort((a, b) => a.compareTo(b));
    if (res.isNotEmpty) {
      for (var dic in splitStr) {
        if (dic.contains("/")) {
          folderList.add(dic);
        } else {
          list.add(dic);
        }
      }
      list.addAll(folderList);
    }
    return list;
  }

  static Future<String> get demo async {
    final String res = await _channel.invokeMethod("demo");
    return res;
  }
}
