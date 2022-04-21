import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/MyInputWidget.dart';
import 'package:smblib/smblib.dart';

///
///Nas 連線
///Date: 2022-03-03
///
class NasConnectDialog extends StatefulWidget {
  const NasConnectDialog({Key? key}) : super(key: key);

  @override
  State<NasConnectDialog> createState() => _NasConnectDialogState();
}

class _NasConnectDialogState extends State<NasConnectDialog> with BaseWidget {
  final TextEditingController _hostCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  String dialogType = "init";

  void _login() async {
    String hostName = _hostCtrl.text;
    String userName = _usernameCtrl.text;
    String password = _passwordCtrl.text;
    var res = await Smblib.Login(hostName, userName, password);
    if (res == "ok") {
      Map<String, dynamic> json = {};
      json["hostName"] = hostName;
      json["userName"] = userName;
      json["password"] = password;
      await LocalStorage.save("nasinfo", jsonEncode(json));
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "$res");
    }
  }

  initData() async {
    var nasinfo = await LocalStorage.get(Config.nasinfo);
    if (nasinfo != null) {
      Map<String, dynamic> json = jsonDecode(nasinfo);
      _hostCtrl.value = TextEditingValue(text: json["hostName"]);
      _usernameCtrl.value = TextEditingValue(text: json["userName"]);
      _passwordCtrl.value = TextEditingValue(text: json["password"]);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameCtrl.dispose();
    _hostCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('static/images/bg.png'),
                    fit: BoxFit.fill)),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: selectorConnectDialog()))));
  }

  /// nas連線
  List<Widget> netConnectDialog() {
    List<Widget> list = [
      Container(
          alignment: Alignment.center,
          child: Text(
            'Network Shared Folder',
            style: TextStyle(
                fontSize: MyScreen.smallFontSize(context), color: Colors.white),
          )),
      const SizedBox(
        height: 20,
      ),
      Text(
        '"Please enter IP and ID & Password"',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: MyScreen.smallFontSize(context), color: Colors.white),
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              'IP : ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MyScreen.normalPageFontSize(context),
                  color: Colors.white),
            ),
          ),
          Flexible(
            flex: 4,
            child: ConnetInputWidget(
              hintText: '',
              lableText: '',
              textTitle: '',
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: MyScreen.smallFontSize(context)),
              textAlign: TextAlign.center,
              controller: _hostCtrl,
              obscureText: false,
              onChanged: (String val) {},
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              'ID : ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MyScreen.normalPageFontSize(context),
                  color: Colors.white),
            ),
          ),
          Flexible(
            flex: 4,
            child: ConnetInputWidget(
              hintText: '',
              textTitle: '',
              lableText: '',
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: MyScreen.smallFontSize(context)),
              textAlign: TextAlign.center,
              controller: _usernameCtrl,
              onChanged: (String val) {},
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              'Pwd: ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MyScreen.minFontSize(context), color: Colors.white),
            ),
          ),
          Flexible(
            flex: 4,
            child: ConnetInputWidget(
              hintText: '',
              textTitle: '',
              lableText: '',
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: MyScreen.smallFontSize(context)),
              textAlign: TextAlign.center,
              controller: _passwordCtrl,
              onChanged: (String val) {},
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              flex: 2,
              child: GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('static/images/yellowBtn.png'),
                    Text(
                      'cancel',
                      style:
                          TextStyle(fontSize: MyScreen.smallFontSize(context)),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
          const Flexible(
              flex: 1,
              child: SizedBox(
                width: 20,
              )),
          Flexible(
              flex: 2,
              child: GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('static/images/yellowBtn.png'),
                    Text(
                      'connect',
                      style:
                          TextStyle(fontSize: MyScreen.smallFontSize(context)),
                    )
                  ],
                ),
                onTap: () async {
                  _login();
                },
              )),
        ],
      ),
    ];

    return list;
  }

  /// ad連線，username需前綴domain
  List<Widget> adConnectDialog() {
    List<Widget> list = [
      Container(
          alignment: Alignment.center,
          child: Text(
            'Active Directory',
            style: TextStyle(
                fontSize: MyScreen.smallFontSize(context), color: Colors.white),
          )),
      const SizedBox(
        height: 20,
      ),
      Text(
        '"Please enter IP and ID & Password"',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: MyScreen.smallFontSize(context), color: Colors.white),
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              'IP : ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MyScreen.normalPageFontSize(context),
                  color: Colors.white),
            ),
          ),
          Flexible(
            flex: 4,
            child: ConnetInputWidget(
              hintText: '',
              lableText: '',
              textTitle: '',
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: MyScreen.smallFontSize(context)),
              textAlign: TextAlign.center,
              controller: _hostCtrl,
              obscureText: false,
              onChanged: (String val) {},
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              'ID : ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MyScreen.normalPageFontSize(context),
                  color: Colors.white),
            ),
          ),
          Flexible(
            flex: 4,
            child: ConnetInputWidget(
              hintText: '',
              textTitle: '',
              lableText: '',
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: MyScreen.smallFontSize(context)),
              textAlign: TextAlign.center,
              controller: _usernameCtrl,
              onChanged: (String val) {},
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              'Pwd: ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MyScreen.minFontSize(context), color: Colors.white),
            ),
          ),
          Flexible(
            flex: 4,
            child: ConnetInputWidget(
              hintText: '',
              textTitle: '',
              lableText: '',
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: MyScreen.smallFontSize(context)),
              textAlign: TextAlign.center,
              controller: _passwordCtrl,
              onChanged: (String val) {},
            ),
          )
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              flex: 2,
              child: GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('static/images/yellowBtn.png'),
                    Text(
                      'cancel',
                      style:
                          TextStyle(fontSize: MyScreen.smallFontSize(context)),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
          const Flexible(
              flex: 1,
              child: SizedBox(
                width: 20,
              )),
          Flexible(
              flex: 2,
              child: GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('static/images/yellowBtn.png'),
                    Text(
                      'connect',
                      style:
                          TextStyle(fontSize: MyScreen.smallFontSize(context)),
                    )
                  ],
                ),
                onTap: () async {
                  if (!_usernameCtrl.text.contains("\\")) {
                    Fluttertoast.showToast(
                        msg: 'please enter active directory domain');
                    return;
                  }
                  _login();
                },
              )),
        ],
      ),
    ];

    return list;
  }

  /// 下拉選單選要用ad還是nas
  List<Widget> selectorConnectDialog() {
    List<Widget> list = [];
    if (dialogType == "init") {
      list = [
        Container(
            alignment: Alignment.center,
            child: Text(
              'Output',
              style: TextStyle(
                  fontSize: MyScreen.smallFontSize(context),
                  color: Colors.white),
            )),
        const SizedBox(
          height: 30,
        ),
        Text(
          '"AD or NAS Connect"',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: MyScreen.smallFontSize(context), color: Colors.white),
        ),
        const SizedBox(
          height: 20,
        ),
        GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'static/images/yellowBtn.png',
              ),
              Text(
                'Active Directory',
                style: TextStyle(fontSize: MyScreen.smallFontSize(context)),
              )
            ],
          ),
          onTap: () async {
            setState(() {
              dialogType = "ad";
            });
          },
        ),
        const SizedBox(
          height: 20,
        ),
        GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'static/images/yellowBtn.png',
              ),
              Text(
                'Network Shared Folder',
                style: TextStyle(fontSize: MyScreen.smallFontSize(context)),
              )
            ],
          ),
          onTap: () async {
            setState(() {
              dialogType = "net";
            });
          },
        ),
        const SizedBox(
          height: 30,
        ),
        GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'static/images/yellowBtn.png',
              ),
              Text(
                'cancel',
                style: TextStyle(fontSize: MyScreen.smallFontSize(context)),
              )
            ],
          ),
          onTap: () async {
            Navigator.pop(context);
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ];
    } else if (dialogType == "ad") {
      list = adConnectDialog();
    } else if (dialogType == "net") {
      list = netConnectDialog();
    }

    return list;
  }
}
