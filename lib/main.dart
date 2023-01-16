import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
                              : () => _loginButtonAction(),
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

  void _loginButtonAction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isButtonEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
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
