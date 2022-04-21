import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:scanner/common/net/SoapClient.dart';

///
///上傳檔案
///Date: 2022-01-23
///
class UploadClient extends SoapClient {
  Future<GetUploadResponse> getUpload(GetUploadRequest request) async {
    return GetUploadResponse.fromXml(await post(request.toXml()));
  }
}

@immutable
class GetUploadResponse {
  final UploadInfo info;

  const GetUploadResponse(this.info);

  factory GetUploadResponse.fromXml(XmlDocument document) {
    print('response soap -->');
    print(document.toXmlString());
    var info = UploadInfo();

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
      info = UploadInfo.fromXml(node);
    }
    return GetUploadResponse(info);
  }
}

class UploadInfo {
  final String? status;
  final String? message;

  UploadInfo({this.status, this.message});

  factory UploadInfo.fromXml(XmlElement infoNode) {
    return UploadInfo(
        status: infoNode.findElements('status').first.text,
        message: infoNode.findElements('message').isEmpty
            ? ''
            : infoNode.findElements('message').first.text);
  }
}

@immutable
class GetUploadRequest {
  final String token;
  final String timestamp;
  final String base64Data;
  final String docId;
  final String page;
  final String total;

  const GetUploadRequest(
      {required this.timestamp,
      required this.base64Data,
      required this.docId,
      required this.page,
      required this.total,
      required this.token});

  XmlElement toXml() {
    const uri = "http://webservice.chiga.com/";
    final params =
        "<request><token>$token</token><uuid>$timestamp</uuid><page>$page</page><total>$total</total><documentId>$docId</documentId><image>$base64Data</image></request>";

    final xml = XmlBuilder();
    xml.element('executeWithToken', namespace: uri, nest: () {
      xml.namespace(uri, 'web');
      xml.element('arg0', nest: "imsSoapService");
      xml.element('arg1', nest: "oneScanUploadImages");
      xml.element('arg2', nest: () {
        xml.cdata(params);
      });

      xml.element('arg3', namespace: null, nest: token);
    });

    var res = xml.buildDocument().rootElement;
    return res;
  }
}
