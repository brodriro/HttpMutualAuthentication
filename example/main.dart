import 'package:http_mutual_authentication/http_mutual_authentication.dart';

void main() {
  /// Init HttpAuth with HttpAuthBuilder
  /// sets [authPass] and [pathCertificate] for request
  HttpAuth httpAuth = new HttpAuthBuilder(
          authPass: "password", pathCertificate: "assets/certificate.p12")
      .build;

  /// Replace your url
  httpAuth.getRequest("http://www.google.com").then((result){
    /// Parse response with HttpAuth.parseBody -> String
    HttpAuth.parseBody(result).then((resultString){
      print("Results: $resultString");
    });
  });
}
