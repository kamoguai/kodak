import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/DocumentSelectWidget.dart';
import 'package:scanner/common/widget/dialog/CustomerDialog.dart';
import 'package:scanner/common/widget/dialog/UploadDialog.dart';
import 'package:share_plus/share_plus.dart';

///
///文件頁面
///Date: 2022-01-17
///
class DocumentPage extends StatefulWidget {
  final bool? isEdited;
  final String? token;
  const DocumentPage({Key? key, this.isEdited, this.token}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> with BaseWidget {
  List<CheckBoxModel> ckModelList = [];
  List<CheckBoxModel> filterModelList = [];
  List<CheckBoxModel> originModelList = [];
  CheckBoxModel checkModel = CheckBoxModel();
  List<String> imageUriList = [];
  List<String> imgFileTime = [];
  bool isSelecMod = false;
  List<String> selectedFilePathList = [];

  ///初始化取得檔案資料夾
  _filePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    var folderPath = appDir.path + Platform.pathSeparator + "ScanDir";

    Directory dir = Directory(folderPath);
    bool isExsit = dir.existsSync();
    if (isExsit) {
      List<FileSystemEntity> files = dir.listSync(recursive: true);

      for (FileSystemEntity dic in files) {
        print(dic.absolute);
        FileStat fi = dic.statSync();
        print(fi);
        if (fi.type.toString().contains("directory")) {
          imgFileTime.add(
              fi.accessed.toString().substring(0, 19).replaceAll("-", "/"));
          imageUriList.add(dic.uri.path);
        }

        print(imageUriList);
      }
    }
    imgFileTime.sort((a, b) => b.compareTo(a));
    imageUriList.sort((a, b) => b.compareTo(a));
    getImgMetaData(imageUriList, imgFileTime);
  }

  ///選擇要的資料夾取出所有圖片
  _fileAllPath(filePath) async {
    // showLoadingAnime(context);
    imageUriList.clear();
    Directory dir = Directory(filePath);
    List<FileSystemEntity> files = dir.listSync(recursive: true);

    for (FileSystemEntity dic in files) {
      print(dic.absolute);
      FileStat fi = dic.statSync();
      if (fi.type.toString().contains("file")) {
        imageUriList.add(dic.uri.path);
      }
    }
    // Navigator.pop(context);
  }

  ///呼叫api取得metaData
  void getImgMetaData(uriList, timeList) async {
    for (var i = 0; i < uriList.length; i++) {
      setState(() {
        checkModel.val = i;
        checkModel.checked = false;
        checkModel.imageUri = uriList[i];
        checkModel.date = timeList[i];
        checkModel.isDel = false;
        checkModel.isFavor = false;
        checkModel.zipUri = "";
        ckModelList.add(checkModel);
        originModelList.add(checkModel);
        checkModel = CheckBoxModel();
      });
    }
  }

  ///執行share
  Future<void> _onShare(BuildContext context) async {
    ///把loading取消
    Navigator.pop(context);
    final box = context.findRenderObject() as RenderBox?;

    if (ckModelList.isNotEmpty) {
      List<String> uri = [];
      for (var dic in ckModelList) {
        if (dic.checked) {
          uri.add(dic.zipUri);
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
      originModelList.clear();
      originModelList.addAll(ckModelList);
    });
  }

  ///刪除暫存檔
  void deleteTemporaryFile(String filePath) async {
    try {
      String subPath = filePath.substring(0, filePath.lastIndexOf("/"));
      File(subPath).deleteSync(recursive: true);
    } catch (error) {
      debugPrint('Delete TemporaryFile error');
    }
  }

  ///將所選資料夾裡面所有檔案壓成zip
  Future<void> _zipFile() async {
    final List<File> fileList = [];
    int count = 0;
    for (var dic in ckModelList) {
      if (dic.checked) {
        count++;
        Directory dir = Directory(dic.imageUri);
        bool isExsit = dir.existsSync();
        if (isExsit) {
          List<FileSystemEntity> files = dir.listSync(recursive: true);

          for (FileSystemEntity dic in files) {
            print(dic.absolute);
            FileStat fi = dic.statSync();
            print(fi);
            if (fi.type.toString().contains("file")) {
              fileList.add(File(dic.uri.path));
            }
          }
        }

        final sourceDir = Directory(dic.imageUri);
        String timestempStr = dic.date
                .replaceAll("-", "")
                .replaceAll(":", "")
                .replaceAll(" ", "") +
            "$count";
        final zipFile = File(dic.imageUri + "$timestempStr.zip");
        try {
          ZipFile.createFromFiles(
              sourceDir: sourceDir, files: fileList, zipFile: zipFile);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  ///將所選資料夾壓成zip
  Future<void> _zipFile2() async {
    ///進來就loading
    showLoadingDialog(context);
    int count = 0;
    final appDir = await getApplicationDocumentsDirectory();
    var folderPath = appDir.path +
        Platform.pathSeparator +
        "ScanDir" +
        Platform.pathSeparator;

    for (var dic in ckModelList) {
      if (dic.checked && dic.zipUri.isEmpty) {
        count++;
        final sourceDir = Directory(dic.imageUri);
        String timestempStr = dic.date
                .replaceAll("-", "")
                .replaceAll(":", "")
                .replaceAll(" ", "") +
            "$count";
        final zipFile = File(folderPath + "$timestempStr.zip");
        try {
          ZipFile.createFromDirectory(sourceDir: sourceDir, zipFile: zipFile);
        } catch (e) {
          print(e);
        }
        setState(() {
          dic.zipUri = zipFile.path;
        });
      } else {
        setState(() {
          dic.zipUri = '';
        });
      }
    }
  }

  void _onChangeSelectMod() async {
    setState(() {
      if (isSelecMod) {
        isSelecMod = false;
      } else {
        isSelecMod = true;
      }
    });
  }

  initData() async {
    _filePath();
  }

  ///filter function
  void _filterFunc(data) {
    print('callback -> $data');
    setState(() {
      filterModelList.clear();
      filterModelList.addAll(data);
      ckModelList.clear();
      ckModelList.addAll(filterModelList);
    });
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
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: UploadDialog(
          token: widget.token,
          imagePathList: imageUriList,
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
                  children: [_appBar(), _search(), _body(), _bottomBar()],
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
                              NavigatorUtils.goOption(context);
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
                      'Documents',
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
                        _onChangeSelectMod();
                      },
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'select',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MyScreen.defaultTableCellFontSize(context),
                          ),
                        ),
                      )))
            ]));
    return w;
  }

  Widget _search() {
    Widget w;
    w = Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        color: Colors.white,
        child: DocumentSelectWidget(
          ckModelList: ckModelList,
          filterFunc: _filterFunc,
          callBackData: originModelList,
        ));
    return w;
  }

  ///body
  Widget _body() {
    Widget w;
    if (ckModelList.isEmpty) {
      w = Expanded(
          child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Center(
              child: ListView.separated(
                  itemBuilder: (conext, index) {
                    return _dummyItems()[index];
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.grey,
                      height: 2,
                    );
                  },
                  itemCount: _dummyItems().length)),
        ),
      ));
    } else {
      w = Expanded(
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
    }
    return w;
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
              onTap: () async {
                if (isSelecMod) {
                  if (selectedFilePathList.isEmpty) {
                    return;
                  } else {
                    if (widget.token!.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => _Dialog(context,
                              '', 'Please login to be use file upload'));
                      return;
                    } else {
                      if (selectedFilePathList.length > 1) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => _Dialog(context,
                                '', 'Please upload one folder at a time'));
                        return;
                      }
                      await _fileAllPath(selectedFilePathList[0]);
                      if (Platform.isAndroid) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _UploadDialog(context));
                      } else {
                        NavigatorUtils.goUploadCloud(context,
                            token: widget.token, imagePathList: imageUriList);
                      }
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
                if (isSelecMod) {
                  _deleteWidger();
                }
              },
              child: Image.asset('static/images/trash.png'),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (isSelecMod) {
                  if (widget.token!.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => _Dialog(
                            context, '', 'Please login to be use share'));
                    return;
                  } else {
                    await _zipFile2();
                    await _onShare(context);
                  }
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

  List<Widget> _titleItems(int index) {
    List<Widget> list = [];

    for (var dic in ckModelList) {
      if (!dic.isDel) {
        list.add(ListTile(
          leading: Image.asset(
            'static/images/fileData.png',
            fit: BoxFit.cover,
          ),
          trailing: Image.asset(
            'static/images/arrow.png',
            fit: BoxFit.cover,
          ),
          title: Transform(
              transform: Matrix4.translationValues(10, 0.0, 0.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      dic.date,
                      style: TextStyle(
                          fontSize: MyScreen.minFontSize(context),
                          color: Colors.redAccent),
                    ),
                    isSelecMod
                        ? Transform.scale(
                            scale: 2.0,
                            child: Checkbox(
                                value: dic.checked,
                                onChanged: (val) {
                                  setState(() {
                                    dic.checked = val!;
                                    if (val == true) {
                                      selectedFilePathList.add(dic.imageUri);
                                    } else {
                                      selectedFilePathList.remove(dic.imageUri);
                                    }
                                  });
                                }))
                        : const SizedBox()
                  ])),
          contentPadding: const EdgeInsets.all(10),
          onTap: () {
            NavigatorUtils.goImageGridView(
                context, dic.imageUri, false, widget.token);
          },
        ));
      }
    }
    list.add(SizedBox(
      height: deviceHeight10(context),
    ));

    return list;
  }

  List<Widget> _dummyItems() {
    List<Widget> list = [];
    for (int i = 0; i < 5; i++) {
      list.add(SizedBox(
        height: deviceHeight10(context),
      ));
    }

    return list;
  }
}

class CheckBoxModel {
  late int val;
  late bool checked;
  late String imageUri;
  late String date;
  late bool isDel;
  late bool isFavor;
  late String zipUri;
  CheckBoxModel();
}
