import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/ScannerDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/net/Address.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';

///
///連線的dialog
///Date: 2022-01-09
class ConnectDialog extends StatefulWidget {
  const ConnectDialog({Key? key}) : super(key: key);

  @override
  _ConnectDialogState createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> with BaseWidget {
  TextEditingController ipContrl = TextEditingController();
  FocusNode textFocus = FocusNode();
  var ipStr = '192.168.50.0';
  List<String> dropList = [""];
  String dropListStr = "";
  String pickStr = "";

  final Map<String, dynamic> mainData = {};

  ///呼叫API取得session
  void getSession() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap["OCPUserName"] = "user";
    var res = await ScannerDao.getSession(jsonMap);
    if (res != null && res.result) {
      print("====>${res.data}");
      await LocalStorage.save(Config.connectIP, ipStr);
      final saveDropIP = dropListStr + "," + ipStr + ",";
      await LocalStorage.save(Config.connectIP, ipStr);
      if (!dropListStr.contains(ipStr)) {
        await LocalStorage.save(Config.dropdownconnectIP, saveDropIP);
      }
      setState(() {
        mainData.addAll(res.data);
        getScannerStat();
      });
    }
  }

  ///呼叫API取得session狀態
  void getScannerStat() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};
    var res = await ScannerDao.getScannerStat(mainData);
    if (res != null && res.result) {
      print("====>${res.data}");
      Fluttertoast.showToast(msg: 'connect success');
      var device = await LocalStorage.get(Config.devices);
      setState(() {
        Navigator.pop(context);
      });
    }
  }

  initData() async {
    ///取得連線ip
    var resIP = await LocalStorage.get(Config.connectIP);

    ///取得連線過的ip
    var resDP = await LocalStorage.get(Config.dropdownconnectIP);
    if (resIP == null) {
      ipContrl.value = const TextEditingValue(text: "192.168.0.0");
    } else {
      if (resDP != null) {
        setState(() {
          if (resDP.toString().contains(",")) {
            dropListStr = resDP
                .toString()
                .substring(0, resDP.toString().lastIndexOf(","));
            var splitStr = dropListStr.split(",");
            for (var str in splitStr) {
              dropList.add(str);
            }
          }
        });
      }

      ipStr = resIP;
      ipContrl.value = TextEditingValue(text: ipStr);
      Address.domain = "http://$resIP";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Scanner connect',
                          style: TextStyle(
                              fontSize: MyScreen.smallFontSize(context),
                              color: Colors.white),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      '"Scanner IP address"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MyScreen.smallFontSize(context),
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: searchTextField()),
                        Expanded(flex: 1, child: searchDropDown()),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset('static/images/yellowBtn.png'),
                                  Text(
                                    'cancel',
                                    style: TextStyle(
                                        fontSize:
                                            MyScreen.smallFontSize(context)),
                                  )
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            )),
                        const Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset('static/images/yellowBtn.png'),
                                  Text(
                                    'connect',
                                    style: TextStyle(
                                        fontSize:
                                            MyScreen.smallFontSize(context)),
                                  )
                                ],
                              ),
                              onTap: () async {
                                if (ipStr.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: 'Please enter IP');
                                  return;
                                }
                                print('connection ip --> $ipStr');
                                getSession();
                              },
                            )),
                      ],
                    ),
                  ],
                ))));
  }

  ///搜尋bar
  Widget searchTextField() {
    Widget widget;
    widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          ipStr = value;
          Address.domain = "http://$value";
        },
        controller: ipContrl,
        focusNode: textFocus,
        decoration: const InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: '',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ),
      ),
    );
    return widget;
  }

  ///下拉選connect ip
  Widget searchDropDown() {
    Widget dropWidget;
    List<PopupMenuEntry<String>> dropItem = [];
    dropWidget = PopupMenuButton<String>(
      color: Colors.grey[400],
      child: Image.asset(
        'static/images/dropdown.png',
        scale: 1.2,
      ),
      itemBuilder: (BuildContext context) {
        return dropItem;
      },
      onSelected: (String val) {
        setState(() {
          if (val.isEmpty) {
            textFocus.requestFocus();
          }
          ipStr = val;
          ipContrl.text = val;
          Address.domain = "http://$val";
        });
      },
    );

    if (dropList.isNotEmpty) {
      for (var val in dropList) {
        dropItem.add(PopupMenuItem(
          child: Text(
            val,
            style: const TextStyle(color: Colors.black),
          ),
          value: val,
        ));
      }
    }

    return dropWidget;
  }
}
