import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 基本widget，供重複使用的widget
/// Date: 2019-05-09
mixin BaseWidget {
  ///是否讀取中
  var isLoading = false;

  ///讀取用dialog
  showLoadingDialog(BuildContext context) {
    Widget dialog;

    dialog = Material(
      type: MaterialType.transparency,
      child: Center(
          child: Container(
        width: 250.0,
        height: 250.0,
        padding: const EdgeInsets.all(4.0),
        decoration: const BoxDecoration(
          color: Colors.black45,
          //用一个BoxDecoration装饰器提供背景图片
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: SpinKitCubeGrid(color: Colors.white)),
            Container(height: 10.0),
            Container(
                child: Text('Loading..',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MyScreen.defaultTableCellFontSize(context)))),
          ],
        ),
      )),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  ///讀取結束用
  hidenLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  ///anime loding
  showLoadingAnime(BuildContext context) {
    return Center(
        child: Container(
      width: deviceWidth3(context) * 1.2,
      height: deviceWidth3(context) * 1.2,
      padding: const EdgeInsets.all(4.0),
      decoration: const BoxDecoration(
        color: Colors.black45,
        //用一个BoxDecoration装饰器提供背景图片
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SpinKitCubeGrid(color: Colors.white),
          Container(height: 10.0),
          Text('Loading..',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: MyScreen.defaultTableCellFontSize(context))),
        ],
      ),
    ));
  }

  ///anime loding blue
  showLoadingAnimeB(BuildContext context) {
    return Center(
        child: Container(
      width: 250.0,
      height: 250.0,
      padding: const EdgeInsets.all(4.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        //用一个BoxDecoration装饰器提供背景图片
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitCubeGrid(color: Colors.blue[200]),
          Container(height: 10.0),
          Text('Loading..',
              style: TextStyle(
                  color: Colors.black, fontSize: ScreenUtil().setSp(20.0))),
        ],
      ),
    ));
  }

  ///分隔線
  buildLine() {
    return Container(
      height: 1.0,
      color: Colors.grey,
    );
  }

  ///分隔線-紅
  buildRedLine() {
    return Container(
      height: 1.0,
      color: Colors.red,
    );
  }

  ///高分隔線
  buildLineHeight(BuildContext context) {
    return Container(
      height: titleHeight(context),
      width: 1.0,
      color: Colors.grey,
    );
  }

  ///高分隔線-red
  buildLineHeightRed(BuildContext context) {
    return Container(
      height: titleHeight(context),
      width: 1.0,
      color: Colors.red,
    );
  }

  ///高分隔線
  buildRedLineHeight(BuildContext context) {
    return Container(
      height: titleHeight(context),
      width: 1.0,
      color: Colors.red,
    );
  }

  ///51高分隔線
  buildHeightLine51() {
    return Container(
      height: 51.0,
      width: 1.0,
      color: Colors.grey,
    );
  }

  ///取得裝置width並切1.5份
  deviceWidth1_5(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 1.5;
  }

  ///取得裝置width並切2份
  deviceWidth2(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 2;
  }

  ///取得裝置width並切3份
  deviceWidth3(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 3;
  }

  ///取得裝置width並切4份
  deviceWidth4(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 4;
  }

  ///取得裝置width並切5份
  deviceWidth5(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 5;
  }

  ///取得裝置width並切6份
  deviceWidth6(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 6;
  }

  ///取得裝置width並切7份
  deviceWidth7(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 7;
  }

  ///取得裝置width並切8份
  deviceWidth8(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 8;
  }

  ///取得裝置width並切9份
  deviceWidth9(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 9;
  }

  ///取得裝置width並切10份
  deviceWidth10(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width / 10;
  }

  ///取得裝置width並切9 * 2 + 9 * 0.5 份
  deviceWidth92(context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    var width9 = deviceWidth / 9;
    return (width9 * 2) + (width9 * 0.5);
  }

  ///取得裝置height切2分
  deviceHeight2(BuildContext context) {
    AppBar appBar = AppBar();
    var appBarHeight = appBar.preferredSize.height;
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight - appBarHeight;

    return height / 2;
  }

  ///取得裝置height切3分
  deviceHeight3(BuildContext context) {
    AppBar appBar = AppBar();
    var appBarHeight = appBar.preferredSize.height;
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight - appBarHeight;

    return height / 3;
  }

  ///取得裝置height切4分
  deviceHeight4(BuildContext context) {
    AppBar appBar = AppBar();
    var appBarHeight = appBar.preferredSize.height;
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight - appBarHeight;

    return height / 4;
  }

  ///取得裝置height切4分
  deviceHeight6(BuildContext context) {
    AppBar appBar = AppBar();
    var appBarHeight = appBar.preferredSize.height;
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight - appBarHeight;

    return height / 6;
  }

  ///取得裝置height切15分
  deviceHeight15(BuildContext context) {
    AppBar appBar = AppBar();
    var appBarHeight = appBar.preferredSize.height;
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight - appBarHeight;

    return height / 15;
  }

  ///取得裝置height切7分
  deviceHeight7(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight;

    return height / 7;
  }

  ///取得裝置height切8分
  deviceHeight8(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight;

    return height / 8;
  }

  ///取得裝置height切10分
  deviceHeight10(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var height = deviceHeight;

    return height / 10;
  }

  ///lsit height
  listHeight(BuildContext context) {
    var height = deviceHeight4(context);
    return height / 5;
  }

  ///title height
  titleHeight(BuildContext context) {
    var height = deviceHeight4(context);
    return height / 4;
  }

  ///自動縮放-中
  // autoTextSize(text, style, context) {
  //   var fontSize = MyScreen.defaultTableCellFontSize(context);
  //   var fontStyle = TextStyle(fontSize: fontSize);
  //   return AutoSizeText(
  //     text,
  //     style: style.merge(fontStyle),
  //     minFontSize: 5.0,
  //     textAlign: TextAlign.center,
  //   );
  // }

  ///自動縮放-左
  // autoTextSizeLeft(text, style, context) {
  //   var fontSize = MyScreen.defaultTableCellFontSize(context);
  //   var fontStyle = TextStyle(fontSize: fontSize);
  //   return AutoSizeText(
  //     text,
  //     style: style.merge(fontStyle),
  //     minFontSize: 5.0,
  //     textAlign: TextAlign.left,
  //   );
  // }
}
