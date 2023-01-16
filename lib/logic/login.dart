import './request.dart';

Future<Map<String, dynamic>?> loginRequest(login, password) async {
  /* First of all, we make a get request to have PHPSESSID */
  var rep = await makeGetRequest("/");

  if (rep['success'] == false) {
    return {'success': false, 'message': rep['e']};
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
    return {
      'success': false,
      'message':
          "Error ${rep['statusCode']}. Server connection is impossible or response is incomplete"
    };
  }

  if (rep['success'] == true) {
    return {
      'body': rep['body'],
      'headers': rep['headers'],
      'success': true,
    };
  }

  return null;
}
