import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanner/common/event/HttpErrorEvent.dart';
import 'package:scanner/common/net/Code.dart';
import 'package:scanner/common/redux/SysState.dart';
import 'package:scanner/page/HomePage.dart';
import 'package:scanner/page/LoginPage.dart';
import 'package:redux/redux.dart';
import 'package:scanner/page/OptionPage.dart';
import 'package:scanner/page/SMBPage.dart';
import 'common/delegate/FallbackCupertinoLocalisationsDelegate.dart';
import 'common/model/UserInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  ///創建Store，引用 SysState中的appReducer 實現 Reducer 方法
  ///initialState 初始化 State
  final store = Store<SysState>(appReducer,

      ///初始化數據
      initialState: SysState(
        userInfo: UserInfo.empty(),
      ));

  @override
  Widget build(BuildContext context) {
    ///設定手機畫面固定直立上方
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return StoreProvider(
        store: store,
        child: StoreBuilder<SysState>(builder: (context, store) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: {
              LoginPage.sName: (context) {
                //登入
                return const MyHomePage(
                  child: LoginPage(),
                );
              },
              // SMBPage.sName: (context) {
              //   //登入
              //   return const MyHomePage(
              //     child: SMBPage(),
              //   );
              // },
              HomePage.sName: (context) {
                //首頁
                return const MyHomePage(
                  child: HomePage(),
                );
              },
              OptionPage.sName: (context) {
                //首頁
                return const MyHomePage(
                  child: OptionPage(),
                );
              }
            },
            builder: (context, widget) {
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget!);
            },
          );
        }));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription stream;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return StoreBuilder<SysState>(
      builder: (context, store) {
        return Localizations.override(
          context: context,
          child: widget.child,
          delegates: const [
            FallbackCupertinoLocalisationsDelegate(),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    stream = Code.eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    stream.cancel();
  }

  errorHandleFunction(int code, message) {
    switch (code) {
      case Code.network_error:
        Fluttertoast.showToast(msg: '網路錯誤');
        break;
      case 401:
        Fluttertoast.showToast(msg: '[401錯誤可能: 未授權 \\ 授權登入失敗 \\ 登入過期]');
        break;
      case 403:
        Fluttertoast.showToast(msg: '403權限錯誤');
        break;
      case 404:
        Fluttertoast.showToast(msg: '404錯誤');
        break;
      case Code.network_timeout:
        //超时
        Fluttertoast.showToast(msg: '請求超時');
        break;
      default:
        if (message.toString().contains('Socket')) {
          Fluttertoast.showToast(msg: '網路請求異常，請更換網路試試。' + " " + message);
        } else {
          Fluttertoast.showToast(msg: '請求異常' + " " + message);
        }

        break;
    }
  }
}
