import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:developer' as developer;

///
///wifi功能的dialog
///Date: 2022-01-09
///
///
class WifiDialog extends StatefulWidget {
  const WifiDialog({Key? key}) : super(key: key);

  @override
  _WifiDialogState createState() => _WifiDialogState();
}

class _WifiDialogState extends State<WifiDialog> with BaseWidget {
  static const swiftChannel = MethodChannel('wifiSwift');
  final TextEditingController _pwdContrl = TextEditingController();
  FocusNode textFocus = FocusNode();
  final List<String> wifiList = [];
  String pickStr = "";
  String pwdStr = "";
  String ipStr = "";
  bool isPickOnchange = false;
  String _connectionStatus = 'Unknown';
  String? wifiName,
      wifiBSSID,
      wifiIPv4,
      wifiIPv6,
      wifiGatewayIP,
      wifiBroadcast,
      wifiSubmask;
  final NetworkInfo _networkInfo = NetworkInfo();

  Future getSwiftWifiInfo() async {
    await swiftChannel.invokeListMethod('getSwiftWifiInfo');
  }

  init() async {
    final ssid = await WiFiForIoTPlugin.getSSID();
    final sIP = await WiFiForIoTPlugin.getIP();
    if (Platform.isAndroid) {
      final wifis = await WiFiForIoTPlugin.loadWifiList();
      setState(() {
        pickStr = ssid ?? '';
        ipStr = sIP ?? '';
        var list = wifis.map((e) => e.ssid!).toList();
        wifiList.addAll(list);
      });
    } else {
      setState(() {
        ipStr = sIP ?? '';
      });
    }
  }

  ///輸入匡
  Widget editText() {
    Widget widget;
    widget = TextField(
      controller: _pwdContrl,
      decoration: const InputDecoration(hintText: "enter wifi password"),
      onChanged: (val) {
        setState(() {
          pwdStr = val;
        });
      },
    );
    return widget;
  }

  ///搜尋bar
  Widget searchDropDown() {
    Widget widget;
    widget = FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                iconColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: pickStr,
                  isDense: true,
                  items: wifiList.map((String val) {
                    return DropdownMenuItem(
                      child: Text(
                        val,
                      ),
                      value: val,
                    );
                  }).toList(),
                  onChanged: (String? newVal) {
                    setState(() {
                      pickStr = newVal!;
                      isPickOnchange = true;
                    });
                  }),
            ));
      },
    );
    return widget;
  }

  Widget getBtnforAndroid() {
    Widget w;
    w = Row(
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
                        fontSize: MyScreen.defaultTableCellFontSize(context)),
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
                          fontSize: MyScreen.defaultTableCellFontSize(context)),
                    )
                  ],
                ),
                onTap: () async {
                  if (wifiList.isNotEmpty) {
                    final res = await WiFiForIoTPlugin.connect(pickStr,
                        password: pwdStr,
                        security: NetworkSecurity.WPA,
                        joinOnce: true,
                        withInternet: false);
                    if (!res) {
                      Fluttertoast.showToast(msg: '請輸入正確密碼');
                    } else {
                      Navigator.pop(context);
                    }
                  }
                })),
      ],
    );
    return w;
  }

  Widget getBtnConfirm() {
    Widget w;
    w = Row(
      children: [
        Expanded(
            child: GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('static/images/yellowBtn.png'),
              Text(
                'ok',
                style: TextStyle(fontSize: MyScreen.smallFontSize(context)),
              )
            ],
          ),
          onTap: () {
            Navigator.pop(context);
          },
        )),
      ],
    );
    return w;
  }

  ///搜尋bar
  Widget searchTextFieldAndroid() {
    Widget widget;
    widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          ipStr = value;
        },
        controller: _pwdContrl,
        focusNode: textFocus,
        decoration: const InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'password',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ),
      ),
    );
    return widget;
  }

  ///搜尋bar
  Widget searchTextFieldIOS() {
    Widget widget;
    widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        readOnly: true,
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          ipStr = value;
        },
        controller: _pwdContrl,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initNetworkInfo();
    init();
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
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    wifiBSSID == null
                        ? const SizedBox()
                        : Container(
                            alignment: Alignment.center,
                            child: Text(
                              'wifi scanners',
                              style: TextStyle(
                                  fontSize: MyScreen.smallFontSize(context),
                                  color: Colors.white),
                            )),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      wifiBSSID == null
                          ? 'If you wanna use scanner, please setting and connect wifi'
                          : 'scanners will apper in the list of wifi type something here... ',
                      style: TextStyle(
                          fontSize: MyScreen.smallFontSize(context),
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    wifiBSSID == null
                        ? const SizedBox()
                        : Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'SSID : $pickStr',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: MyScreen.smallFontSize(context),
                                  color: Colors.white),
                            )),
                    const SizedBox(
                      height: 10,
                    ),
                    wifiBSSID == null
                        ? const SizedBox()
                        : Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'IP : $ipStr',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: MyScreen.smallFontSize(context),
                                  color: Colors.white),
                            )),
                    const SizedBox(
                      height: 20,
                    ),
                    getBtnConfirm(),
                  ],
                ))));
  }

  Future<void> _initNetworkInfo() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      wifiIPv6 = await _networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      wifiBroadcast = await _networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask', error: e);
      wifiSubmask = 'Failed to get Wifi submask';
    }

    setState(() {
      _connectionStatus = 'Wifi Name: $wifiName\n'
          'Wifi BSSID: $wifiBSSID\n'
          'Wifi IPv4: $wifiIPv4\n'
          'Wifi IPv6: $wifiIPv6\n'
          'Wifi Broadcast: $wifiBroadcast\n'
          'Wifi Gateway: $wifiGatewayIP\n'
          'Wifi Submask: $wifiSubmask\n';
      print(_connectionStatus);
      pickStr = wifiName!;
    });
  }
}
