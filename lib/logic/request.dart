import 'dart:convert';
import 'package:http/http.dart' as http;

makePostRequest(path, body) async {
  try {
    var response = await http.post(Uri.parse('https://plumeo.ml/api/$path'),
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*',
          'Accept': 'application/json',
        },
        body: jsonEncode(body));

    if (response.statusCode != 200) {
      return {
        "success": false,
        "statusCode": response.statusCode,
        "body": response.body,
      };
    }
    return {
      "success": true,
      "statusCode": response.statusCode,
      "body": response.body,
    };
  } catch (e) {
    return {
      "success": false,
      "body": {"message": "Une erreur lors de la requête est survenue."}
    };
  }
}
