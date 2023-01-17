// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:developer';
import 'dart:ffi';
import 'package:html/parser.dart' show parse;
import 'package:flutter/material.dart';
import 'package:sattelysreader/logic/getEdt.dart';
import 'package:sattelysreader/logic/getWeekNumber.dart';
import 'package:sattelysreader/logic/login.dart';
import 'package:sattelysreader/screens/calendar.dart';

void main() {
  runApp(const MyApp());
}

class Todo {
  final Map<dynamic, dynamic> EDT;
  const Todo(this.EDT);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sattelys Reader',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const LoginPage(title: 'Sattelys Reader'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool pswinvisible = true;
  bool isButtonEnabled = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String req = "";
  Map Edt = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sattelys Reader',
          style: TextStyle(color: Colors.deepPurple),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Connexion à la plateforme',
                      style: TextStyle(color: Colors.deepPurple, fontSize: 25),
                    ),
                    const Padding(padding: EdgeInsets.all(8.0)),
                    TextFormField(
                      enabled: isButtonEnabled,
                      controller: usernameController,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Identifiant',
                        border: OutlineInputBorder(),
                        hintText: 'Entrez votre identifiant',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre identifiant';
                        }
                        return null;
                      },
                    ),
                    const Padding(padding: EdgeInsets.all(8.0)),
                    TextFormField(
                      enabled: isButtonEnabled,
                      controller: passwordController,
                      autofillHints: const [AutofillHints.password],
                      obscureText: pswinvisible,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: const OutlineInputBorder(),
                          hintText: 'Entrez votre mot de passe',
                          suffix: IconButton(
                              onPressed: () {
                                //add Icon button at end of TextField
                                setState(() {
                                  //refresh UI
                                  if (pswinvisible) {
                                    //if pswinvisible == true, make it false
                                    pswinvisible = false;
                                  } else {
                                    pswinvisible =
                                        true; //if pswinvisible == false, make it true
                                  }
                                });
                              },
                              icon: Icon(pswinvisible == true
                                  ? Icons.remove_red_eye
                                  : Icons.password))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    const Padding(padding: EdgeInsets.all(8.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                            label: const Text('Aide'),
                            icon: const Icon(Icons.help),
                            onPressed: !isButtonEnabled
                                ? null
                                : () => _helpButtonAction()),
                        ElevatedButton.icon(
                          onPressed: !isButtonEnabled
                              ? null
                              : () async => _loginButtonAction(req),
                          icon: const Icon(Icons.login),
                          label: const Text('Se connecter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loginButtonAction(req) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isButtonEnabled = false;
      });

      showModalBottomSheet(
          isDismissible: false,
          isScrollControlled: false,
          context: context,
          builder: ((context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Text(
                      'Connexion à votre emploi du temps',
                      style: TextStyle(color: Colors.deepPurple, fontSize: 15),
                    ),
                  ),
                  CircularProgressIndicator(),
                ],
              )));

      req =
          await loginRequest(usernameController.text, passwordController.text);

      if (req['success']) {
        setState(() {
          isButtonEnabled = true;
        });

        final PHPSESSID = req['PHPSESSID'];
        Edt['weeks'] = req['weekList'];

        /* Now, we have all the weeks available, we check if the actual week
          is on the list, if yes, we get the schedule for it, if not, we get 
          the first week available */

        var now = DateTime.now();
        var weekNumber = getWeekNumber(now);
        var reqEdt;

        if (Edt['weeks'].indexOf(weekNumber.toString) != null) {
          // the week is available, we get the schedule for it
          reqEdt = await getWeekSchedule(PHPSESSID, weekNumber);
        } else {
          // we get the first week available
          reqEdt = await getWeekSchedule(PHPSESSID, Edt['weeks'][0].toString());
        }

        if (reqEdt?['success']) {
          /* We finnaly have all the necessary informations to go to the 
            next window with the calendar */

          Edt['schedule'] = reqEdt['schedule'];
          Edt['PHPSESSID'] = PHPSESSID;

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => CalendarView(
                        todo: Edt,
                      )),
              ModalRoute.withName("/Home"));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(reqEdt?['message'])),
          );
          setState(() {
            isButtonEnabled = true;
          });
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(req['message'].toString())),
        );
        setState(() {
          isButtonEnabled = true;
        });
      }
    }
  }

  void _helpButtonAction() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Aide à la connexion',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 25),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                  'Quels sont mes identifiants ?',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 20),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                    "Vos identifiants sont les mêmes que ceux que vous entrez sur le site gpu.iut.bordeaux.fr, nous nous connectons à ce site avec ces informations pour obtenir votre emploi du temps."),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                  "Je n'arrive pas à me connecter.",
                  style: TextStyle(color: Colors.deepPurple, fontSize: 20),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                    "Avant toute choses, pensez à vérifier votre connexion internet, et à redemmarrer l'application ou votre appareil.\n\nDans un deuxième temps, essayez de vous connecter sur le site internet officiel Sattelys GPU pour vérifier si le problème ne vient pas d'eux. Ensuite vérifiez que vous avez bien rentré le bon identifiant et mot de passe.\n\nSi le problème persiste, vous pouvez nous contacter à l'adresse email suivante : vrock691@gmail.com. Ou sur instagram."),
              ],
            ),
          );
        });
  }
}
