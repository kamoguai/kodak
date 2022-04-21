import 'package:flutter/cupertino.dart';
import 'package:scanner/page/ConnetSettingPage.dart';
import 'package:scanner/page/DetailFileSreenPage.dart';
import 'package:scanner/page/DocumentPage.dart';
import 'package:scanner/page/EditImagePage.dart';
import 'package:scanner/page/HomePage.dart';
import 'package:scanner/page/ImageGridViewPage.dart';
import 'package:scanner/page/ImageViewPage.dart';
import 'package:scanner/page/LoginPage.dart';
import 'package:scanner/page/OptionPage.dart';
import 'package:scanner/page/ScanPage.dart';
import 'package:scanner/page/ScanandSettingPage.dart';
import 'package:scanner/page/UploadCloudPage.dart';
import 'package:scanner/page/UploadNasPage.dart';

///
///導航欄
///Date: 2019-06-04
///
class NavigatorUtils {
  ///替換
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切換無參數頁面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///首頁
  ///pushReplacementNamed需要由main.dart做導航
  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, HomePage.sName);
  }

  ///option頁
  ///pushReplacementNamed需要由main.dart做導航
  static goOption(BuildContext context) {
    Navigator.pushReplacementNamed(context, OptionPage.sName);
  }

  ///一般跳轉頁面
  // ignore: non_constant_identifier_names
  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(
        context, CupertinoPageRoute(builder: (context) => widget));
  }

  ///跳轉至頁面並移除上一頁
  // static NavigatorRemoveRouter(BuildContext context, Widget widget) {
  //   Navigator.pushAndRemoveUntil(
  //       context,  CupertinoPageRoute(builder: (context) => widget), false);
  // }

  ///登入頁
  static goLogin(BuildContext context, {isAutoLogin}) {
    Navigator.pushNamed(context, LoginPage.sName);
  }

  ///scan頁面
  static goScan(BuildContext context, sessionID, connectIP, deviceHostName) {
    NavigatorRouter(
        context,
        ScanPage(
          sessionID: sessionID,
          connectIP: connectIP,
          deviceHostName: deviceHostName,
        ));
  }

  ///image頁面
  static goImageView(BuildContext context, filePath) {
    NavigatorRouter(context, ImageViewPage(filePath: filePath));
  }

  ///連線設定頁面
  static goConnectSetting(BuildContext context) {
    NavigatorRouter(context, const ConnectSettingPage());
  }

  ///文件頁面
  static goDocument(BuildContext context, {isEdited, token}) {
    NavigatorRouter(
        context,
        DocumentPage(
          isEdited: isEdited,
          token: token,
        ));
  }

  ///文件上傳頁面
  static goUploadCloud(BuildContext context,
      {token, imagePathList, imagePathAESList}) {
    NavigatorRouter(
        context,
        UploadCloudPage(
          token: token,
          imagePathList: imagePathList,
          imagePathAESList: imagePathAESList,
        ));
  }

  ///nas上傳頁面
  static goUploadNas(BuildContext context,
      {token, imagePathList, isCanUpload}) {
    NavigatorRouter(
        context,
        UploadNasPage(
          token: token,
          imagePathList: imagePathList,
          isCanUpload: isCanUpload,
        ));
  }

  ///掃描&設定頁面
  static goScanandSetting(BuildContext context, sessionId) {
    NavigatorRouter(
        context,
        ScanandSettingPage(
          sessionID: sessionId,
        ));
  }

  ///imageGrid頁面
  static goImageGridView(BuildContext context, filePath, isEdited, token) {
    NavigatorRouter(
        context,
        ImageGridViewPage(
          filePath: filePath,
          isEdited: isEdited,
          token: token,
        ));
  }

  ///DetailFile頁面
  static goDetailFileSreen(BuildContext context,
      {filePath, tag, token, filePathList, modelList, aesPath}) {
    NavigatorRouter(
        context,
        DetailFileScreenPage(
          url: filePath,
          tag: tag,
          token: token,
          urlList: filePathList,
          ckModelList: modelList,
          aesUrl: aesPath,
        ));
  }

  ///DetailFile頁面
  static goEditImage(BuildContext context, filePath, tag, token, aesPath) {
    NavigatorRouter(
        context,
        EditImagePage(
          url: filePath,
          tag: tag,
          token: token,
          aesUrl: aesPath,
        ));
  }
}
