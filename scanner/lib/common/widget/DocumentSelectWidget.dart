import 'package:flutter/material.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/page/DocumentPage.dart';

///
///文件filter
///Date: 2022-01-17
///
class DocumentSelectWidget extends StatefulWidget {
  ///由上一頁傳入data
  final List<CheckBoxModel> ckModelList;

  final Function filterFunc;

  final List<CheckBoxModel> callBackData;

  const DocumentSelectWidget(
      {Key? key,
      required this.ckModelList,
      required this.filterFunc,
      required this.callBackData})
      : super(key: key);

  @override
  _DocumentSelectWidgetState createState() => _DocumentSelectWidgetState();
}

class _DocumentSelectWidgetState extends State<DocumentSelectWidget>
    with BaseWidget {
  ///裝載資料
  List<CheckBoxModel> dataArray = [];
  List<CheckBoxModel> originArray = [];
  Map<String, dynamic> pickData = {};

  ///textField controller
  TextEditingController textEditingController = TextEditingController();
  FocusNode textFocus = FocusNode();

  ///filter功能
  void filterSearchResult(String str) {
    List<CheckBoxModel> dummySearchList = [];
    dummySearchList.addAll(dataArray);
    if (str.isNotEmpty) {
      List<CheckBoxModel> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.date.contains(str)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        dataArray = dummyListData;
        widget.filterFunc(dataArray);
      });
      // return;
    } else {
      setState(() {
        dataArray = widget.callBackData;
        widget.filterFunc(dataArray);
      });
    }
  }

  ///搜尋bar
  Widget searchTextField() {
    Widget widget;
    widget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onSubmitted: (value) {
          filterSearchResult(value);
        },
        controller: textEditingController,
        focusNode: textFocus,
        decoration: const InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ),
      ),
    );
    return widget;
  }

  @override
  void initState() {
    super.initState();
    dataArray = widget.ckModelList;
    originArray = widget.ckModelList;
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: searchTextField());
  }
}
