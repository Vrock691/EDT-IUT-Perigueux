import 'dart:convert';
import 'dart:ffi';

import './request.dart';
import 'package:html/parser.dart';

// ignore: non_constant_identifier_names
Future<Map<String, dynamic>?> getWeekSchedule(PHPSESSID, weekNumber) async {
  var rep = await makePostRequest(
      {'aim': '', 'mode': '', 'num_semaine': weekNumber}, PHPSESSID);

  if (rep['statusCode'] != 200 || rep['success'] == false) {
    return {
      'success': false,
      'message': "Connexion au serveur impossible.",
      'code': 'server_lost'
    };
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

    String currentDayInTheLoop = '';
    Map EDT = {};

    for (var element in EdtHtml.getElementsByTagName('td')) {
      switch (element.className) {
        case 'jour':
          var completedate = element.innerHtml.toString();
          var year = int.parse(completedate.substring(
              completedate.length - 4, completedate.length));
          var month = int.parse(completedate.substring(
              completedate.length - 7, completedate.length - 5));
          var day = int.parse(completedate.substring(
              completedate.length - 10, completedate.length - 8));
          currentDayInTheLoop = DateTime(
            year,
            month,
            day,
          ).toString();
          EDT[currentDayInTheLoop] = {
            'html': [],
            'lessons': [],
            'day': DateTime(
              year,
              month,
              day,
            )
          };
          break;
        case 'atenu':
          EDT[currentDayInTheLoop]['html'].add(element);
          break;
        default:
      }
    }

    if (EDT.isEmpty) {
      return {
        'body': rep['body'],
        'headers': rep['headers'],
        'success': true,
        'scheduleInJson': {},
      };
    }

    EDT.forEach((key, value) {
      var i = 0;

      var start;
      var end;
      var type;
      var name;
      var teacher;
      var room;

      for (var element in value['html']) {
        switch (i) {
          case 0:
            i++;
            var hour = element.innerHtml
                .toString()
                .substring(0, element.innerHtml.toString().length - 2)
                .replaceAll("h", '');
            var minute = element.innerHtml
                .toString()
                .substring(element.innerHtml.toString().length - 2,
                    element.innerHtml.toString().length)
                .replaceAll("h", '');
            start = [int.parse(hour), int.parse(minute)];
            break;
          case 1:
            i++;
            var hour = element.innerHtml
                .toString()
                .substring(0, element.innerHtml.toString().length - 2)
                .replaceAll("h", '');
            var minute = element.innerHtml
                .toString()
                .substring(element.innerHtml.toString().length - 2,
                    element.innerHtml.toString().length)
                .replaceAll("h", '');
            end = [int.parse(hour), int.parse(minute)];
            break;
          case 2:
            i++;
            type = element.innerHtml
                .toString()
                .replaceAll('<br>', '')
                .replaceAll(' ', '')
                .replaceAll('\n', '')
                .replaceAll(' ', '')
                .replaceAll('	', '');
            break;
          case 3:
            i++;
            name = element.innerHtml
                .toString()
                .replaceAll('<br>', '')
                .replaceAll(' ', '')
                .replaceAll('\n', '')
                .replaceAll(' ', '')
                .replaceAll('	', '');
            break;
          case 4:
            i++;
            teacher = element.innerHtml
                .toString()
                .replaceAll('<br>', '')
                .replaceAll(' ', '')
                .replaceAll('\n', '')
                .replaceAll(' ', '')
                .replaceAll('	', '');

            break;
          case 5:
            i = 0;
            room = element.innerHtml
                .toString()
                .replaceAll('<br>', '')
                .replaceAll(' ', '')
                .replaceAll('\n', '')
                .replaceAll(' ', '')
                .replaceAll('	', '');

            EDT[key]['lessons'].add({
              'start': start,
              'end': end,
              'type': type,
              'name': name,
              'teacher': teacher,
              'room': room
            });
            break;
          default:
        }
      }
    });

    return {
      'body': rep['body'],
      'headers': rep['headers'],
      'success': true,
      'schedule': EDT,
    };
  }

  return null;
}
