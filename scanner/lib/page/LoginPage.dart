import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/UserInfoDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/model/UserInfo.dart';
import 'package:scanner/common/net/LoginClient.dart';
import 'package:scanner/common/redux/SysState.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/CommonUtils.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/LoginInputWidget.dart';
import 'package:scanner/common/widget/TickAnimeWidget.dart';
import 'package:scanner/common/widget/dialog/UpgradeDialog.dart';
import 'package:smblib/smblib.dart';

///
///Date: 2022-01-08
///登入頁面
///
class LoginPage extends StatefulWidget {
  static const String sName = "/";
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with BaseWidget, TickerProviderStateMixin {
  // var _account = "yi@chiga.com.tw";
  // var _password = "aaaa0000";
  var _account = "";
  var _password = "";
  late GetLoginResponse _lastResponse;
  final TextEditingController accountController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final FocusNode _accNode = FocusNode();
  final FocusNode _pwNode = FocusNode();
  late UserInfo userInfo;

  bool isSuccess = false;
  bool isUpdate = false;

  _callbackSuccess() {
    UserInfoDao.getUserInfoLocal();
    NavigatorUtils.goOption(context);
  }

  ///呼叫login api
  _getLoginApi(store) async {
    FocusScope.of(context).unfocus();

    var res = await UserInfoDao.login(_account, _password, store, context);
    if (res.result) {
      if (userInfo.version.isNotEmpty) {
        if (Config.appVer != res.data['version']) {
          isSuccess = false;
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _upgradeDialog(context, res.data['downloadAppUrl']));
        } else {
          isSuccess = true;
        }
      } else {
        Config.appVer = res.data['version'];
        isSuccess = true;
      }
    } else {
      CommonUtils.showToast(context, msg: res.data['message']);
      return;
    }
  }

  initData() async {
    _account = await LocalStorage.get(Config.USER_NAME_KEY) ?? '';
    _password = await LocalStorage.get(Config.PW_KEY) ?? '';
    var userInfoData = await UserInfoDao.getUserInfoLocal();

    ///如果帳號登入成功有資料
    if (userInfoData.result) {
      ///取得nasinfo
      var nasinfo = await LocalStorage.get(Config.nasinfo);
      if (nasinfo != null) {
        Map<String, dynamic> json = jsonDecode(nasinfo);
        String hostName = json["hostName"];
        String userName = json["userName"];
        String password = json["password"];

        ///登入nas
        await Smblib.Login(hostName, userName, password);
      }
      if (mounted) {
        setState(() {
          userInfo = userInfoData.data;
          Config.appVer = userInfo.version;
        });
      }
    }
    accountController.value = TextEditingValue(text: _account);
    pwController.value = TextEditingValue(text: _password);
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    print("--- now device height : [$deviceHeight] ---");
    return StoreBuilder<SysState>(builder: (context, store) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
            top: false,
            child: Scaffold(
              //滿版的contrainer
              body: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  //背景色
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('static/images/bg.png'),
                  )),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: kToolbarHeight),
                          child: Image.asset(
                            'static/images/logo.png',
                            fit: BoxFit.fill,
                            scale: MyScreen.mainLogoScale(context),
                          ),
                        ),
                        onTap: () {
                          // this._changeTaped();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.all(10.0)),
                            LoginInputWidget(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MyScreen.loginTextFieldFontSize(context)),
                              obscureText: false,
                              hintText: '',
                              textTitle: 'Username',
                              onChanged: (String value) {
                                setState(() {
                                  _account = value;
                                });
                              },
                              controller: accountController,
                              node: _accNode,
                            ),
                            const Padding(padding: EdgeInsets.all(10.0)),
                            LoginInputWidget(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MyScreen.loginTextFieldFontSize(context)),
                              obscureText: true,
                              hintText: '',
                              textTitle: 'Password',
                              onChanged: (String value) {
                                setState(() {
                                  _password = value;
                                });
                              },
                              controller: pwController,
                              node: _pwNode,
                            ),
                            const Padding(padding: EdgeInsets.all(10.0)),
                            SizedBox(
                              width: double.infinity,
                              height: deviceHeight15(context),
                              child: GestureDetector(
                                  onTap: () async {
                                    if (_account.isEmpty && _password.isEmpty) {
                                      var acc = await LocalStorage.get(
                                          Config.USER_NAME_KEY);
                                      var pwd =
                                          await LocalStorage.get(Config.PW_KEY);
                                      if (acc != null) {
                                        await LocalStorage.remove(
                                            Config.USER_NAME_KEY);
                                      }
                                      if (pwd != null) {
                                        await LocalStorage.remove(
                                            Config.PW_KEY);
                                      }
                                      setState(() {
                                        isSuccess = true;
                                      });
                                    } else {
                                      _getLoginApi(store);
                                    }
                                  },
                                  child: Container(
                                    color: Colors.orange,
                                    child: Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        Positioned(
                                          left: deviceWidth5(context),
                                          child: !isSuccess
                                              ? Container()
                                              : TickAnimeWidget(
                                                  size: 50,
                                                  onComplete: _callbackSuccess),
                                        ),
                                        Text(
                                          'Login',
                                          style: TextStyle(
                                              fontSize: MyScreen
                                                  .loginTextFieldFontSize(
                                                      context),
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                            const Padding(padding: EdgeInsets.all(15.0)),
                            Container(
                                padding: const EdgeInsets.only(right: 20),
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '1.6.1',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize:
                                          MyScreen.defaultTableCellFontSize(
                                              context),
                                      color: Colors.black),
                                )),
                            // Expanded(child: SizedBox()),

                            const Padding(padding: EdgeInsets.all(10.0)),
                          ],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: kToolbarHeight),
                          child: Text(
                            'CHIGA technology co., ltd',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: deviceHeight < 700
                                  ? MyScreen.minFontSize(context)
                                  : MyScreen.smallFontSize(context),
                            ),
                            textAlign: TextAlign.center,
                          ))
                    ],
                  )),
                ),
              ),
            )),
      );
    });
  }

  ///upload按鈕 dialog
  Widget _upgradeDialog(BuildContext context, downloadUrl) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: UpgradeDialog(
          downloadUrl: downloadUrl,
        ),
      )),
    );
  }
}
