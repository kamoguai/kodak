import 'package:flutter/material.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/dialog/ConnectDialog.dart';
import 'package:scanner/common/widget/dialog/NasConnectDialog.dart';
import 'package:scanner/common/widget/dialog/WifiDialog.dart';

///
///連線頁面
///Date: 2022-01-17
///
class ConnectSettingPage extends StatefulWidget {
  const ConnectSettingPage({Key? key}) : super(key: key);

  @override
  _ConnectSettingPageState createState() => _ConnectSettingPageState();
}

class _ConnectSettingPageState extends State<ConnectSettingPage>
    with BaseWidget {
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
                      Navigator.pop(context);
                    },
                  ))),
          Expanded(
              flex: 6,
              child: Center(
                  child: Container(
                padding: const EdgeInsets.only(bottom: 15),
                alignment: Alignment.bottomCenter,
                child: Text(
                  'connection setting',
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
            'Wifi',
            style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
          )),
      contentPadding: const EdgeInsets.all(10),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => _wifiDialog(context));
      },
    ));

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
          transform: Matrix4.translationValues(5, 0.0, 0.0),
          child: Text(
            'Scanners',
            style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
          )),
      contentPadding: const EdgeInsets.all(10),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => _connectDialog(context));
      },
    ));
    if (PlatformCheck.isAndroid) {
      list.add(ListTile(
        leading: Image.asset(
          'static/images/outside.png',
          fit: BoxFit.cover,
        ),
        trailing: Image.asset(
          'static/images/arrow.png',
          fit: BoxFit.cover,
        ),
        title: Transform(
            transform: Matrix4.translationValues(5, 0.0, 0.0),
            child: Text(
              'Output',
              style: TextStyle(fontSize: MyScreen.normalPageFontSize(context)),
            )),
        contentPadding: const EdgeInsets.all(10),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => _nasDialog(context));
        },
      ));
    }

    list.add(SizedBox(
      height: deviceHeight10(context),
    ));
    list.add(SizedBox(
      height: deviceHeight10(context),
    ));

    return list;
  }

  ///upload按鈕 dialog
  Widget _connectDialog(BuildContext contect) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: const ConnectDialog(),
      )),
    );
  }

  ///wifi dialog
  Widget _wifiDialog(BuildContext contect) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: const WifiDialog(),
      )),
    );
  }

  ///nas dialog
  Widget _nasDialog(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: const NasConnectDialog(),
      )),
    );
  }
}
