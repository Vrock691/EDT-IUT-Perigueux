// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sattelysreader/logic/getEdt.dart';
import 'package:sattelysreader/logic/getWeekNumber.dart';
import 'package:sattelysreader/logic/login.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class Todo {
  final Map<dynamic, dynamic> EDT;
  const Todo(this.EDT);
}

class CalendarView extends StatelessWidget {
  const CalendarView({super.key, required this.todo});

  final Map<dynamic, dynamic> todo;

  @override
  Widget build(BuildContext context) {
    return CalendarViewStateful(todo: todo);
  }
}

class CalendarViewStateful extends StatefulWidget {
  const CalendarViewStateful({super.key, required this.todo});

  final Map<dynamic, dynamic> todo;

  @override
  State<CalendarViewStateful> createState() => CalendarViewStatefulState();
}

class CalendarViewStatefulState extends State<CalendarViewStateful> {
  bool ViewTypeIsWeek = true;
  bool lalane = false;
  bool chatemmaback = false;
  var WeekLoaded = [];
  final _calendarDayViewKey = GlobalKey<DayViewState>();
  final _calendarWeekViewKey = GlobalKey<WeekViewState>();

  @override
  Widget build(BuildContext context) {
    final TODO = widget.todo;
    final credentials = TODO['credentials'];
    EventController controller =
        CalendarControllerProvider.of(context).controller;
    String PHPSESSID = TODO['PHPSESSID'].toString();
    bool ReconnectionProcessIsRunning = false;

    void clearAllEvents() {
      CalendarControllerProvider.of(context)
          .controller
          .events
          .forEach((element) {
        CalendarControllerProvider.of(context).controller.remove(element);
      });
    }

    Color hexToColor(String code) {
      Color color;

      if (code == '' || code == '&nbsp;') {
        color = Colors.deepPurple;
      } else {
        color = Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
      }

      return color;
    }

    String Content(String content) {
      String contentFinal = '';

      if (content == '' || content == '&nbsp;') {
        contentFinal = 'Non renseigné(e)';
      } else {
        contentFinal = content;
      }

      return contentFinal;
    }

    void addElementToCalendar(Map schedule) {
      schedule.forEach((key, value) {
        for (var element in value['lessons']) {
          DateTime DayOfEvent = value['day'];
          final event = CalendarEventData(
            color: hexToColor(element['color']),
            title:
                "${Content(element['name'].toString())} - ${Content(element['type'].toString())}",
            description:
                "${Content(element['room'].toString())} | ${Content(element['teacher'].toString())}",
            date: DayOfEvent,
            startTime: DayOfEvent.add(Duration(
                hours: element['start'][0], minutes: element['start'][1])),
            endTime: DayOfEvent.add(
                Duration(hours: element['end'][0], minutes: element['end'][1])),
            event: jsonEncode(element).toString(),
          );
          CalendarControllerProvider.of(context).controller.add(event);
        }
      });
    }

    try {
      addElementToCalendar(TODO['schedule']);
    } catch (e) {
      // no schedule
    }

    void Reconnect() async {
      if (!ReconnectionProcessIsRunning) {
        ReconnectionProcessIsRunning = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Vous avez été déconnecté, reconnexion en cours...')),
        );
        var req =
            await loginRequest(credentials['login'], credentials['password']);

        if (req?['success']) {
          PHPSESSID = req?['PHPSESSID'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.deepPurple,
                content: Text(
                    'De nouveau connecté, chargement de votre emploi du temps...')),
          );
          clearAllEvents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(
                    'Erreur lors de la reconnexion, nouvel essai dans 5 secondes.')),
          );
          await Future.delayed(const Duration(seconds: 5));
          ReconnectionProcessIsRunning = false;
          Reconnect();
        }
      }
    }

    void PageChanged(date, page) async {
      var weeknum = getWeekNumber(date);

      if (!WeekLoaded.contains(weeknum) && !ReconnectionProcessIsRunning) {
        var WeekScheduleRequest = await getWeekSchedule(PHPSESSID, weeknum);

        if (WeekScheduleRequest?['success']) {
          if (WeekScheduleRequest?['schedule'] != null) {
            addElementToCalendar(WeekScheduleRequest?['schedule']);
          }
        } else {
          if (WeekScheduleRequest?['code'] == 'disconnected') {
            Reconnect();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(WeekScheduleRequest?['message'])),
            );
          }
        }
      }
    }

    displayEventDetails(events, DateTime date) {
      Map event = jsonDecode(events[0].toJson()['event'].toString());

      showModalBottomSheet(
          isScrollControlled: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          isDismissible: true,
          context: context,
          builder: ((context) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: ListTile(
                        leading: Icon(
                          Icons.class_,
                          color: hexToColor(event['color'].toString()),
                        ),
                        title: Text(
                          Content(event['name']),
                          style: const TextStyle(fontSize: 20),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                        subtitle: const Text('Date'),
                        leading: Icon(Icons.calendar_today,
                            color: hexToColor(event['color'].toString())),
                        title: Text(
                            '${Content(date.day.toString())}-${Content(date.formatted)}')),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                        subtitle: const Text('Horaire'),
                        leading: Icon(Icons.timelapse,
                            color: hexToColor(event['color'].toString())),
                        title: Text(
                            '${Content(event['startString'])} - ${Content(event['endString'])}')),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                        subtitle: const Text('Type'),
                        leading: Icon(Icons.school,
                            color: hexToColor(event['color'].toString())),
                        title: Text(Content(event['type'].toString()))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                        subtitle: const Text('Professeur'),
                        leading: Icon(Icons.person,
                            color: hexToColor(event['color'].toString())),
                        title: Text(Content(event['teacher'].toString()))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                        subtitle: const Text('Salle'),
                        leading: Icon(Icons.room,
                            color: hexToColor(event['color'].toString())),
                        title: Text(Content(event['room'].toString()))),
                  ),
                ],
              )));
    }

    Widget LalaneWidget() {
      if (lalane) {
        return ListTile(
          leading: const Icon(Icons.thermostat),
          title: const Text("La thermo"),
          onTap: (() async {
            Uri _url = Uri.parse('https://www.youtube.com/watch?v=n_pbxHnw4zY');

            Future<void> _launchUrl() async {
              if (!await launchUrl(_url)) {
                throw 'Impossible de lancer le lien $_url';
              }
            }

            _launchUrl();
          }),
        );
      } else {
        return const Padding(padding: EdgeInsets.all(0));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Votre emploi du temps',
          style: TextStyle(color: Colors.deepPurple),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                if (ViewTypeIsWeek) {
                  _calendarWeekViewKey.currentState
                      ?.animateToWeek(DateTime.now());
                } else {
                  _calendarDayViewKey.currentState
                      ?.animateToDate(DateTime.now());
                }
              },
              icon: const Icon(
                Icons.today,
                color: Colors.deepPurple,
              )),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: chatemmaback
                    ? const DecorationImage(
                        image: AssetImage("assets/chatemma.jpg"),
                        fit: BoxFit.cover)
                    : null,
                color: !chatemmaback ? Colors.deepPurple : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bienvenue sur votre emploi du temps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  Text('IUT Périgueux',
                      style: TextStyle(
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text('Vue'),
            ),
            ListTile(
              selected: !ViewTypeIsWeek,
              leading: const Icon(Icons.calendar_view_day),
              title: const Text('Jour'),
              onTap: () {
                setState(() {
                  ViewTypeIsWeek = false;
                });
                Navigator.pop(context);
              },
              onLongPress: () {
                setState(() {
                  lalane = true;
                });
              },
            ),
            ListTile(
              selected: ViewTypeIsWeek,
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('Semaine'),
              onTap: () {
                setState(() {
                  ViewTypeIsWeek = true;
                });
                Navigator.pop(context);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text("Plus d'options"),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text("Recharger EDT"),
              onTap: (() async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Colors.deepPurple,
                      content: Text('Actualisation...')),
                );
                clearAllEvents();
                if (ViewTypeIsWeek) {
                  _calendarWeekViewKey.currentState
                      ?.animateToWeek(DateTime.now());
                } else {
                  _calendarDayViewKey.currentState
                      ?.animateToDate(DateTime.now());
                }
                var WeekScheduleRequest = await getWeekSchedule(
                    PHPSESSID, getWeekNumber(DateTime.now()));

                if (WeekScheduleRequest?['success']) {
                  if (WeekScheduleRequest?['schedule'] != null) {
                    addElementToCalendar(WeekScheduleRequest?['schedule']);
                  }
                } else {
                  if (WeekScheduleRequest?['code'] == 'disconnected') {
                    Reconnect();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text(WeekScheduleRequest?['message'])),
                    );
                  }
                }
              }),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Se deconnecter"),
              onTap: (() {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                    ModalRoute.withName("/Login"));
              }),
            ),
            LalaneWidget(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text("Autres applications"),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text("Ma note sur vingt"),
              onTap: (() async {
                Uri _url = Uri.parse('https://manotesurvingt.web.app/');

                Future<void> _launchUrl() async {
                  if (!await launchUrl(_url)) {
                    throw 'Impossible de lancer le lien $_url';
                  }
                }

                _launchUrl();
              }),
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text("Pourcentage"),
              onTap: (() async {
                Uri _url = Uri.parse(
                    'https://github.com/Vrock691/pourcentage/releases');

                Future<void> _launchUrl() async {
                  if (!await launchUrl(_url)) {
                    throw 'Impossible de lancer le lien $_url';
                  }
                }

                _launchUrl();
              }),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text("Support"),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("A propos"),
              onTap: (() async {
                showAboutDialog(
                    context: context,
                    applicationName: 'Sattelys Reader',
                    applicationVersion: "1.0",
                    applicationIcon: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: (() {
                        setState(() {
                          chatemmaback = true;
                        });
                      }),
                      icon: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          "assets/logo.jpg",
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    children: [
                      const Text(
                          "Merci d'utiliser cette application ! N'hésitez pas à aller voir mes autres projets cités sur mon site vrock691.web.app.\n\nCette application n'est pas affiliée à votre IUT ou à sattelys.\n\nJe remercie ma coquillette de m'avoir lancé dans ce projet !\n\nThomas j'ai utilisé du violet comme tu m'as dit hehe.\n\nPour toute suggestions ou problèmes, n'hésitez pas à me contacter en cliquant sur 'contacter le support' dans la barre latérale.\n\nBonne chance à ceux qui chercheront les easter eggs !\n\nApplication codée avec ♥ par Valentin.")
                    ]);
              }),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Contacter le support"),
              onTap: (() async {
                final Uri _url = Uri.parse(
                    'mailto:sattelysreader@proton.me?subject=SATTELYSREADER%20ERR');
                Future<void> _launchUrl() async {
                  if (!await launchUrl(_url)) {
                    throw 'Could not launch $_url';
                  }
                }

                _launchUrl();
              }),
            ),
          ],
        ),
      ),
      body: ViewTypeIsWeek
          ? WeekView(
              key: _calendarWeekViewKey,
              weekDays: const [
                WeekDays.monday,
                WeekDays.tuesday,
                WeekDays.wednesday,
                WeekDays.thursday,
                WeekDays.friday,
                WeekDays.saturday,
              ],
              heightPerMinute: 0.8,
              controller: controller,
              onPageChange: (date, page) {
                PageChanged(date, page);
              },
              onEventTap: (events, date) => {displayEventDetails(events, date)},
              headerStyle: const HeaderStyle(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(71, 104, 58, 183))),
            )
          : DayView(
              key: _calendarDayViewKey,
              liveTimeIndicatorSettings:
                  const HourIndicatorSettings(color: Colors.deepPurple),
              heightPerMinute: 0.8,
              controller: controller,
              onPageChange: (date, page) {
                PageChanged(date, page);
              },
              onEventTap: (events, date) => {displayEventDetails(events, date)},
              headerStyle: const HeaderStyle(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(71, 104, 58, 183))),
            ),
    );
  }
}
