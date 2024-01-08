import 'package:flutter/material.dart';
import 'package:lightweight/backend/firebase_training.dart'; // Falls vorhanden, das Backend importieren
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrainingPage(),
    );
  }
}

class TrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      body: Center(
        child: CalendarWidget(),
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _startingDay;
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> _trainingData = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    getCurrentDate().then((date) {
      if (date != null) {
        setState(() {
          _startingDay = date;
        });
      } else {
        print('Datum konnte nicht abgerufen werden');
      }
    });
  }

  String getDayId(DateTime day) {
    int diff = day.difference(_startingDay).inDays % 7;
    return 'day${diff + 1}';
  }

  Future<void> fetchTrainingData(DateTime selectedDay) async {
    String dayId = getDayId(selectedDay);
    Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> trainingData =
        await loadTrainingDataForDay(dayId);

    setState(() {
      _trainingData = trainingData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          calendarFormat: CalendarFormat.week,
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(3000, 12, 31),
          startingDayOfWeek: StartingDayOfWeek.sunday,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              print(getDayId(selectedDay)); // Drucken der Tag-ID des ausgewählten Tages
              fetchTrainingData(selectedDay); // Laden der Daten für den ausgewählten Tag
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              print(getDayId(_selectedDay)); // Drucken der Tag-ID des aktuellen ausgewählten Tages
            });
          },
        ),
          Expanded(
        child: _trainingData.isNotEmpty
            ? ListView.builder(
                itemCount: _trainingData.length,
                itemBuilder: (context, index) {
                  String splitName = _trainingData.keys.elementAt(index);
                  Map<String, Map<String, List<Map<String, dynamic>>>> daysData =
                      _trainingData[splitName] ?? {};

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: daysData.entries.map((dayEntry) {
                      Map<String, List<Map<String, dynamic>>> exercises = dayEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: exercises.entries.map((exerciseEntry) {
                              String planName = exerciseEntry.key;
                              List<Map<String, dynamic>> exerciseDataList = exerciseEntry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plan Name: $planName',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  Column(
                                    children: exerciseDataList.map((exerciseData) {
                                      String exerciseId = exerciseData['id'] ?? '';
                                      Map<String, dynamic> data = exerciseData['data'] ?? {};

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Text('Exercise ID: $exerciseId'),
                                          ListTile(
                                            title: Text('Exercise: $exerciseId'),
                                            subtitle: Text(
                                              'Sets: ${data['set'] ?? ''}, Reps: ${data['rep'] ?? ''}',
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              )
            : Container(),
      ),
    ],
  );
}
}


/*
import 'package:flutter/material.dart';
import 'package:lightweight/backend/firebase_training.dart';
import 'package:table_calendar/table_calendar.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrainingPage(),
    );
  }
}

class TrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      body: Center(
        child: CalendarWidget(),
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _startingDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    getCurrentDate().then((date) {
      if (date != null) {
        setState(() {
          _startingDay = date;
        });
      } else {
        print('Datum konnte nicht abgerufen werden');
      }
    });
  }

  String getDayId(DateTime day) {
    int diff = day.difference(_startingDay).inDays % 7;
    return 'day${diff + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarFormat: CalendarFormat.week,
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(3000, 12, 31),
      startingDayOfWeek: StartingDayOfWeek.sunday,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          print(getDayId(selectedDay)); // Drucken der Tag-ID des ausgewählten Tages
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          print(getDayId(_selectedDay)); // Drucken der Tag-ID des aktuellen ausgewählten Tages
        });
      },
    );
  }
}
*/


/*
import 'package:flutter/material.dart';
import 'package:lightweight/backend/firebase_training.dart';
import 'package:table_calendar/table_calendar.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrainingPage(),
    );
  }
}

class TrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      body: Center(
        child: CalendarWidget(),
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _startingDay;
  late Map<DateTime, DateTime> _dayDateMap; // Map zum Speichern des Datums für jeden Tag

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _startingDay = DateTime.utc(2024, 1, 2); // Startdatum festlegen (2.1.2024)
    _dayDateMap = {}; // Initialisieren der Map
    _generateDayDates(); // Datumsinformationen für die Tage generieren und speichern
  }

  void _generateDayDates() {
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1)).add(Duration(days: i));
      _dayDateMap[currentDay] = currentDay; // Das aktuelle Datum speichern
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarFormat: CalendarFormat.week,
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(3000, 12, 31),
      startingDayOfWeek: StartingDayOfWeek.sunday,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _generateDayDates(); // Datumsinformationen für die Woche aktualisieren
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          _generateDayDates(); // Datumsinformationen für die Woche aktualisieren
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          DateTime? dayDate = _dayDateMap[date];
          return Center(child: Text('${dayDate?.day}')); // Anzeige des Tages
        },
        selectedBuilder: (context, date, _) {
          DateTime? dayDate = _dayDateMap[date];
          return Container(
            margin: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(child: Text('${dayDate?.day}')), // Anzeige des Tages
          );
        },
      ),
    );
  }
}
*/



/*
import 'package:flutter/material.dart';
import 'package:lightweight/backend/firebase_training.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrainingPage(),
    );
  }
}

class TrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      body: Center(
        child: CalendarWidget(),
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _startingDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.week;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _startingDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(3000, 12, 31),
      startingDayOfWeek: getStartingDayOfWeek(),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  } 
}
*/
