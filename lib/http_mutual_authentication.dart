library http_mutual_authentication;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HttpAuth {
  // ignore: non_constant_identifier_names
  final String TAG = "HttpAuth";

  String authPass;
  String pathCertificate;
  HttpClient client;
  SecurityContext context;
  Map<String, String> _headers = new Map();

  HttpAuth({this.pathCertificate, this.authPass});

  setHeaders(String header, String value) {
    _headers.addAll({header: value});
  }

  HttpClientRequest _getHeaders(HttpClientRequest request) {
    if (_headers.length > 0) {
      _headers.forEach((key, value) => request.headers.set(key, value));
    }
    return request;
  }

  Future<HttpClientResponse> getRequest(String url) async {
    debugPrint("API : $url");

    await this._loadContext();

    var request = await client.getUrl(Uri.parse(url));

    _getHeaders(request);

    return await request.close();
  }

  Future<HttpClientResponse> postRequest(String url, Map<String, String> body) async {
    debugPrint("API : $url");

    await this._loadContext();

    var request = await client.postUrl(Uri.parse(url));
    _getHeaders(request);
    request.add(utf8.encode(json.encode(body)));

    return await request.close();
  }

  Future _loadContext() async {
    try {
      ByteData certificate = await rootBundle.load(this.pathCertificate);

      this.context = SecurityContext.defaultContext;

      this.context.useCertificateChainBytes(certificate.buffer.asUint8List(),
          password: this.authPass);
      this.context.usePrivateKeyBytes(certificate.buffer.asUint8List(),
          password: this.authPass);
    } catch (exception) {
      debugPrint("$TAG: Certificate not found. $exception");
    }
  }

  static Future<String> parseBody(HttpClientResponse response) async {
    return await response.transform(Utf8Decoder()).join();
  }
}

class HttpAuthBuilder{
  String authPass;
  String pathCertificate;

  HttpAuthBuilder({this.authPass, this.pathCertificate});


  HttpAuth get build {
    SecurityContext context;
    HttpAuth httpAuth = new HttpAuth(authPass: this.authPass, pathCertificate: this.pathCertificate);
    httpAuth.context = context;
    httpAuth.client = new HttpClient(context: context);
    return httpAuth;
  }

}