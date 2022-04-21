import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:scanner/common/net/SoapClient.dart';

///
///取得文件列表
///Date: 2022-01-23
class DocTypeClient extends SoapClient {
  Future<GetDocTypeResponse> getDocType(GetDocTypeRequest request) async {
    return GetDocTypeResponse.fromXml(await post(request.toXml()));
  }
}

@immutable
class GetDocTypeResponse {
  final DoctypeInfo info;

  const GetDocTypeResponse(this.info);

  factory GetDocTypeResponse.fromXml(XmlDocument document) {
    print('response soap -->');
    print(document.toXmlString());
    var info = DoctypeInfo();

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
      info = DoctypeInfo.fromXml(node);
    }
    return GetDocTypeResponse(info);
  }
}

class DoctypeInfo {
  final String? status;
  final String? message;
  final Row? row;

  DoctypeInfo({this.status, this.message, this.row});

  factory DoctypeInfo.fromXml(XmlElement infoNode) {
    return DoctypeInfo(
        status: infoNode.findElements('status').first.text,
        message: infoNode.findElements('message').isEmpty
            ? ''
            : infoNode.findElements('message').first.text,
        row: infoNode.findElements('rows').isEmpty
            ? null
            : Row.fromElement(infoNode.findElements('rows').first));
  }
}

class Row {
  final String? key;
  final String? value;
  final List<Row>? subRows;
  Row({this.key, this.value, this.subRows});
  factory Row.fromElement(XmlElement rowElement) {
    return Row(
        key: rowElement.getAttribute('key'),
        value: rowElement.getAttribute('value'),
        subRows: rowElement
            .findAllElements('row')
            .map((e) => Row.fromElement(e))
            .toList());
  }
}

@immutable
class GetDocTypeRequest {
  final String token;
  const GetDocTypeRequest({required this.token});

  XmlElement toXml() {
    const uri = "http://webservice.chiga.com/";
    final params = "<request><token>$token</token></request>";

    final xml = XmlBuilder();
    xml.element('executeWithToken', namespace: uri, nest: () {
      xml.namespace(uri, 'web');
      xml.element('arg0', nest: "imsSoapService");
      xml.element('arg1', nest: "getDocTypes");
      xml.element('arg2', nest: () {
        xml.cdata(params);
      });

      xml.element('arg3', namespace: null, nest: token);
    });

    var res = xml.buildDocument().rootElement;
    return res;
  }
}
