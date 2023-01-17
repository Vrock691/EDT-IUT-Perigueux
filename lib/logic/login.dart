import 'package:html/parser.dart';

import './request.dart';

Future<Map<String, dynamic>?> loginRequest(login, password) async {
  /* First of all, we make a get request to have PHPSESSID */
  var rep = await makeGetRequest("/");

  if (rep['success'] == false) {
    return {'success': false, 'message': "Connexion au serveur impossible."};
  }

  // ignore: non_constant_identifier_names
  var PHPSESSID = rep['headers']['set-cookie']
      .toString()
      .replaceAll('PHPSESSID=', '')
      .replaceAll('; path=/', '');

  /* Now we make the login session with this id */
  rep = await makePostRequest(
      {'aim': 'connecte', 'mode': '', 'login': login, 'mdp': password},
      PHPSESSID);

  if (rep['statusCode'] != 200 || rep['success'] == false) {
    return {'success': false, 'message': "Connexion au serveur impossible."};
  }

  if (rep['success'] == true) {
    var html = parse(rep['body'].toString());

    if (!(html.getElementById('num_semaine') == null)) {
      // here we have to get the time schedule
      // first, we get all the weeks available in the html document

      final weekList = [];

      for (var element in html.getElementsByTagName('option')) {
        weekList.add(element.attributes['value']);
      }

      weekList.removeAt(0);

      return {
        'body': rep['body'],
        'headers': rep['headers'],
        'PHPSESSID': PHPSESSID,
        'success': true,
        'weekList': weekList,
      };
    } else {
      return {
        'success': false,
        'message': "Votre identifiant ou mot de passe est incorrect."
      };
    }
  }

  return null;
}
