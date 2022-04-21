import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scanner/common/dao/UserInfoDao.dart';
import 'package:scanner/common/model/UserInfo.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/AesUtils.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/dialog/CustomerDialog.dart';
import 'package:scanner/common/widget/dialog/UploadDialog.dart';
import 'package:share_plus/share_plus.dart';

class ImageGridViewPage extends StatefulWidget {
  final String filePath;
  final bool? isEdited;
  final String? token;
  const ImageGridViewPage(
      {Key? key, required this.filePath, this.isEdited, this.token})
      : super(key: key);

  @override
  _ImageGridViewPageState createState() => _ImageGridViewPageState();
}

class _ImageGridViewPageState extends State<ImageGridViewPage> with BaseWidget {
  List<CheckBoxModel> ckModelList = [];
  List<CheckBoxModel> filterModelList = [];
  CheckBoxModel checkModel = CheckBoxModel();
  List<String> imageUriList = [];
  List<String> imgFileTime = [];
  List<String> selectedImagePathList = [];
  int count = 0;
  List<String> imageUriAesList = [];

  /// 裝載userinfo
  late UserInfo userInfo;

  _filePath() async {
    Directory dir = Directory(widget.filePath);
    List<FileSystemEntity> files = dir.listSync(recursive: true);

    for (FileSystemEntity dic in files) {
      print(dic.absolute);
      FileStat fi = dic.statSync();
      if (fi.type.toString().contains("file")) {
        print(fi);
        imgFileTime.add(fi.changed.toString().substring(0, 16));
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
            imageUriList.clear();
          }

          ///測試多筆
          // for (int i = 0; i < 5; i++) {
          //   String deCodePath = await _getNormalFile(dic.uri.path);
          //   imageUriList.add(deCodePath);
          //   imgFileTime.add(fi.changed.toString().substring(0, 16));
          // }

          String deCodePath = await _getNormalFile(dic.uri.path);
          imageUriList.add(deCodePath);
          imageUriAesList.add(dic.uri.path);
        } else {
          if (count == 0) {
            if (dic.uri.path.contains('.pdf')) {
              dic.delete(recursive: true);
            } else {
              imageUriList.add(dic.uri.path);
            }
          }
        }
      }
    }

    imageUriList.sort((a, b) => a.compareTo(b));
    imageUriAesList.sort((a, b) => a.compareTo(b));
    getImgMetaData(imageUriList, imgFileTime, imageUriAesList);
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

  ///呼叫api取得metaData
  void getImgMetaData(uriList, timeList, aesUriList) async {
    for (var i = 0; i < uriList.length; i++) {
      setState(() {
        checkModel.val = i;
        checkModel.checked = false;
        checkModel.imageUri = uriList[i];
        checkModel.date = timeList[i];
        checkModel.isDel = false;
        checkModel.isFavor = false;
        if (aesUriList.length > 0) {
          checkModel.imageUriAES = aesUriList[i];
        } else {
          checkModel.imageUriAES = '';
        }

        ckModelList.add(checkModel);
        checkModel = CheckBoxModel();
      });
    }
  }

  ///執行share
  Future<void> _onShare(BuildContext context) async {
    ///把loading取消
    final box = context.findRenderObject() as RenderBox?;

    if (ckModelList.isNotEmpty) {
      List<String> uri = [];
      for (var dic in ckModelList) {
        if (dic.checked) {
          uri.add(dic.imageUri);
        }
      }
      if (uri.isNotEmpty) {
        if (Platform.isAndroid) {
          await Share.shareFiles(uri,
              text: "share files",
              subject: "share files",
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
        } else {
          await Share.shareFiles(uri,
              text: "share files",
              subject: "share files",
              sharePositionOrigin:
                  box!.localToGlobal(Offset(0.0, deviceHeight10(context) * 7)) &
                      box.size);
        }
      }
    }
  }

  ///刪除widget
  void _deleteWidger() {
    setState(() {
      if (ckModelList.isNotEmpty) {
        for (var dic in ckModelList) {
          if (dic.checked && !dic.isFavor) {
            dic.isDel = true;
            deleteTemporaryFile(dic.imageUri);
          }
        }
      }
    });
  }

  ///刪除暫存檔
  deleteTemporaryFile(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (error) {
      debugPrint('Delete TemporaryFile error');
    }
  }

  /// select all 按鈕事件
  _selectAllEvent() async {
    selectedImagePathList.clear();
    for (var dic in ckModelList) {
      setState(() {
        dic.checked = true;
        selectedImagePathList.add(dic.imageUri);
      });
    }
  }

  ///upload按鈕 dialog
  Widget _Dialog(BuildContext contect, title, content) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: CustomerDialog(
          title: title,
          content: content,
        ),
      )),
    );
  }

  Widget _UploadDialog(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: UploadDialog(
          token: widget.token,
          imagePathList: selectedImagePathList,
          imagePathAESList: imageUriAesList,
        ),
      )),
    );
  }

  initData() async {
    var userRes = await UserInfoDao.getUserInfoLocal();
    setState(() {
      userInfo = userRes.data;
      _filePath();
    });
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
  }

  /// appbar
  Widget _appBar() {
    Widget w;
    w = SizedBox(
        height: deviceHeight10(context),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                          if (widget.isEdited != null) {
                            if (widget.isEdited!) {
                              NavigatorUtils.goDocument(context,
                                  isEdited: true, token: widget.token);
                            } else {
                              Navigator.pop(context);
                            }
                          } else {
                            Navigator.pop(context);
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
                      'Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MyScreen.homePageFontSize(context),
                      ),
                    ),
                  ))),
              Expanded(
                  flex: 2,
                  child: GestureDetector(
                      onTap: () async {
                        _selectAllEvent();
                      },
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Select All',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MyScreen.minFontSize(context),
                          ),
                        ),
                      )))
            ]));
    return w;
  }

  ///gen grid圖片
  List<Widget> gridWidget2() {
    List<Widget> list = [];
    for (var dic in ckModelList) {
      if (!dic.isDel) {
        String valStr = "Scan000";
        if (dic.val < 9) {
          valStr = "Scan000${dic.val + 1}";
        } else if (dic.val >= 9 && dic.val < 99) {
          valStr = "Scan00${dic.val + 1}";
        } else if (dic.val >= 99 && dic.val < 999) {
          valStr = "Scan0${dic.val + 1}";
        } else {
          valStr = "Scan${dic.val + 1}";
        }
        list.add(Card(
          key: ValueKey(dic.val),
          child: GestureDetector(
              onTap: () {
                print('tap dic.val => ${dic.val + 1}');
                for (var dic in ckModelList) {
                  print('real arr => ${dic.val + 1}');
                }
                NavigatorUtils.goDetailFileSreen(context,
                    filePath: dic.imageUri,
                    tag: '${dic.val}',
                    token: widget.token,
                    filePathList: imageUriList,
                    modelList: ckModelList,
                    aesPath: dic.imageUriAES ?? '');
              },
              child: Container(
                  // color: Colors.grey,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: FileImage(
                        File(dic.imageUri),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                valStr,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blue),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Transform.scale(
                                      scale: 2.0,
                                      child: Checkbox(
                                          value: dic.checked,
                                          onChanged: (val) {
                                            setState(() {
                                              dic.checked = val!;
                                              if (val == true) {
                                                selectedImagePathList
                                                    .add(dic.imageUri);
                                              } else {
                                                selectedImagePathList
                                                    .remove(dic.imageUri);
                                              }
                                            });
                                          })))),
                        ],
                      ),
                    ],
                  ))),
        ));
      }
    }

    return list;
  }

  ///Scaffold's body widget
  Widget _body() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight * 3) / 2;
    final double itemWidth = size.width / 2;
    Widget body;
    if (ckModelList.isEmpty || isLoading) {
      body = Expanded(
          child: Container(
        width: double.infinity,
        color: Colors.white,
        child: showLoadingAnime(context),
      ));
    } else {
      body = Expanded(
          child: Container(
              color: Colors.white,
              child: ReorderableGridView.count(
                childAspectRatio: (itemWidth / itemHeight),
                crossAxisCount: 3,
                onReorder: (int oldIndex, int newIndex) {
                  print('old -> $oldIndex');
                  print('new -> $newIndex');
                  setState(() {
                    CheckBoxModel oldM = ckModelList[oldIndex];
                    CheckBoxModel newM = ckModelList[newIndex];
                    int oVal = oldM.val;
                    int nVal = newM.val;
                    oldM.val = nVal;
                    newM.val = oVal;
                    CheckBoxModel model = ckModelList.removeAt(oldIndex);
                    ckModelList.insert(newIndex, model);
                  });
                },
                children: gridWidget2(),
              )));
    }

    return body;
  }

  ///bottomBar
  Widget _bottomBar() {
    Widget w;
    w = SizedBox(
      height: deviceHeight10(context),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (selectedImagePathList.isEmpty) {
                  return;
                } else {
                  if (widget.token!.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => _Dialog(
                            context, '', 'Please login to be use file upload'));
                    return;
                  } else {
                    if (Platform.isAndroid) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _UploadDialog(context));
                    } else {
                      NavigatorUtils.goUploadCloud(context,
                          token: widget.token,
                          imagePathList: selectedImagePathList);
                    }
                  }
                }
              },
              child: Image.asset('static/images/ccs.png'),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                _deleteWidger();
              },
              child: Image.asset('static/images/trash.png'),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (widget.token!.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _Dialog(context, '', 'Please login to be use share'));
                  return;
                } else {
                  _onShare(context);
                }
              },
              child: Image.asset('static/images/Ellipse.png'),
            ),
          ),
        ],
      ),
    );
    return w;
  }
}

class CheckBoxModel {
  late int val;
  late bool checked;
  late String imageUri;
  late String? imageUriAES;
  late String date;
  late bool isDel;
  late bool isFavor;
  CheckBoxModel();
}
