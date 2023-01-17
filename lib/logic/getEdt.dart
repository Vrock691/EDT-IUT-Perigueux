import 'dart:convert';

import './request.dart';
import 'package:html/parser.dart';

// ignore: non_constant_identifier_names
Future<Map<String, dynamic>?> getWeekSchedule(PHPSESSID, weekNumber) async {
  var rep = await makePostRequest(
      {'aim': '', 'mode': '', 'num_semaine': weekNumber}, PHPSESSID);

  if (rep['statusCode'] != 200 || rep['success'] == false) {
    return {'success': false, 'message': "Connexion au serveur impossible."};
  }

  if (rep['success'] == true) {
    var html = parse(rep['body'].toString());

    if (html.getElementById('num_semaine') == null) {
      return {
        'success': false,
        'message': "Vous avez été déconnecté.",
        'code': 'disconnected'
      };
    }

    final EdtHtml = html.getElementsByClassName('edt')[0];

    print(EdtHtml);

    var scheduleInJson = {};

    return {
      'body': rep['body'],
      'headers': rep['headers'],
      'success': true,
      'scheduleInJson': scheduleInJson,
    };
  }

  return null;
}
