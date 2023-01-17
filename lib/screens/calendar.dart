import 'package:flutter/material.dart';
import 'package:sattelysreader/logic/getEdt.dart';
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
  var ViewType = 'Day';

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Votre emploi du temps',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ],
          ),
        ),
        body: Calendar(),
      ),
    );
  }

  Widget Calendar() {
    if (ViewType == 'Week') {
      return WeekView();
    } else {
      return DayView();
    }
  }
}
