import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:scanner/common/net/Code.dart';

import 'dart:collection';
import 'dart:convert';
import 'package:scanner/common/net/ResultData.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:connectivity/connectivity.dart';

///http請求
class HttpManager {
  static const content_type_json = "application/json";
  static const content_type_form = "application/x-www-form-urlencoded";
  static Map optionParams = {
    "timeoutMs": 15000,
    "token": null,
    "authorizationCode": null,
  };
  static netFetch(url, params, Map<String, dynamic> header, Options option,
      {noTip = false}) async {
    //沒有網路時
    var conntectivityResult = await (Connectivity().checkConnectivity());
    if (conntectivityResult == ConnectivityResult.none) {
      return ResultData(Code.errorHandleFunction(Code.network_error, "", noTip),
          false, Code.network_error);
    }

    Map<String, dynamic> headers = HashMap();

    headers.addAll(header);
    option.headers = headers;

    //超時
    // option.connectTimeout = 15000;
    Dio dio = Dio();
    Response response;
    try {
      dio.options.connectTimeout = 6000;

      ///忽略https校驗
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
      };
      response = await dio.request(url, data: params, options: option);
    } on DioError catch (e) {
      var errorResponse;

      if (e.response != null) {
        //如果有錯誤信息回填
        errorResponse = e.response;
        if (e.type == DioErrorType.connectTimeout) {
          //如果是timeout
          errorResponse.statusCode = Code.network_timeout;
        }
        if (Config.DEBUG) {
          // debug模式才會進入
          print("請求異常 => " + e.toString());
          print("請求異常url => " + url);
        }
        return ResultData(
            Code.errorHandleFunction(
                errorResponse.statusCode, e.message, noTip),
            false,
            errorResponse.statusCode);
      } else {
        return ResultData(
            Code.errorHandleFunction(99, e.message, noTip), false, 99);
      }
    }

    if (Config.DEBUG) {
      print("請求 url => " + url);
      print("請求頭 => " + option.toString());
      if (params != null) {
        print("請求參數 => " + params.toString());
      }
    }
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var jsonStr = jsonDecode(response.toString());
          Map<String, dynamic> map = jsonStr;
          print("返回參數 => " + response.toString());
          return ResultData(map, true, Code.success, headers: response.headers);
        } catch (ex) {
          Map<String, dynamic> map = {};
          return ResultData(map, true, Code.success, headers: response.headers);
        }
      }
    } catch (e) {
      print(e.toString() + url);
      String respData =
          response.data.toString().replaceAll("\r", "").replaceAll("\n", "");
      if (respData.isEmpty) {
        return ResultData(null, false, response.statusCode!,
            headers: response.headers);
      }
      Map<String, dynamic> jsonStr = jsonDecode(response.data);
      return ResultData(jsonStr, false, response.statusCode!,
          headers: response.headers);
    }
    return ResultData(Code.errorHandleFunction(response.statusCode, "", noTip),
        false, response.statusCode!);
  }
}
