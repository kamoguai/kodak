import 'package:flutter/material.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/ScannerDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/dialog/ConnectDialog.dart';
import 'package:scanner/common/widget/dialog/WifiDialog.dart';
import 'package:share_plus/share_plus.dart';

///
///首頁tab功能頁
///Date: 2022-01-09
class FunctionPage extends StatefulWidget {
  final String? deviceHostName;
  const FunctionPage({Key? key, this.deviceHostName}) : super(key: key);

  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage>
    with AutomaticKeepAliveClientMixin<FunctionPage>, BaseWidget {
  final Map<String, dynamic> mainData = {};
  String deviceName = "";

  ///connect按鈕 dialog
  Widget _connectDialog(BuildContext contect) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight4(context),
            horizontal: deviceWidth10(context)),
        child: const ConnectDialog(),
      ),
    );
  }

  ///呼叫API取得session
  void getSession() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap["OCPUserName"] = "user";
    var res = await ScannerDao.getSession(jsonMap);
    if (res != null && res.result) {
      print("====>${res.data}");
      setState(() {
        mainData.addAll(res.data);
      });
    }
  }

  ///取得session狀態API
  getSessionStat(headersData) async {
    bool isConnect = false;
    var res = await ScannerDao.getSessionStat(headersData);
    if (res == null) {
      isConnect = false;
    } else {
      isConnect = true;
    }

    return isConnect;
  }

  toConnectPage() async {
    var session = await LocalStorage.get(Config.sessionHeaders);
    if (session != null) {
      var sessionStr = session
          .replaceAll("{", "")
          .replaceAll("}", "")
          .replaceAll("SessionId: ", "");
      Map<String, String> headersData = {};
      headersData["SessionId"] = sessionStr;
      showLoadingDialog(context);
      bool isConn = await getSessionStat(headersData);
      if (isConn) {
        Navigator.pop(context);
        var ipStr = await LocalStorage.get(Config.connectIP);
        var device = await LocalStorage.get(Config.devices);
        setState(() {
          deviceName = device;
        });
        NavigatorUtils.goScan(context, headersData['SessionId'], ipStr, device);
      } else {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (BuildContext context) => _connectDialog(context));
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => _connectDialog(context));
    }
  }

  ///執行share
  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share('text',
        subject: 'test',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(MyColors.hexFromStr('#a5d4f5')),
      child: GridView.count(crossAxisCount: 2, children: [
        Container(
            color: Color(MyColors.hexFromStr('#a5d4f5')),
            child: GestureDetector(
              child: Column(
                children: [
                  Image(
                    width: deviceWidth3(context),
                    height: deviceHeight6(context),
                    image: const AssetImage('static/images/scan.png'),
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    deviceName.isEmpty == true ? '' : deviceName,
                    style: TextStyle(
                        fontSize: MyScreen.normalPageFontSize(context)),
                  )
                ],
              ),
              onTap: () {},
            )),
        Container(
            color: Color(MyColors.hexFromStr('#a5d4f5')),
            child: GestureDetector(
              child: Container(),
              onTap: () {},
            )),
        Container(
            color: Color(MyColors.hexFromStr('#a5d4f5')),
            child: GestureDetector(
              child: Column(
                children: [
                  Image(
                    width: deviceWidth3(context),
                    height: deviceHeight6(context),
                    image: const AssetImage('static/images/wifi.png'),
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'WiFi Scanner',
                    style: TextStyle(
                        fontSize: MyScreen.normalPageFontSize(context)),
                  )
                ],
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => const WifiDialog());
              },
            )),
        Container(
            color: Color(MyColors.hexFromStr('#a5d4f5')),
            child: GestureDetector(
              child: Column(
                children: [
                  Image(
                    width: deviceWidth3(context),
                    height: deviceHeight6(context),
                    image: const AssetImage('static/images/connect.png'),
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Scanner IP Connect',
                    style: TextStyle(
                        fontSize: MyScreen.normalPageFontSize(context)),
                  )
                ],
              ),
              onTap: () async {
                toConnectPage();
              },
            ))
      ]),
    );
  }
}
