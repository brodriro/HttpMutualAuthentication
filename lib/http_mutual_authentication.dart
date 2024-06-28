library http_mutual_authentication;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HttpAuth {
  final String _tag = "HttpAuth";

  late String authPass;
  late String pathCertificate;
  late HttpClient client;
  late SecurityContext context;

  Map<String, String> _headers = {};

  HttpAuth({required this.pathCertificate, required this.authPass}) {
    client = HttpClient();
  }

  void setHeaders(String header, String value) {
    _headers[header] = value;
  }

  HttpClientRequest _getHeaders(HttpClientRequest request) {
    _headers.forEach((key, value) => request.headers.set(key, value));
    return request;
  }

  Future<HttpClientResponse> getRequest(String url) async {
    debugPrint("API : $url");

    await _loadContext();

    var request = await client.getUrl(Uri.parse(url));
    _getHeaders(request);

    return request.close();
  }

  Future<HttpClientResponse> postRequest(
      String url, Map<String, String> body) async {
    debugPrint("API : $url");

    await _loadContext();

    var request = await client.postUrl(Uri.parse(url));
    _getHeaders(request);
    request.add(utf8.encode(json.encode(body)));

    return request.close();
  }

  Future<void> _loadContext() async {
    try {
      ByteData certificate = await rootBundle.load(this.pathCertificate);
      this.context = SecurityContext.defaultContext;
      this.context.useCertificateChainBytes(certificate.buffer.asUint8List(),
          password: this.authPass);
      this.context.usePrivateKeyBytes(certificate.buffer.asUint8List(),
          password: this.authPass);
    } catch (e) {
      debugPrint("$_tag: Error loading certificate: $e");
      rethrow; // Re-throw the exception to maintain proper error propagation
    }
  }

  static Future<String> parseBody(HttpClientResponse response) async {
    return await utf8.decodeStream(response);
  }
}

class HttpAuthBuilder {
  String authPass;
  String pathCertificate;

  HttpAuthBuilder({required this.authPass, required this.pathCertificate});

  HttpAuth build() {
    HttpAuth httpAuth = HttpAuth(
        authPass: this.authPass, pathCertificate: this.pathCertificate);
    return httpAuth;
  }
}
