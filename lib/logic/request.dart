import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// ignore: non_constant_identifier_names
makePostRequest(body, PHPSESSID) async {
  /* This part use a small for each to correctly encode the form data */
  var parts = [];
  body.forEach((key, value) {
    parts.add('${Uri.encodeQueryComponent(key.toString())}='
        '${Uri.encodeQueryComponent(value.toString())}');
  });
  var formData = parts.join('&');

  /* Now we can make the request */
  try {
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);

    var response = await http.post(
        Uri.parse('https://gpu.perigueux.u-bordeaux.fr/mobile/index.php'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Content-Length": formData.length.toString(),
          "Cookie": 'PHPSESSID=$PHPSESSID',
        },
        body: formData);

    if (response.statusCode != 200) {
      return {
        "success": false,
        "statusCode": response.statusCode,
        "body": response.body,
        "headers": response.headers,
      };
    }
    return {
      "success": true,
      "statusCode": response.statusCode,
      "body": response.body,
      "headers": response.headers,
    };
  } catch (e) {
    return {
      "success": false,
      "body": {"message": "Une erreur est survenue."}
    };
  }
}

makeGetRequest(path) async {
  try {
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);

    var response = await http.post(
      Uri.parse('https://gpu.perigueux.u-bordeaux.fr/mobile/index.php'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    if (response.statusCode != 200) return {"success": false};
    return {
      "success": true,
      "statusCode": response.statusCode,
      "body": response.body,
      "headers": response.headers,
    };
  } catch (e) {
    return {"success": false, 'message': e};
  }
}
