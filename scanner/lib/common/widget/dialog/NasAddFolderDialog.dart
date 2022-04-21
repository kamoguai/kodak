import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:smblib/smblib.dart';

///
///添加文件夾dialog
///Date: 2022-03-09
class NasAddFolderDialog extends StatefulWidget {
  final Function? callback;
  final String? folderPath;
  const NasAddFolderDialog({Key? key, this.callback, this.folderPath})
      : super(key: key);

  @override
  State<NasAddFolderDialog> createState() => _NasAddFolderDialogState();
}

class _NasAddFolderDialogState extends State<NasAddFolderDialog>
    with BaseWidget {
  TextEditingController fContrl = TextEditingController();
  FocusNode textFocus = FocusNode();
  String folderName = '';
  // String _fullPostPath = "smb://";
  final Map<String, dynamic> mainData = {};

  Future<void> folderAdd(String dirName) async {
    showLoadingDialog(context);
    String url = widget.folderPath! + dirName + Platform.pathSeparator;
    var res = await Smblib.AddFolder(url);
    if (res == "1") {
      widget.callback!();
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    } else {
      Fluttertoast.showToast(msg: "folder create fail");
    }
  }

  initData() async {
    // var resp = await LocalStorage.get(Config.nasinfo);
    // if (resp != null) {
    //   Map<String, dynamic> json = jsonDecode(resp);
    //   String host = json["hostName"];
    //   String user = json["userName"];
    //   String pwd = json["password"];
    //   _fullPostPath += host + Platform.pathSeparator;
    // }
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
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Add folder',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MyScreen.smallFontSize(context),
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    searchTextField(),
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
                                    'add',
                                    style: TextStyle(
                                        fontSize:
                                            MyScreen.smallFontSize(context)),
                                  )
                                ],
                              ),
                              onTap: () async {
                                await folderAdd(folderName);
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
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          folderName = value;
        },
        controller: fContrl,
        focusNode: textFocus,
        decoration: const InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: 'folder name',
          // labelStyle: TextStyle(color: Colors.),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ),
      ),
    );
    return widget;
  }
}
