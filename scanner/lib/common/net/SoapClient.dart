import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class SoapClient {
  static String endpoint = 'http://ap2.chiga.com.tw:8080/unims/webservice/soap';

  Future<XmlDocument> post(XmlElement request) async {
    final response = await http.post(Uri.parse(endpoint),
        headers: {'Content-Type': 'text/xml'},
        body: _soapEnvelope(request).toXmlString());
    print(_soapEnvelope(request).toXmlString());
    print(XmlDocument.parse(response.body));
    return XmlDocument.parse(response.body);
  }

  XmlNode _soapEnvelope(Object body) {
    const uri = "http://schemas.xmlsoap.org/soap/envelope/";
    const uri2 = "http://webservice.chiga.com/";
    final xml = XmlBuilder();
    xml.element("Envelope", namespace: uri, nest: () {
      xml.namespace(uri, 'soapenv');
      xml.namespace(uri2, 'web');
      xml.element("Header", namespace: uri);
      xml.element("Body", namespace: uri, nest: body);
    });
    return xml.buildDocument();
  }
}
