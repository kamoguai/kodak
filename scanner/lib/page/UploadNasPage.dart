import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/UserInfoDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/model/UserInfo.dart';
import 'package:scanner/common/redux/SysState.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/CommonUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/dialog/NasAddFolderDialog.dart';
import 'package:scanner/common/widget/dialog/PdfDialog.dart';
import 'package:smblib/smblib.dart';
import 'package:scanner/common/utils/AesUtils.dart';

///
///上傳雲端頁面
///Date: 2022-01-17
///
class UploadNasPage extends StatefulWidget {
  final String? token;
  final List<String>? imagePathList;
  final bool? isCanUpload;
  const UploadNasPage(
      {Key? key, this.token, this.imagePathList, this.isCanUpload})
      : super(key: key);

  @override
  _UploadNasPageState createState() => _UploadNasPageState();
}

class _UploadNasPageState extends State<UploadNasPage> with BaseWidget {
  RowModel rModel = RowModel();
  List<RowModel> listModel = [];

  /// 裝載userinfo
  late UserInfo userInfo;

  ///紀錄所選單位
  String _pickPath = '';
  String _fullPostPath = "smb://";
  String _currentPath = "";
  String _parentPath = "";

  Future<dynamic> getFileList() async {
    var res = await Smblib.GetFileList();
    setState(() {
      for (String dic in res) {
        if (dic.contains("/")) {
          rModel.filetype = "folder";
        } else {
          rModel.filetype = "file";
        }

        rModel.filePath = dic;

        listModel.add(rModel);
        rModel = RowModel();
      }
    });
  }

  Future<dynamic> getFileListPath(String path) async {
    listModel.clear();
    var res = await Smblib.GetFilePath(path);
    setState(() {
      _pickPath = path;
      _currentPath = path;
      _fullPostPath += path;
      for (String dic in res) {
        if (dic.contains("/")) {
          rModel.filetype = "folder";
        } else {
          rModel.filetype = "file";
        }
        rModel.filePath = dic;
        listModel.add(rModel);
        rModel = RowModel();
      }
    });
  }

  Future<void> getBackData(String path) async {
    if (path.isEmpty) {
      Navigator.pop(context);
      return;
    }

    ///substr最後斜線
    String p = path.substring(0, path.lastIndexOf("/"));

    ///substr到父層
    String p2 = p.substring(0, p.lastIndexOf("/") + 1);

    getFileListPath(p2);
  }

  Future<void> fileUpload() async {
    showLoadingDialog(context);
    int count = 0;
    String res = "";
    for (String localPath in widget.imagePathList!) {
      String imgFileName = localPath.substring(localPath.lastIndexOf("/") + 1);
      String loPath = "";
      if (imgFileName.contains(".aes")) {
        String filesPath =
            localPath.substring(0, localPath.lastIndexOf("/") + 1);

        /// get dir
        Directory dir = Directory(filesPath);
        List<FileSystemEntity> files = dir.listSync(recursive: true);
        for (FileSystemEntity dic in files) {
          FileStat fi = dic.statSync();
          if (fi.type.toString().contains("file")) {
            print(fi);
            if (dic.uri.path.contains('.aes')) {
              if (count == 0) {
                for (FileSystemEntity dic in files) {
                  FileStat fi = dic.statSync();
                  if (fi.type.toString().contains("file")) {
                    if (!dic.uri.path.contains('.aes')) {
                      dic.delete(recursive: true);
                    }
                  }
                  count++;
                }
              }
            }
          }
        }
        loPath = await _getNormalFile(localPath);
        String postUrl =
            _parentPath + _currentPath + imgFileName.replaceAll(".aes", "");
        print('file upload folder path -> $postUrl');
        res = await Smblib.UploadFile(postUrl, loPath);
      } else {
        loPath = localPath;
        String postUrl = _parentPath + _currentPath + imgFileName;
        print('file upload folder path -> $postUrl');
        res = await Smblib.UploadFile(postUrl, loPath);
      }

      if (res == "1") {
        CommonUtils.showToast(context, msg: 'File upload success');
      } else {
        CommonUtils.showToast(context, msg: 'File upload fail ');
      }
    }
    getFileListPath(_currentPath);
    Navigator.pop(context);
  }

  void _callback(String path) async {
    // _fullPostPath = "";
    getFileListPath(path);
  }

  initData() async {
    var resp = await LocalStorage.get(Config.nasinfo);
    if (resp != null) {
      Map<String, dynamic> json = jsonDecode(resp);
      String host = json["hostName"];
      String user = json["userName"];
      String pwd = json["password"];
      _fullPostPath += host + "/";
      _parentPath = _fullPostPath;
      var userRes = await UserInfoDao.getUserInfoLocal();
      setState(() {
        userInfo = userRes.data;
        getFileList();
      });
    }
  }

  _getNormalFile(String path) async {
    Uint8List encData = await _readData(path);
    AesUtils.aesIv = userInfo.aesIv;
    AesUtils.aesKey = userInfo.aesKey;
    var plainData = await AesUtils.decryptAES(encData);
    // Uint8List.fromList(plainData);
    String reStr = (path.replaceAll('.aes', ''));
    String p = await _writeData(plainData, reStr);
    return p;
  }

  Future<Uint8List> _readData(path) async {
    File f = File(path);
    var res = f.readAsBytesSync();
    return res;
  }

  Future<String> _writeData(dataToWrite, fileNameWithPath) async {
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);
    return f.path;
  }

  Widget _pdfDialog(BuildContext context, func) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: PdfDialog(
          filePath: widget.imagePathList,
          nasPath: _parentPath + _currentPath,
          currentPath: _currentPath,
          callback: func,
        ),
      )),
    );
  }

  @override
  void initState() {
    initData();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<SysState>(builder: (context, store) {
      return SafeArea(
          top: false,
          child: Material(
              child: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('static/images/bg.png'),
                          fit: BoxFit.fill)),
                  child: Column(
                    children: [_appBar(), _body(), _bottomBar()],
                  ))));
    });
  }

  /// appbar
  Widget _appBar() {
    Widget w;
    w = SizedBox(
        height: deviceHeight10(context),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.only(
                      top: MyScreen.backArrowPaddingTop(context), left: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      if (mounted) {
                        getBackData(_currentPath);
                      }
                    },
                  ))),
          Expanded(
              flex: 6,
              child: Center(
                  child: Container(
                padding: const EdgeInsets.only(bottom: 15),
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Network Attached Storage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MyScreen.minFontSize(context),
                  ),
                ),
              ))),
          Expanded(flex: 2, child: Container()
              // Container(
              //   padding: const EdgeInsets.only(top: 30),
              //   child: IconButton(
              //       iconSize: 40,
              //       onPressed: () {
              //         showDialog(
              //             context: context,
              //             builder: (BuildContext context) => _AddfolderDialog(
              //                 context, _callback, _fullPostPath));
              //       },
              //       icon: const Icon(
              //         Icons.add,
              //         color: Colors.white,
              //       )),
              // )
              )
        ]));
    return w;
  }

  ///body
  Widget _body() {
    Widget w;
    w = listModel.isEmpty
        ? Expanded(
            child: Container(
            width: double.infinity,
            color: Colors.white,
            child: showLoadingAnime(context),
          ))
        : Expanded(
            child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                  child: ListView.separated(
                      itemBuilder: (conext, index) {
                        return _titleItems(index)[index];
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.grey,
                          height: 2,
                        );
                      },
                      itemCount: _titleItems(-1).length)),
            ),
          ));
    return w;
  }

  ///bottomBar
  Widget _bottomBar() {
    Widget w;
    w = widget.isCanUpload!
        ? SizedBox(
            height: deviceHeight10(context),
            child: GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _pdfDialog(context, _callback));
                // await fileUpload();
              },
              child: Center(
                child: Text(
                  'upload',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MyScreen.appBarFontSize(context)),
                ),
              ),
            ))
        : SizedBox(
            height: deviceHeight10(context),
          );
    return w;
  }

  List<Widget> _titleItems(int index) {
    List<Widget> list = [];
    for (var dic in listModel) {
      list.add(Container(
          child: ListTile(
        leading: dic.filetype == "folder"
            ? Image.asset(
                'static/images/file.png',
                fit: BoxFit.cover,
              )
            : Image.asset(
                'static/images/fileData.png',
                fit: BoxFit.cover,
              ),
        title: Transform(
            transform: Matrix4.translationValues(10, 0.0, 0.0),
            child: Text(
              dic.filePath,
              style: TextStyle(
                  fontSize: MyScreen.normalPageFontSize(context),
                  color: Colors.redAccent),
            )),
        contentPadding: const EdgeInsets.all(10),
        onTap: () async {
          if (dic.filetype == "folder") {
            if (!_pickPath.contains(dic.filePath)) {
              _pickPath += dic.filePath;

              getFileListPath(_pickPath);
            } else {
              getFileListPath(dic.filePath);
            }
          }
        },
      )));
    }

    return list;
  }

  ///upload按鈕 dialog
  Widget _AddfolderDialog(BuildContext contect, func, folderPath) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: NasAddFolderDialog(
          callback: func,
          folderPath: folderPath,
        ),
      )),
    );
  }
}

class RowModel {
  late String filePath;
  late String filetype;
  RowModel();
}
