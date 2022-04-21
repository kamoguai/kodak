import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/ScannerDao.dart';
import 'package:scanner/common/dao/UserInfoDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/model/UserInfo.dart';
import 'package:scanner/common/net/Address.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/AesUtils.dart';
import 'package:scanner/common/utils/CommonUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:image/image.dart' as img;

///
///掃描與設定頁面
///Date: 2022-01-18
///
class ScanandSettingPage extends StatefulWidget {
  ///由上一頁傳入sessionID
  final Map<String, dynamic> sessionID;
  const ScanandSettingPage({Key? key, required this.sessionID})
      : super(key: key);

  @override
  _ScanandSettingPageState createState() => _ScanandSettingPageState();
}

class _ScanandSettingPageState extends State<ScanandSettingPage>
    with BaseWidget {
  ///裝configData
  Map<String, dynamic> configData = {};
  Map<String, dynamic> loadConfig = {};

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

  ///標記上一頁按鈕
  bool isCanPop = false;

  /// 裝載userinfo
  late UserInfo userInfo;

  ///呼叫API取得session
  Future<void> getSession() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap["OCPUserName"] = "user";
    var res = await ScannerDao.getSession(jsonMap);
    if (res != null && res.result) {
      print("====>${res.data}");
      setState(() {
        headersData.addAll(res.data);
      });
    }
  }

  ///取得session狀態API
  void getSessionStat() async {
    isLoading = true;
    Map<String, dynamic> resMap = {};
    var res = await ScannerDao.getSessionStat(headersData);
    resMap = res.data["Configuration"];
    setState(() {
      if (loadConfig.isEmpty) {
        dpiStr = resMap["DPI"];
        colorModeStr = resMap["ColorMode"];
        scanSideStr = resMap["ScanSide"];
        sbpStr = resMap["SkipBlankPages"];
      } else {
        resMap = loadConfig["Configuration"];
        dpiStr = resMap["DPI"];
        colorModeStr = resMap["ColorMode"];
        scanSideStr = resMap["ScanSide"];
        sbpStr = resMap["SkipBlankPages"];
      }
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
    showLoadingDialog(context);
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    Map<String, dynamic> map = <String, dynamic>{};
    map["DPI"] = dpiStr;
    map["ScanSide"] = scanSideStr;
    map["ColorMode"] = colorModeStr;
    map["SkipBlankPages"] = sbpStr;
    map["AutoStart"] = 1;
    map["OutputType"] = 'Images';
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

        ///開啟掃描後不能返回
        isCanPop = false;
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
          _downloadAndCreate(numImages, scanCount);
        });
      }
    }
  }

  ///移除連線API
  Future<void> deleteSession() async {
    if (isCanPop) {
      await ScannerDao.deleteSession(headersData);
      clearData();
      if (mounted) Navigator.pop(context);
    }
  }

  initDir() async {
    var path = await LocalStorage.get(Config.imgTemptDir);
    if (path != null) {
      if (Directory(path).existsSync()) {
        Directory(path).deleteSync(recursive: true);
      }
    }
    var userRes = await UserInfoDao.getUserInfoLocal();
    setState(() {
      userInfo = userRes.data;
    });
  }

  ///寫到落地檔暫存
  Future<void> _downloadAndCreate(count, scanCount) async {
    // showLoadingDialog(context);

    ///取得暫存位址
    final appDir = await getApplicationDocumentsDirectory();
    String nowStr = CommonUtils.getDateSecStr(DateTime.now());

    ///抓取現在時間，yyyyMMddhhmmss
    String replaceDate =
        nowStr.replaceAll("-", "").replaceAll(" ", "").replaceAll(":", "");

    ///暫存位址添加folder
    var folderPath = appDir.path + Platform.pathSeparator + "ScanDir";
    var fullPath = folderPath + Platform.pathSeparator + replaceDate;

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
      String appPath = "";

      /// scan檔案名為tiff
      appPath = fullPath + Platform.pathSeparator + "$timeStamp.tiff";
      debugPrint(appPath);
      //把檔案用Dio download存到暫時路徑
      var response = await Dio().download(Address.getImg(i), appPath,
          options:
              Options(headers: headersData, responseType: ResponseType.bytes),
          onReceiveProgress: (count, total) {
        //這邊是下載進度的換算, 可以從這裡取出數值
        debugPrint(
            "$appPath--> " + (count / total * 100).toStringAsFixed(0) + "%");
      });

      ///tiff檔案，在此轉檔為png，檔案名不變
      img.Image? im = img.decodeImage(File(appPath).readAsBytesSync());

      img.Image thumbnail = img.copyResize(im!, width: 1200);
      File(appPath).deleteSync();
      File(appPath).writeAsBytesSync(img.encodePng(thumbnail));

      if (userInfo.useAes == "Y") {
        ///讀取檔案
        var ff = File(appPath).readAsBytesSync();

        ///宣告空list<int>
        List<int> listInt = [];

        ///將file檔案由unit8list 迴圈為list<int>
        for (var d in ff) {
          listInt.add(d);
        }

        ///塞入login取得的key, iv
        AesUtils.aesKey = userInfo.aesKey;
        AesUtils.aesKey = userInfo.aesIv;

        /// 將list<int>轉為aes256
        var encResult = AesUtils.encryptAES(listInt);

        /// 講檔案寫入資料夾並改名為.aes
        String p = await _writeData(encResult, appPath + '.aes');
        debugPrint("aes writing success -> $p");

        /// 刪除原本檔案，只留aes檔案
        File(appPath).deleteSync();
      }
    }
    setState(() {
      ///寫檔結束後可返回
      isCanPop = true;
    });
    await previvew();
    Navigator.pop(context);
  }

  Future<String> _writeData(dataToWrite, fileNameWithPath) async {
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);
    return f.absolute.toString();
  }

  ininData() async {
    isLoading = false;
    isScanDone = false;

    ///初始可以返回
    isCanPop = true;
    clearData();

    ///將前一頁的sessionId帶入headers
    headersData.addAll(widget.sessionID);

    ///讀取內存設定檔
    var con = await LocalStorage.get(Config.scannerConfig);
    if (con != null) {
      loadConfig = json.decode(con);
    }
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

  @override
  void initState() {
    super.initState();
    ininData();
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
                        onPressed: () async {
                          await deleteSession();
                        },
                      ))),
              Expanded(
                  flex: 6,
                  child: Center(
                      child: Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MyScreen.appBarFontSize(context),
                      ),
                    ),
                  ))),
              const Expanded(flex: 2, child: SizedBox())
            ]));
    return w;
  }

  ///body
  Widget _body() {
    final deviceHeight = MediaQuery.of(context).size.height;
    Widget w;
    w = configData.isEmpty == true
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(40))),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  'Color Mode',
                                  style: TextStyle(
                                      fontSize:
                                          MyScreen.appBarFontSize(context)),
                                ),
                              ),
                              Expanded(child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15))),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                            value: colorModeStr,
                                            isDense: true,
                                            items:
                                                colorModeList.map((String val) {
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
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  'Scan Side',
                                  style: TextStyle(
                                      fontSize:
                                          MyScreen.appBarFontSize(context)),
                                ),
                              ),
                              Expanded(child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0))),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                            value: scanSideStr,
                                            isDense: true,
                                            items:
                                                scanSideList.map((String val) {
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
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  'DPI',
                                  style: TextStyle(
                                      fontSize:
                                          MyScreen.appBarFontSize(context)),
                                ),
                              ),
                              Expanded(child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0))),
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
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  'Skip Blank Pages',
                                  style: TextStyle(
                                      fontSize:
                                          MyScreen.appBarFontSize(context)),
                                ),
                              ),
                              Expanded(child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0))),
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
                        ],
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  child: SizedBox(
                    child: Image.asset(
                      'static/images/scanBtn.png',
                      scale: MyScreen.scanPageScale(context),
                    ),
                  ),
                  onTap: () async {
                    await updateConfig();

                    Timer.periodic(const Duration(seconds: 3), (timer) {
                      if (!isScanDone) {
                        timer.cancel();
                      } else {
                        try {
                          getScanDone();
                        } catch (e) {
                          timer.cancel();
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ));
    return w;
  }

  ///bottomBar
  Widget _bottomBar() {
    Widget w;
    w = SizedBox(
      height: deviceHeight10(context),
    );
    return w;
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
