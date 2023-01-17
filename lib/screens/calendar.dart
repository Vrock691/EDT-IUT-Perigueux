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
    String PHPSESSID = TODO['PHPSESSID'].toString();

    Widget calendar() {
      if (ViewTypeIsWeek) {
        return WeekView(
          onPageChange: (date, page) async {
            var weeknum = getWeekNumber(date);

            if (!WeekLoaded.contains(weeknum)) {
              var WeekScheduleRequest =
                  await getWeekSchedule(PHPSESSID, weeknum);

              if (WeekScheduleRequest?['success']) {
              } else {
                if (WeekScheduleRequest?['code'] == 'disconnected') {
                  // re login
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.redAccent,
                        content:
                            Text(WeekScheduleRequest?['message'])),
                  );
                }
              }
            }
          },
        );
      } else {
        return DayView();
      }
    }

    return CalendarControllerProvider(
      controller: EventController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Votre emploi du temps',
            style: TextStyle(color: Colors.deepPurple),
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.today,
                  color: Colors.deepPurple,
                ))
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
        body: calendar(),
      ),
    );
  }
}
