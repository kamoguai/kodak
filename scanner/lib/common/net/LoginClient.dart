import 'package:flutter/material.dart';
import 'package:scanner/common/net/SoapClient.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

///
///Login soap clinet
///Date: 2022-01-22
///
class LoginClient extends SoapClient {
  Future<GetLoginResponse> getLogin(GetLoginRequest request) async {
    return GetLoginResponse.fromXml(await post(request.toXml()));
  }
}

@immutable
class GetLoginResponse {
  final LoginInfo info;

  const GetLoginResponse(this.info);

  factory GetLoginResponse.fromXml(XmlDocument document) {
    print('response soap -->');
    print(document.toXmlString());
    var info = LoginInfo();

    ///get return element
    var returnNode = document
        .getElement('soap:Envelope')
        ?.getElement("soap:Body")
        ?.getElement('ns2:executeWithTokenResponse')
        ?.getElement('return');

    ///返回body並replace xml的角括號
    var cdata = returnNode?.toXmlString().replaceAll('&lt;', '<');
    var cxml = XmlDocument.parse(cdata!).firstChild;
    for (final node in cxml!.childElements) {
      info = LoginInfo.fromXml(node);
    }
    return GetLoginResponse(info);
  }
}

class LoginInfo {
  final String? token;
  final String? status;
  final String? message;
  final String? aesKey;
  final String? aesIv;
  final String? version;
  final String? downloadAppUrl;
  final String? useAes;

  LoginInfo(
      {this.token,
      this.status,
      this.message,
      this.aesIv,
      this.aesKey,
      this.downloadAppUrl,
      this.version,
      this.useAes});

  factory LoginInfo.fromXml(XmlElement infoNode) {
    return LoginInfo(
      status: infoNode.findElements('status').first.text,
      token: infoNode.findElements('token').isEmpty
          ? ''
          : infoNode.findElements('token').first.text,
      message: infoNode.findElements('message').isEmpty
          ? ''
          : infoNode.findElements('message').first.text,
      aesIv: infoNode.findElements('aesIv').isEmpty
          ? ''
          : infoNode.findElements('aesIv').first.text,
      aesKey: infoNode.findElements('aesKey').isEmpty
          ? ''
          : infoNode.findElements('aesKey').first.text,
      downloadAppUrl: infoNode.findElements('downloadAppUrl').isEmpty
          ? ''
          : infoNode.findElements('downloadAppUrl').first.text,
      version: infoNode.findElements('version').isEmpty
          ? ''
          : infoNode.findElements('version').first.text,
      useAes: infoNode.findElements('useAes').isEmpty
          ? ''
          : infoNode.findElements('useAes').first.text,
    );
  }
}

@immutable
class GetLoginRequest {
  final String loginId;
  final String password;
  GetLoginRequest({required this.loginId, required this.password});

  XmlElement toXml() {
    const uri = "http://webservice.chiga.com/";
    final params =
        "<request><loginId>$loginId</loginId><password>$password</password></request>";

    final xml = XmlBuilder();
    xml.element('executeWithToken', namespace: uri, nest: () {
      xml.namespace(uri, 'web');
      xml.element('arg0', nest: "imsSoapService");
      xml.element('arg1', nest: "oneScanLogin");
      xml.element('arg2', nest: () {
        xml.cdata(params);
      });

      xml.element('arg3', namespace: null, nest: null);
    });

    var res = xml.buildDocument().rootElement;
    return res;
  }
}
