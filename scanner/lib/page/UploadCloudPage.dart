import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/UserInfoDao.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/redux/SysState.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/CommonUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';

///
///上傳雲端頁面
///Date: 2022-01-17
///
class UploadCloudPage extends StatefulWidget {
  final String? token;
  final List<String>? imagePathList;
  final List<String>? imagePathAESList;
  const UploadCloudPage(
      {Key? key, this.token, this.imagePathList, this.imagePathAESList})
      : super(key: key);

  @override
  _UploadCloudPageState createState() => _UploadCloudPageState();
}

class _UploadCloudPageState extends State<UploadCloudPage> with BaseWidget {
  RowModel rModel = RowModel();
  List<RowModel> listModel = [];

  ///紀錄所選單位
  String pickData = '';

  Future<void> _getDocTypeApi() async {
    var res = await UserInfoDao.getDocTypesList(widget.token);
    if (res.result) {
      setState(() {
        for (var dic in res.data["rows"]) {
          rModel.key = dic["key"];
          rModel.value = dic["value"];
          listModel.add(rModel);
          rModel = RowModel();
        }
      });
    }
  }

  ///file upload api
  Future<void> _filePathToByteData() async {
    showLoadingDialog(context);
    int pageCount = 0;
    List<String> imgPathList = [];
    if (widget.imagePathAESList != null &&
        widget.imagePathAESList!.isNotEmpty) {
      imgPathList.addAll(widget.imagePathAESList!);
    } else {
      imgPathList.addAll(widget.imagePathList!);
    }
    for (var path in imgPathList) {
      pageCount++;
      final bytes = File(path).readAsBytesSync();
      String base64File = base64Encode(bytes);
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var res = await UserInfoDao.uploadCloud(
          token: widget.token,
          page: '$pageCount',
          total: '${widget.imagePathList!.length}',
          uuid: timeStamp,
          base64Data: base64File,
          docId: pickData);
      if (res.result) {
        CommonUtils.showToast(context, msg: 'File upload success');
      } else {
        if (res.data['message'] != null &&
            res.data['message'].toString().isNotEmpty) {
          CommonUtils.showToast(context, msg: res.data['message']);
        } else {
          CommonUtils.showToast(context, msg: 'File upload fail ');
        }
      }
    }
    Navigator.pop(context);
  }

  initData() async {
    var res = await LocalStorage.get(Config.doctypes);
    var deJson = jsonDecode(res);
    setState(() {
      for (var dic in deJson) {
        rModel.key = dic["key"];
        rModel.value = dic["value"];
        listModel.add(rModel);
        rModel = RowModel();
      }
    });
  }

  @override
  void initState() {
    initData();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<SysState>(builder: (context, store) {
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
    });
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
                      if (mounted) Navigator.pop(context);
                    },
                  ))),
          Expanded(
              flex: 6,
              child: Center(
                  child: Container(
                padding: const EdgeInsets.only(bottom: 15),
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Cloud',
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
    w = listModel.isEmpty
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                  child: ListView.separated(
                      itemBuilder: (conext, index) {
                        return _titleItems(index)[index];
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.grey,
                          height: 2,
                        );
                      },
                      itemCount: _titleItems(-1).length)),
            ),
          ));
    return w;
  }

  ///bottomBar
  Widget _bottomBar() {
    Widget w;
    w = SizedBox(
        height: deviceHeight10(context),
        child: GestureDetector(
          onTap: () async {
            _filePathToByteData();
          },
          child: Center(
            child: Text(
              'upload',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: MyScreen.appBarFontSize(context)),
            ),
          ),
        ));
    return w;
  }

  List<Widget> _titleItems(int index) {
    List<Widget> list = [];
    for (var dic in listModel) {
      list.add(Container(
          color: pickData == dic.key ? Colors.yellow : Colors.white,
          child: ListTile(
            leading: Image.asset(
              'static/images/fileData.png',
              fit: BoxFit.cover,
            ),
            title: Transform(
                transform: Matrix4.translationValues(10, 0.0, 0.0),
                child: Text(
                  dic.value,
                  style: TextStyle(
                      fontSize: MyScreen.normalPageFontSize(context),
                      color: Colors.redAccent),
                )),
            contentPadding: const EdgeInsets.all(10),
            onTap: () async {
              setState(() {
                pickData = dic.key;
              });
            },
          )));
    }

    return list;
  }
}

class RowModel {
  late String key;
  late String value;
  RowModel();
}
