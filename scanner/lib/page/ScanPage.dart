import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/ScannerDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/net/Address.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/CommonUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/page/SelectFolderPage.dart';

///
///scan頁面
///Date: 2022-01-10
class ScanPage extends StatefulWidget {
  ///由上一頁傳入sessionID
  final String sessionID;

  ///由上一頁傳入connectIP
  final String connectIP;

  final String deviceHostName;

  const ScanPage(
      {Key? key,
      required this.sessionID,
      required this.connectIP,
      required this.deviceHostName})
      : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with BaseWidget {
  ///裝configData
  Map<String, dynamic> configData = {};

  ///裝head資料
  final Map<String, dynamic> headersData = {};

  ///viewmodel
  ScanViewModel viewModel = ScanViewModel();

  final List<ScanViewModel> dropDownItems = [];

  int dpiStr = 0;
  String colorModeStr = "";
  String scanSideStr = "";
  int sbpStr = 0;
  bool isScanDone = false;
  String scanBtnStr = "SCAN";
  int scanCount = 0;

  List<int> dpiList = [];

  List<String> colorModeList = [];

  List<String> scanSideList = [];

  List<int> sbpList = [];

  ///暫存資料夾位置
  List<String> previewPath = [];

  ///取得session狀態API
  void getSessionStat() async {
    isLoading = true;
    Map<String, dynamic> resMap = {};
    var res = await ScannerDao.getSessionStat(headersData);
    resMap = res.data["Configuration"];
    setState(() {
      dpiStr = resMap["DPI"];
      colorModeStr = resMap["ColorMode"];
      scanSideStr = resMap["ScanSide"];
      sbpStr = resMap["SkipBlankPages"];
      getCapabilities();
    });
  }

  ///取得下拉選單物件
  void getCapabilities() async {
    Map<String, dynamic> resMap = {};
    var res = await ScannerDao.getCapabilities();
    resMap = res.data["Configuration"];
    setState(() {
      configData = resMap;
      dpiList = (resMap["DPI"].cast<int>());
      colorModeList = (resMap["ColorMode"].cast<String>());
      scanSideList = (resMap["ScanSide"].cast<String>());
      sbpList = (resMap["SkipBlankPages"].cast<int>());
      isLoading = false;
    });
  }

  ///更新掃描機config API
  Future<void> updateConfig() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    Map<String, dynamic> map = <String, dynamic>{};
    map["DPI"] = dpiStr;
    map["ScanSide"] = scanSideStr;
    map["ColorMode"] = colorModeStr;
    map["SkipBlankPages"] = sbpStr;
    map["AutoStart"] = 1;
    jsonMap["Configuration"] = map;
    var res = await ScannerDao.updateConfig(headersData, jsonMap);
    if (res.result) {
      ///跑完update開啟scan
      startScan();
    }
  }

  ///開啟掃描功能
  void startScan() async {
    var res = await ScannerDao.startScan(headersData);
    if (res.result) {
      setState(() {
        scanBtnStr = "SCAN DONE";
        isScanDone = true;
      });
    }
  }

  ///取得session狀態API
  void getScanDone() async {
    Map<String, dynamic> resMap = {};
    int numImages = 0;
    var res = await ScannerDao.getSessionStat(headersData);
    if (res.result) {
      String r = res.data["Status"]["State"];
      if (r == 'Done Scanning') {
        setState(() {
          scanCount++;
          resMap = res.data["Status"];
          numImages = resMap["NumImagesScanned"];
          scanBtnStr = "SCAN";
          isScanDone = false;
          saveSupprotDir(numImages, scanCount);
        });
      }
    }
  }

  ///移除連線API
  void deleteSession() async {
    var res = await ScannerDao.deleteSession(headersData);
    clearData();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  initDir() async {
    var path = await LocalStorage.get(Config.imgTemptDir);
    if (path != null) {
      if (Directory(path).existsSync()) {
        Directory(path).deleteSync(recursive: true);
      }
    }
  }

  ///寫到落地檔暫存
  Future<void> saveSupprotDir(count, scanCount) async {
    showLoadingDialog(context);

    ///取得暫存位址
    final appDir = await getApplicationDocumentsDirectory();
    String nowStr = CommonUtils.getDateSecStr(DateTime.now());

    ///暫存位址添加folder
    var folderPath = appDir.path + Platform.pathSeparator + "ScanDir";
    var fullPath = folderPath + Platform.pathSeparator + "Scan$scanCount";

    ///判斷是否有此folder，沒有就創建
    if (!Directory(folderPath).existsSync()) {
      Directory(folderPath).createSync();
      Directory(fullPath).createSync();
    }

    ///取得內部資料
    var ls = await LocalStorage.get(Config.imgDocDir);
    if (ls != null) {
      ///有資料就移除
      await LocalStorage.remove(Config.imgDocDir);
    }

    ///保存內部資料
    await LocalStorage.save(Config.imgDocDir, folderPath);

    ///開始寫資料
    for (int i = 1; i <= count; i++) {
      String timeStamp =
          DateTime.now().millisecondsSinceEpoch.toString() + "$i";
      //檔名暫時用timeStamp命名
      String appPath = fullPath + Platform.pathSeparator + "$timeStamp.png";
      debugPrint(appPath);
      //把檔案用Dio download存到暫時路徑
      final response = await Dio().download(Address.getImg(i), appPath,
          options: Options(headers: headersData),
          onReceiveProgress: (count, total) {
        //這邊是下載進度的換算, 可以從這裡取出數值
        debugPrint(
            "$appPath--> " + (count / total * 100).toStringAsFixed(0) + "%");
      });
    }
    await previvew();
    Navigator.pop(context);
  }

  ininData() async {
    isLoading = false;
    isScanDone = false;
    clearData();

    ///將前一頁的sessionId帶入headers
    headersData['SessionId'] = widget.sessionID;
    getSessionStat();
  }

  clearData() async {
    await initDir();
    dpiList.clear();
    colorModeList.clear();
    scanSideList.clear();
    sbpList.clear();
  }

  previvew() async {
    previewPath.clear();
    var path = await LocalStorage.get(Config.imgDocDir);
    Directory dir = Directory(path);
    List<FileSystemEntity> files = dir.listSync(recursive: true);
    for (FileSystemEntity dic in files) {
      print(dic.absolute);
      FileStat fi = dic.statSync();
      print(fi);
      if (fi.type.toString().contains("directory")) {
        setState(() {
          previewPath.add(dic.uri.path);
        });
      }
      print(fi.type.toString());
      print(previewPath);
    }
  }

  Widget _body() {
    Widget body;
    body = configData.isEmpty == true
        ? Expanded(
            child: Container(
            width: double.infinity,
            color: Colors.white,
            child: showLoadingAnime(context),
          ))
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        'Color Mode',
                        style: TextStyle(
                            fontSize: MyScreen.normalPageFontSize(context)),
                      ),
                    ),
                    Expanded(child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  value: colorModeStr,
                                  isDense: true,
                                  items: colorModeList.map((String val) {
                                    return DropdownMenuItem(
                                      child: Text(val),
                                      value: val,
                                    );
                                  }).toList(),
                                  onChanged: (String? newVal) {
                                    setState(() {
                                      colorModeStr = newVal!;
                                    });
                                  }),
                            ));
                      },
                    ))
                  ],
                ),
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        'Scan Side',
                        style: TextStyle(
                            fontSize: MyScreen.normalPageFontSize(context)),
                      ),
                    ),
                    Expanded(child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  value: scanSideStr,
                                  isDense: true,
                                  items: scanSideList.map((String val) {
                                    return DropdownMenuItem(
                                      child: Text(val),
                                      value: val,
                                    );
                                  }).toList(),
                                  onChanged: (String? newVal) {
                                    setState(() {
                                      scanSideStr = newVal!;
                                    });
                                  }),
                            ));
                      },
                    ))
                  ],
                ),
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        'DPI',
                        style: TextStyle(
                            fontSize: MyScreen.normalPageFontSize(context)),
                      ),
                    ),
                    Expanded(child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                  value: dpiStr,
                                  isDense: true,
                                  items: dpiList.map((int val) {
                                    return DropdownMenuItem(
                                      child: Text('$val'),
                                      value: val,
                                    );
                                  }).toList(),
                                  onChanged: (int? newVal) {
                                    setState(() {
                                      dpiStr = newVal!;
                                    });
                                  }),
                            ));
                      },
                    ))
                  ],
                ),
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        'Skip Blank Pages',
                        style: TextStyle(
                            fontSize: MyScreen.normalPageFontSize(context)),
                      ),
                    ),
                    Expanded(child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                  value: sbpStr,
                                  isDense: true,
                                  items: sbpList.map((int val) {
                                    return DropdownMenuItem(
                                      child: Text('$val'),
                                      value: val,
                                    );
                                  }).toList(),
                                  onChanged: (int? newVal) {
                                    setState(() {
                                      sbpStr = newVal!;
                                    });
                                  }),
                            ));
                      },
                    ))
                  ],
                ),
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                SizedBox(
                  width: deviceWidth1_5(context),
                  height: deviceHeight15(context),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue[300]!),
                    child: Text(
                      scanBtnStr,
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    onPressed: () async {
                      await updateConfig();

                      Timer.periodic(const Duration(seconds: 3), (timer) {
                        if (!isScanDone) {
                          timer.cancel();
                        } else {
                          getScanDone();
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                SizedBox(
                  width: deviceWidth1_5(context),
                  height: deviceHeight15(context),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue[300]!),
                    child: const Text(
                      'DISCONNECT',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    onPressed: () async {
                      deleteSession();
                    },
                  ),
                ),
                SizedBox(
                  height: titleHeight(context) / 1.5,
                ),
                previewPath.isEmpty
                    ? const SizedBox()
                    : SelectFolderPage(pathList: previewPath),
              ],
            ),
          );
    return body;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ininData();
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
      child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              leading: const Image(
                image: AssetImage('static/images/scan.png'),
                fit: BoxFit.fill,
              ),
              title: Center(
                  child: Text(
                widget.deviceHostName,
                style:
                    TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
                textAlign: TextAlign.center,
              ))),
          body: _body()),
    );
  }
}

class ScanViewModel {
  late String dpi;
  late String scanside;
  late String colorMode;
  late String skipBlankPages;

  ScanViewModel();
  ScanViewModel.forMap(data) {
    dpi = data["DPI"];
    scanside = data["ScanSide"];
    colorMode = data["ColorMode"];
    skipBlankPages = data["SkipBlankPages"];
  }
}
