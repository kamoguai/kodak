import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/ScannerDao.dart';
import 'package:scanner/common/dao/UserInfoDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scanner/common/redux/SysState.dart';
import 'package:scanner/common/widget/dialog/CustomerDialog.dart';
import 'package:redux/redux.dart';
import 'package:smblib/smblib.dart';

///
///app 首頁
///Date: 2022-01-17
class OptionPage extends StatefulWidget {
  static const String sName = "option";
  const OptionPage({Key? key}) : super(key: key);

  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> with BaseWidget {
  Map<String, dynamic> headers = {};
  String tokenStr = '';
  bool isConnectNas = false;

  Store<SysState> _getStore() {
    return StoreProvider.of(context);
  }

  ///呼叫API取得session
  Future<void> getSession() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap["OCPUserName"] = "user";
    var res = await ScannerDao.getSession(jsonMap);
    if (res != null && res.result) {
      print("====>${res.data}");
      setState(() {
        headers.addAll(res.data);
      });
    }
  }

  ///呼叫取Doctype list api
  Future<void> _getDocTypeApi() async {
    var res =
        await UserInfoDao.getDocTypesList(_getStore().state.userInfo.token);
    if (res.result) {
      await LocalStorage.save(Config.doctypes, jsonEncode(res.data["rows"]));
    }
  }

  ///移除連線API
  Future<void> deleteSession() async {
    var res = await ScannerDao.deleteSession(headers);
  }

  ///登入nas
  Future<void> nasLogin() async {
    var resp = await LocalStorage.get(Config.nasinfo);
    if (resp != null) {
      Map<String, dynamic> json = jsonDecode(resp);
      String host = json["hostName"];
      String user = json["userName"];
      String pwd = json["password"];
      await Smblib.Login(host, user, pwd);
      setState(() {
        isConnectNas = true;
      });
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() async {
    await LocalStorage.remove(Config.sessionHeaders);
    if (_getStore().state.userInfo.token.isNotEmpty) {
      tokenStr = _getStore().state.userInfo.token;
      _getDocTypeApi();
    }
    await nasLogin();
  }

  ///upload按鈕 dialog
  Widget _Dialog(BuildContext context, title, content) {
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
      child: Center(
          child: Container(
        padding: const EdgeInsets.only(bottom: 15),
        alignment: Alignment.bottomCenter,
        child: Text(
          'Main Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: MyScreen.appBarFontSize(context),
          ),
        ),
      )),
    );
    return w;
  }

  ///body
  Widget _body() {
    Widget w;
    w = Expanded(
        child: Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
            child: ListView.separated(
                itemBuilder: (conext, index) {
                  return _titleItems()[index];
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    height: 2,
                  );
                },
                itemCount: _titleItems().length)),
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

  List<Widget> _titleItems() {
    List<Widget> list = [];
    list.add(ListTile(
      leading: Image.asset(
        'static/images/settings.png',
        fit: BoxFit.cover,
      ),
      trailing: Image.asset(
        'static/images/arrow.png',
        fit: BoxFit.cover,
      ),
      title: Transform(
          transform: Matrix4.translationValues(10, 0.0, 0.0),
          child: Text(
            'Connect',
            style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
          )),
      contentPadding: const EdgeInsets.all(10),
      onTap: () {
        NavigatorUtils.goConnectSetting(context);
      },
    ));

    list.add(ListTile(
      leading: Image.asset(
        'static/images/settings_1.png',
        fit: BoxFit.cover,
      ),
      trailing: Image.asset(
        'static/images/arrow.png',
        fit: BoxFit.cover,
      ),
      title: Transform(
          transform: Matrix4.translationValues(5, 0.0, 0.0),
          child: Text(
            'Scan',
            style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
          )),
      contentPadding: const EdgeInsets.all(10),
      onTap: () async {
        var sessionId = await LocalStorage.get(Config.sessionHeaders);
        if (sessionId == null) {
          await getSession();
          if (headers.isNotEmpty) {
            NavigatorUtils.goScanandSetting(context, headers);
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) => _Dialog(context,
                    'Please Connecting Scanner', 'If you wanna use Scanner'));
          }
        } else {
          NavigatorUtils.goScanandSetting(context, jsonDecode(sessionId));
        }
      },
    ));

    list.add(ListTile(
      leading: Image.asset(
        'static/images/document.png',
        fit: BoxFit.cover,
      ),
      trailing: Image.asset(
        'static/images/arrow.png',
        fit: BoxFit.cover,
      ),
      title: Transform(
          transform: Matrix4.translationValues(15, 0.0, 0.0),
          child: Text(
            'Documents',
            style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
          )),
      contentPadding: const EdgeInsets.all(10),
      onTap: () {
        NavigatorUtils.goDocument(context, isEdited: false, token: tokenStr);
      },
    ));
    // if (PlatformCheck.isAndroid) {
    //   list.add(ListTile(
    //     leading: Image.asset(
    //       'static/images/document.png',
    //       fit: BoxFit.cover,
    //     ),
    //     trailing: Image.asset(
    //       'static/images/arrow.png',
    //       fit: BoxFit.cover,
    //     ),
    //     title: Transform(
    //         transform: Matrix4.translationValues(15, 0.0, 0.0),
    //         child: Text(
    //           'nas document',
    //           style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
    //         )),
    //     contentPadding: const EdgeInsets.all(10),
    //     onTap: () {
    //       if (isConnectNas) {
    //         NavigatorUtils.goUploadNas(context,
    //             token: tokenStr, isCanUpload: false);
    //       } else {
    //         showDialog(
    //             context: context,
    //             builder: (BuildContext context) => _Dialog(
    //                 context, 'Please Connecting Nas', 'If you wanna use nas'));
    //       }
    //     },
    //   ));
    // }

    list.add(ListTile(
      leading: Image.asset(
        'static/images/logout.png',
        fit: BoxFit.cover,
      ),
      trailing: Image.asset(
        'static/images/arrow.png',
        fit: BoxFit.cover,
      ),
      title: Transform(
          transform: Matrix4.translationValues(10, 0.0, 0.0),
          child: Text(
            'Sign out',
            style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
          )),
      contentPadding: const EdgeInsets.all(10),
      onTap: () async {
        await LocalStorage.remove(Config.sessionHeaders);
        _getStore().state.userInfo.token = '';
        NavigatorUtils.goLogin(context);
      },
    ));

    list.add(const SizedBox());

    return list;
  }
}
