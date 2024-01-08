import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

Future<void> saveSelectedTrainingPlan(String selectedGoal, String selectedLevel, String selectedSplit, String currentDate) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');

  const String url = 'http://192.168.8.166:3000/training/saveTrainingData';

  final Map<String, dynamic> body = {
    'uid': uid,
    'selectedGoal': selectedGoal,
    'selectedLevel': selectedLevel,
    'selectedSplit': selectedSplit,
    'currentDate': currentDate,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Serverantwort: $data');
    } else {
      print('Fehler beim Speichern der Trainingsdaten - ${response.statusCode}: ${response.body}');
    }
  } catch (error) {
    print('Fehler beim Senden der Anfrage: $error');
  }
}
  String getFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

      StartingDayOfWeek getStartingDayOfWeek() {
      // Bestimme den Wochentag des aktuellen Datums
      int currentWeekday = DateTime.now().weekday;

      // Konvertiere den Wochentag in StartingDayOfWeek
      // Hier wird Montag als erster Tag der Woche festgelegt (können Sie ändern)
      switch (currentWeekday) {
        case DateTime.monday:
          return StartingDayOfWeek.monday;
        case DateTime.tuesday:
          return StartingDayOfWeek.tuesday;
        case DateTime.wednesday:
          return StartingDayOfWeek.wednesday;
        case DateTime.thursday:
          return StartingDayOfWeek.thursday;
        case DateTime.friday:
          return StartingDayOfWeek.friday;
        case DateTime.saturday:
          return StartingDayOfWeek.saturday;
        case DateTime.sunday:
        default:
          return StartingDayOfWeek.sunday;
      }
    }




//Kalender anzeige der Übungen neu
Future<Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>> loadTrainingDataForDay(String day) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');

  if (uid != null) {
    const String url = 'http://192.168.8.166:3000/training/getTrainingDataForDay';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uid': uid, 'day': day}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return processResponseTrainingDataForDay(responseData); // Verarbeitete Daten zurückgeben
      } else {
        print('Fehler beim Abrufen der Daten. Statuscode: ${response.statusCode}');
        return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
      }
    } catch (error) {
      print('Fehler bei der HTTP-Anfrage: $error');
      return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
    }
  } else {
    print('Keine Benutzer-ID gefunden');
    return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
  }
}


Future<Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>> processResponseTrainingDataForDay(Map<String, dynamic> responseData) async {
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> trainingData = {};

  if (responseData.containsKey('data')) {
    final Map<String, dynamic> data = responseData['data'];

    data.forEach((splitName, splitData) {
      Map<String, Map<String, List<Map<String, dynamic>>>> splitExercises = {};
      Map<String, List<Map<String, dynamic>>> dayExercises = {};

      if (splitData is Map<String, dynamic>) {
        splitData.forEach((dayName, exercises) {
          List<Map<String, dynamic>> exerciseList = [];

          if (exercises is List<dynamic>) {
            exercises.forEach((exerciseData) {
              String exerciseId = exerciseData['id'];
              Map<String, dynamic> exerciseDetails = exerciseData['data'];

              // Anpassen der Datenstruktur entsprechend der Anforderung
              exerciseList.add({
                'id': exerciseId,
                'data': exerciseDetails,
              });
            });

            dayExercises[dayName] = exerciseList;
          }
        });

        splitExercises[splitName] = dayExercises;
        trainingData['data'] = splitExercises;
      }
    });
  }

  return trainingData;
}







/*
Future<Map<String, List<Map<String, dynamic>>>> getTrainingData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');

  if (uid != null) {
    const String url = 'http://192.168.8.166:3000/training/getTrainingData';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uid': uid}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return await editTrainingData(responseData);
      } else {
        print('Fehler beim Abrufen der Daten. Statuscode: ${response.statusCode}');
        return {}; // Leere Map bei Fehlerstatus zurückgeben oder null, je nach Bedarf
      }
    } catch (error) {
      print('Fehler bei der HTTP-Anfrage: $error');
      return {}; // Leere Map bei Fehler zurückgeben oder null, je nach Bedarf
    }
  } else {
    print('Keine Benutzer-ID gefunden');
    return {}; // Leere Map zurückgeben oder null, je nach Bedarf
  }
}

Future<Map<String, List<Map<String, dynamic>>>> editTrainingData(Map<String, dynamic> responseData) async {
  Map<String, List<Map<String, dynamic>>> trainingDays = {};

  if (responseData.containsKey('data')) {
    for (String key in responseData['data'].keys) {
      List<Map<String, dynamic>> exercises = [];

      if (responseData['data'][key] is List<dynamic> && responseData['data'][key].isNotEmpty) {
        List<dynamic> dayData = responseData['data'][key];
        String dayId = dayData[0]['id'];

        for (Map<String, dynamic> exerciseData in dayData) {
          String exerciseId = exerciseData['id'];
          List<Map<String, dynamic>> nestedCollections = [];

          if (exerciseData.containsKey('data') && exerciseData['data'].containsKey('nestedCollections')) {
            nestedCollections = List<Map<String, dynamic>>.from(exerciseData['data']['nestedCollections']);
          }

          for (Map<String, dynamic> nestedCollection in nestedCollections) {
            String exerciseName = nestedCollection['exercise'];
            Map<String, dynamic> info = nestedCollection['info']['info'];

            exercises.add({
              'id': exerciseId,
              'exercise': exerciseName,
              'info': info,
            });
          }
        }

        trainingDays[key] = exercises;
      }
    }
  }

  // Hier sind die Daten für alle Tage verarbeitet
  print('Trainingstage:');
  trainingDays.forEach((day, exercises) {
    print('Tag: $day');
    exercises.forEach((exercise) {
      String exerciseId = exercise['id'];
      String exerciseName = exercise['exercise'];
      Map<String, dynamic> info = exercise['info'];
      print('ID: $exerciseId');
      print('Übung: $exerciseName');
      print('Infos: $info');
    });
  });

  return trainingDays;
}


*/

//select Trainingsplan

Future<Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>> loadTrainingSplitData(String selectedGoal, String selectedLevel) async {
  const String url = 'http://192.168.8.166:3000/training/getTrainingSplitData';

  Map<String, dynamic> requestData = {
    'selectedGoal': selectedGoal,
    'selectedLevel': selectedLevel,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      String responseData = response.body;
      return processResponseTrainingSplitData(responseData); // Rückgabe der verarbeiteten Daten
    } else {
      print('Request failed with status: ${response.statusCode}');
      return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
    }
  } catch (error) {
    print('HTTP request error: $error');
    return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
  }
}

Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> processResponseTrainingSplitData(String responseData) {
  Map<String, dynamic> decodedData = jsonDecode(responseData);

  Map<String, dynamic> data = decodedData['data'];

  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> processedData = {};

  data.forEach((splitName, splitData) {
    print('Split Name: $splitName');
    Map<String, dynamic> daysData = splitData as Map<String, dynamic>;

    Map<String, Map<String, List<Map<String, dynamic>>>> days = {};

    daysData.forEach((dayName, dayData) {
      print('\tDay Name: $dayName');
      Map<String, List<Map<String, dynamic>>> planExercises = {};

      (dayData as Map<String, dynamic>).forEach((planName, exercisesList) {
        print('\t\tPlan Name: $planName');
        List<Map<String, dynamic>> exercises = [];

        (exercisesList as List<dynamic>).forEach((exerciseData) {
          exercises.add({
            'id': exerciseData['id'],
            'data': Map<String, dynamic>.from(exerciseData['data']),
          });
          print('\t\t\tExercise ID: ${exerciseData['id']}');
          print('\t\t\tExercise Data: ${exerciseData['data']}');
        });

        planExercises[planName] = exercises;
      });

      days[dayName] = planExercises;
    });

    processedData[splitName] = days;
  });
  return processedData;
}



//get Current Date
Future<DateTime?> getCurrentDate() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('http://192.168.8.166:3000/training/getCurrentDate?uid=$uid');

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final String? currentDateStr = data['currentDate'] as String?;
      
      if (currentDateStr != null) {
        DateTime? currentDate = DateTime.tryParse(currentDateStr);

        if (currentDate != null) {
          return currentDate;
        }
      }
      throw Exception('Ungültiges Datumformat');
    } else {
      throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: $e');
  }
}


/*
//select Trainingsplan

Future<Map<String, Map<String, List<Map<String, dynamic>>>>> editTrainingSplitData(Map<String, dynamic> data) async {
  Map<String, Map<String, List<Map<String, dynamic>>>> result = {};

  data.forEach((splitKey, splitValue) {
    final days = splitValue as Map<String, dynamic>;
    final splitData = <String, List<Map<String, dynamic>>>{};

    days.forEach((dayKey, exercises) {
      final exerciseList = exercises as List<dynamic>;
      final exercisesList = <Map<String, dynamic>>[];

      exerciseList.forEach((exerciseData) {
        final id = exerciseData['id'] as String;
        final nestedCollections = exerciseData['data']['nestedCollections'] as List<dynamic>;

        final exerciseDataList = <Map<String, dynamic>>[];

        nestedCollections.forEach((nestedExercise) {
          if (nestedExercise != null && nestedExercise is Map<String, dynamic>) {
            final exerciseName = nestedExercise['exercise'] as String;
            final exerciseInfo = nestedExercise['info']['info'] as Map<String, dynamic>;

            final sets = exerciseInfo['set'] is int ? exerciseInfo['set'] as int : null;
            final reps = exerciseInfo['rep'] is int ? exerciseInfo['rep'] as int : null;

            exerciseDataList.add({
              'exercise': exerciseName,
              'sets': sets,
              'reps': reps,
            });
          }
        });

        splitData.putIfAbsent(id, () => exerciseDataList);
      });
    });

    result[splitKey] = splitData;
  });

  print(result);
  return result;
}

Future<Map<String, Map<String, List<Map<String, dynamic>>>>> loadTrainingSplitData(String selectedGoal, String selectedLevel) async {
  const String url = 'http://192.168.8.166:3000/training/getTrainingSplitData';

  Map<String, dynamic> requestData = {
    'selectedGoal': selectedGoal,
    'selectedLevel': selectedLevel,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final splitData = await editTrainingSplitData(responseData['data'] as Map<String, dynamic>);
      
      splitData.forEach((splitKey, split) {
        print(splitKey);
        split.forEach((id, exercises) {
          print('  $id');
          exercises.forEach((exercise) {
            print('    ${exercise['exercise']}\tSets: ${exercise['sets']}, Reps: ${exercise['reps']}');
          });
        });
      });
      
      return splitData; // Rückgabe der bearbeiteten Daten
    } else {
      print('Request failed with status: ${response.statusCode}');
      return {}; // Rückgabe eines leeren Datensatzes oder eine andere Fehlerbehandlung
    }
  } catch (error) {
    print('HTTP request error: $error');
    return {}; // Rückgabe eines leeren Datensatzes oder eine andere Fehlerbehandlung
  }
}
*/


/*
//Kalender anzeige der Übungen neu
Future<Map<String, List<Map<String, dynamic>>>> getTrainingDataForDay(String day) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');

  if (uid != null) {
    const String url = 'http://192.168.8.166:3000/training/getTrainingDataForDay';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uid': uid, 'day': day}), // Senden des spezifischen Tags
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        Map<String, List<Map<String, dynamic>>> processedData = await editAndSaveTrainingData(responseData);

        return processedData;

      } else {
        print('Fehler beim Abrufen der Daten. Statuscode: ${response.statusCode}');
        return {}; // Leere Map bei Fehlerstatus zurückgeben oder null, je nach Bedarf
      }
    } catch (error) {
      print('Fehler bei der HTTP-Anfrage: $error');
      return {}; // Leere Map bei Fehler zurückgeben oder null, je nach Bedarf
    }
  } else {
    print('Keine Benutzer-ID gefunden');
    return {}; // Leere Map zurückgeben oder null, je nach Bedarf
  }
}


Future<Map<String, List<Map<String, dynamic>>>> editAndSaveTrainingData(Map<String, dynamic> responseData) async {
  Map<String, List<Map<String, dynamic>>> trainingDays = {};

  if (responseData.containsKey('data')) {
    final Map<String, dynamic> data = responseData['data'];

    data.forEach((dayKey, dayValue) {
      final List<Map<String, dynamic>> exercises = [];

      if (dayValue is List<dynamic> && dayValue.isNotEmpty) {
        final List<dynamic> dayData = dayValue;

        for (var exerciseData in dayData) {
          final String exerciseId = exerciseData['id'];
          final List<dynamic> nestedCollections = exerciseData['data']['nestedCollections'];

          final List<Map<String, dynamic>> exerciseDataList = [];

          for (var nestedExercise in nestedCollections) {
            final String exerciseName = nestedExercise['exercise'];
            final Map<String, dynamic> exerciseInfo = nestedExercise['info']['info'];

            final int? sets = exerciseInfo['set'] is int ? exerciseInfo['set'] : null;
            final int? reps = exerciseInfo['rep'] is int ? exerciseInfo['rep'] : null;

            exerciseDataList.add({
              'exercise': exerciseName,
              'sets': sets,
              'reps': reps,
            });
          }

          exercises.add({
            'id': exerciseId,
            'exercises': exerciseDataList,
          });
        }

        trainingDays[dayKey] = exercises;
      }
    });
  }

  // Überprüfen, ob Daten korrekt verarbeitet wurden
  trainingDays.forEach((dayId, exercises) {
    print('Tag-ID: $dayId');
    exercises.forEach((exercise) {
      print('Übungs-ID: ${exercise['id']}, Übung: ${exercise['exercises']}');
    });
  });

  return trainingDays;
}
*/