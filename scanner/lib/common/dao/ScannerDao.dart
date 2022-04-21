import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/dao/DaoResult.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/net/Address.dart';
import 'package:scanner/common/net/Api.dart';

///
///呼叫掃描機api
///
class ScannerDao {
  ///取得設備session
  static getSession(Map<String, dynamic> jsonMap) async {
    Map<String, dynamic> mainDataArray = {};

    ///map轉json
    String str = json.encode(jsonMap);
    if (Config.DEBUG) {
      print("getSession req => " + str);
    }

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, String> headerMap = {};
    var res = await HttpManager.netFetch(
        Address.getSession(), str, headerMap, Options(method: "post"));
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("getSession resp => " + res.data.toString());
      }
      mainDataArray = res.data;
      await LocalStorage.save(Config.sessionHeaders, jsonEncode(res.data));
      return DataResult(mainDataArray, true);
    }
  }

  ///取得設備session狀態
  static getSessionStat(Map<String, dynamic> header) async {
    Map<String, dynamic> mainDataArray = {};

    Map<String, dynamic> headerMap = {};
    headerMap.addAll(header);
    var res = await HttpManager.netFetch(
        Address.getSession(), null, headerMap, Options(method: "get"));
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("sessionID resp => " + res.data.toString());
      }
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }

  ///取得設備config
  static getConfig() async {
    Map<String, dynamic> mainDataArray = {};

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, String> headerMap = {};
    List<dynamic> dataArray = [];
    var res = await HttpManager.netFetch(
        Address.getConfig(), null, headerMap, Options(method: "get"));
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("getConfig resp => " + res.data.toString());
      }
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }

  ///取得設備下拉選單
  static getCapabilities() async {
    Map<String, dynamic> mainDataArray = {};

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, String> headerMap = {};
    List<dynamic> dataArray = [];
    var res = await HttpManager.netFetch(
        Address.getCapabilities(), null, headerMap, Options(method: "get"));
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("getCapabilities resp => " + res.data.toString());
      }
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }

  ///取得設備狀態
  static getScannerStat(Map<String, dynamic> header) async {
    Map<String, dynamic> mainDataArray = {};

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, String> headerMap = {};
    List<dynamic> dataArray = [];
    var res = await HttpManager.netFetch(
        Address.getConfig(), null, headerMap, Options(method: "get"));
    if (res != null && res.result) {
      mainDataArray = res.data;
      if (Config.DEBUG) {
        print("getConfig resp => " + mainDataArray["SystemStatus"]["HostName"]);
      }
      await LocalStorage.save(
          Config.devices, mainDataArray["SystemStatus"]["HostName"]);
      return DataResult(mainDataArray, true);
    }
  }

  ///update config
  static updateConfig(
      Map<String, dynamic> header, Map<String, dynamic> body) async {
    Map<String, dynamic> mainDataArray = {};

    ///map轉json
    String str = json.encode(body);

    print("getSession req => " + str);

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, dynamic> headerMap = {};
    headerMap.addAll(header);
    var res = await HttpManager.netFetch(
        Address.getSession(), str, headerMap, Options(method: "put"));
    if (res != null && res.result) {
      await LocalStorage.save(Config.scannerConfig, str);
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }

  /// start scan
  /// 傳入header
  static startScan(Map<String, dynamic> header) async {
    Map<String, dynamic> mainDataArray = {};

    Map<String, dynamic> headerMap = {};
    headerMap.addAll(header);
    var res = await HttpManager.netFetch(
        Address.startScan(), null, headerMap, Options(method: "post"));
    if (res != null && res.result) {
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }

  ///取得設備圖片metadata
  static getImgMetaData(Map<String, dynamic> header, int count) async {
    Map<String, dynamic> mainDataArray = {};

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, dynamic> headerMap = {};
    headerMap.addAll(header);
    List<dynamic> dataArray = [];
    var res = await HttpManager.netFetch(
        Address.getImgMetaData(count), null, headerMap, Options(method: "get"));
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("------ ImgMetaDate resp -----");
        print(res.headers);
      }
      var date = HttpDate.parse(res.headers["date"][0]);
      var dateStr =
          "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
      mainDataArray["date"] = dateStr;
      return DataResult(mainDataArray, true);
    }
  }

  ///取得圖片
  static getImgData(Map<String, dynamic> header, int count) async {
    Map<String, dynamic> mainDataArray = {};

    ///aesEncode
    // var aesData = AesUtils.aes128Encrypt(str);
    // Map paramsData = {"data": aesData};
    Map<String, dynamic> headerMap = {};
    headerMap.addAll(header);
    List<dynamic> dataArray = [];
    var res = await HttpManager.netFetch(
        Address.getImg(count), null, headerMap, Options(method: "get"));
    if (res != null && res.result) {
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }

  ///delete session
  static deleteSession(Map<String, dynamic> header) async {
    Map<String, dynamic> mainDataArray = {};

    Map<String, dynamic> headerMap = {};
    headerMap.addAll(header);
    var res = await HttpManager.netFetch(
        Address.getSession(), null, headerMap, Options(method: "delete"));
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("sessionID resp => " + res.data.toString());
      }
      await LocalStorage.remove(Config.sessionHeaders);
      await LocalStorage.remove(Config.devices);
      mainDataArray = res.data;
      return DataResult(mainDataArray, true);
    }
  }
}
