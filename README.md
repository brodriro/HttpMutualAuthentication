# Http Mutual Authentication

## Using
Optional params: `password` and `pathCertificate`

```dart
HttpAuth httpAuth = new HttpAuthBuilder(
          authPass: "password", pathCertificate: "assets/certificate.p12")
      .build;

  httpAuth.getRequest("http://www.google.com").then((result){
    HttpAuth.parseBody(result).then((resultString){
      print("Results: $resultString");
    });
  }); //replace url
```
