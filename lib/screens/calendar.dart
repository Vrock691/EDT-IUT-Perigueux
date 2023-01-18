// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:sattelysreader/logic/getEdt.dart';
import 'package:sattelysreader/logic/getWeekNumber.dart';
import 'package:sattelysreader/logic/login.dart';
import 'package:calendar_view/calendar_view.dart';

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
  var WeekLoaded = [];

  @override
  Widget build(BuildContext context) {
    final TODO = widget.todo;
    final credentials = TODO['credentials'];
    EventController controller =
        CalendarControllerProvider.of(context).controller;
    String PHPSESSID = TODO['PHPSESSID'].toString();
    bool ReconnectionProcessIsRunning = false;

    void clearAllEvents() {}

    Color hexToColor(String code) {
      return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    }

    void addElementToCalendar(Map schedule) {
      schedule.forEach((key, value) {
        for (var element in value['lessons']) {
          DateTime DayOfEvent = value['day'];
          final event = CalendarEventData(
            color: hexToColor(element['color']),
            title: "${element['name']} - ${element['type']}",
            description: "${element['room']} | ${element['teacher']}",
            date: DayOfEvent,
            startTime: DayOfEvent.add(Duration(
                hours: element['start'][0], minutes: element['start'][1])),
            endTime: DayOfEvent.add(
                Duration(hours: element['end'][0], minutes: element['end'][1])),
            event: element.toString(),
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

    displayEventDetails(events, date) {
      showModalBottomSheet(
          context: context,
          builder: ((context) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            events['title'],
                            style: const TextStyle(fontSize: 25),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )));
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
              onPressed: () {},
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
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
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
              title: const Text("Actualiser"),
              onTap: (() {}),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {},
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text("Compte"),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Se deconnecter"),
              onTap: (() {}),
            ),
          ],
        ),
      ),
      body: ViewTypeIsWeek
          ? WeekView(
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
