import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/DaoResult.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/model/UserInfo.dart';
import 'package:redux/redux.dart';
import 'package:scanner/common/net/DocTypeClient.dart';
import 'package:scanner/common/net/LoginClient.dart';
import 'package:scanner/common/net/UploadClient.dart';
import 'package:scanner/common/redux/UserInfoRedux.dart';

///
///呼叫http api
///
class UserInfoDao {
  static login(account, password, store, context) async {
    LoginClient loginClient = LoginClient();
    Map<String, dynamic> mainDataArray = {};
    // 先儲存account至手機內存
    await LocalStorage.save(Config.USER_NAME_KEY, account);
    String serialStr = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      serialStr = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      serialStr = iosDeviceInfo.identifierForVendor;
    }
    var res = await loginClient
        .getLogin(GetLoginRequest(loginId: account, password: password));
    if (res.info.status == 'S') {
      mainDataArray['account'] = account;
      mainDataArray['password'] = password;
      mainDataArray['token'] = res.info.token;
      mainDataArray['aesIv'] = res.info.aesIv;
      mainDataArray['aesKey'] = res.info.aesKey;
      mainDataArray['downloadAppUrl'] = res.info.downloadAppUrl;
      mainDataArray['version'] = res.info.version;
      UserInfo userInfo = UserInfo.fromJson(mainDataArray);
      await LocalStorage.save(Config.PW_KEY, password);
      await LocalStorage.save(Config.USER_INFO, json.encode(userInfo.toJson()));
      store.dispatch(UpdateUserAction(userInfo));
      return DataResult(mainDataArray, true);
    } else {
      mainDataArray['message'] = res.info.message;
      return DataResult(mainDataArray, false);
    }
  }

  ///初始化用戶信息
  static initUserInfo(Store store) async {
    var res = await getUserInfoLocal();
    if (res != null && res.result) {
      store.dispatch(UpdateUserAction(res.data));
    }
    return DataResult(res.data, (res.result));
  }

  ///獲取本地登入用戶信息
  static getUserInfoLocal() async {
    var userText = await LocalStorage.get(Config.USER_INFO);
    if (userText != null) {
      var userMap = json.decode(userText);
      UserInfo user = UserInfo.fromJson(userMap);
      return DataResult(user, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///取得文件列表
  static getDocTypesList(token) async {
    DocTypeClient dtClient = DocTypeClient();
    Map<String, dynamic> mainDataArray = {};
    Map<String, dynamic> map = {};
    List<dynamic> list = [];
    var res = await dtClient.getDocType(GetDocTypeRequest(token: token));
    if (res.info.status == 'S') {
      mainDataArray['status'] = res.info.status;
      var rows = res.info.row!.subRows;
      for (var dic in rows!) {
        map["key"] = dic.key;
        map["value"] = dic.value;
        list.add(map);
        map = <String, dynamic>{};
      }
      mainDataArray['rows'] = list;
      return DataResult(mainDataArray, true);
    } else {
      return DataResult('', false);
    }
  }

  ///upload 文檔
  static uploadCloud({token, uuid, page, total, docId, base64Data}) async {
    Map<String, dynamic> mainDataArray = {};
    UploadClient uClient = UploadClient();
    var res = await uClient.getUpload(GetUploadRequest(
        timestamp: uuid,
        base64Data: base64Data,
        docId: docId,
        page: page,
        total: total,
        token: token));

    if (res.info.status == 'S') {
      return DataResult('success', true);
    } else {
      mainDataArray['message'] = res.info.message;
      return DataResult(mainDataArray, false);
    }
  }
}
