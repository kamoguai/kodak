import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/MyFlexButton.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

///
///通用邏輯
///Date: 2019-03-11
///
class CommonUtils {
  static final double MILLIS_LIMIT = 1000.0;

  static final double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

  static final double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

  static final double HOURS_LIMIT = 24 * MILLIS_LIMIT;

  static final double DAYS_LIMIT = 30 * MILLIS_LIMIT;

  static double sStaticBarHeight = 0.0;

  static void initStatusBarHeight(context) async {
    final double _statusBarHeight = MediaQuery.of(context).padding.top;
    sStaticBarHeight = _statusBarHeight;
  }

  ///取到yyyy-MM-dd hh:mm
  static String getDateMinStr(DateTime date) {
    if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 16);
  }

  ///取到yyyy-MM-dd hh:mm:ss
  static String getDateSecStr(DateTime date) {
    if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 19);
  }

  ///日期格式轉換
  static String getNewsTimeStr(DateTime date) {
    int subTime =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    if (subTime < MILLIS_LIMIT) {
      return "剛剛";
    } else if (subTime < SECONDS_LIMIT) {
      return (subTime / MILLIS_LIMIT).round().toString() + " 秒前";
    } else if (subTime < MINUTES_LIMIT) {
      return (subTime / SECONDS_LIMIT).round().toString() + " 分鐘前";
    } else if (subTime < HOURS_LIMIT) {
      return (subTime / MINUTES_LIMIT).round().toString() + " 小時前";
    } else if (subTime < DAYS_LIMIT) {
      return (subTime / HOURS_LIMIT).round().toString() + " 天前";
    } else {
      return getDateMinStr(date);
    }
  }

  static splitFileNameByPath(String path) {
    return path.substring(path.lastIndexOf("/"));
  }

  ///flutter toast自定義
  static showToast(context, {String? msg, String? align}) {
    if (align == null) {
      Fluttertoast.showToast(
          msg: msg ?? '',
          fontSize: MyScreen.homePageFontSize(context),
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          backgroundColor: Colors.black);
    } else {
      Fluttertoast.showToast(
          msg: msg ?? '',
          fontSize: MyScreen.homePageFontSize(context),
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          gravity: ToastGravity.CENTER);
    }
  }

  ///版本更新
  static Future<void> showUpdateAppDialog(
      BuildContext context, String contentMsg, String updateUrl) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'version upgrade',
              style: TextStyle(fontSize: MyScreen.appBarFontSize(context)),
            ),
            content: Text(
              contentMsg,
              style: TextStyle(
                  fontSize: MyScreen.defaultTableCellFontSize(context)),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    launch(updateUrl);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'OK',
                    style:
                        TextStyle(fontSize: MyScreen.appBarFontSize(context)),
                  )),
            ],
          );
        });
  }

  ///更新為不能使的app
  static Future<void> showDummuAppDialog(
      BuildContext context, String contentMsg, String updateUrl) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '版本更新',
              style: TextStyle(fontSize: MyScreen.appBarFontSize(context)),
            ),
            content: Text(contentMsg),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style:
                        TextStyle(fontSize: MyScreen.appBarFontSize(context)),
                  )),
              TextButton(
                  onPressed: () {
                    launch(updateUrl);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '確定',
                    style:
                        TextStyle(fontSize: MyScreen.appBarFontSize(context)),
                  )),
            ],
          );
        });
  }
}
