/*
import 'package:flutter/material.dart';
import '../backend/firebase_training.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select Plan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SelectPlanPage(),
    );
  }
}

class SelectPlanPage extends StatefulWidget {
  @override
  _SelectPlanPageState createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  String selectedGoal = 'definition';
  String selectedLevel = 'beginner';
  String selectedSplit = 'split1';
  Map<String, Map<String, List<Map<String, dynamic>>>>? splitData;
  bool showButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Plan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frage 1: Was ist dein Ziel\n Bodyweight: Resistance Band + Pull Up Bar',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              hint: Text('Select a goal'),
              value: selectedGoal,
              onChanged: (newValue) {
                setState(() {
                  selectedGoal = newValue!;
                });
              },
              items: ['bodyweight', 'definition', 'strength']
                  .map((goal) => DropdownMenuItem<String>(
                        child: Text(goal),
                        value: goal,
                      ))
                  .toList(),
            ),
            SizedBox(height: 20.0),
            const Text(
              'Frage 2: Welches Niveau haben Sie',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              hint: Text('Select a level'),
              value: selectedLevel,
              onChanged: (newValue) {
                setState(() {
                  selectedLevel = newValue!;
                });
              },
              items: ['beginner', 'advanced']
                  .map((level) => DropdownMenuItem<String>(
                        child: Text(level),
                        value: level,
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                //splitData = await loadTrainingSplitData(selectedGoal, selectedLevel);
                loadTrainingSplitData(selectedGoal, selectedLevel);
                setState(() {
                  showButton = true;
                });
              },
              child: const Text('Submit'),
            ),

            if (splitData != null && showButton) ...[
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  String currentDate = getFormattedDate();
                  await saveSelectedTrainingPlan(selectedGoal, selectedLevel, selectedSplit, currentDate);
                },
                child: const Text('Save Data'),
              ),
            ],

            if (splitData != null) ...[
              SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                hint: Text('split'),
                value: selectedSplit,
                onChanged: (newValue) {
                  setState(() {
                    selectedSplit = newValue!;
                  });
                },
                items: splitData!.keys.map((split) => DropdownMenuItem<String>(
                  child: Text(split),
                  value: split,
                )).toList(),
              ),
              SizedBox(height: 20.0),
              if (selectedSplit.isNotEmpty && splitData![selectedSplit] != null) ...[
                for (final id in splitData![selectedSplit]!.keys) ...[
                  Text(id),
                  for (final exercise in splitData![selectedSplit]![id]!) ...[
                    Text('${exercise['exercise']}\tSets: ${exercise['sets']}, Reps: ${exercise['reps']}'),
                  ],
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../backend/firebase_training.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select Plan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SelectPlanPage(),
    );
  }
}

class SelectPlanPage extends StatefulWidget {
  @override
  _SelectPlanPageState createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  String selectedGoal = 'definition';
  String selectedLevel = 'beginner';
  String selectedSplit = 'split1';
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>? splitData;
  bool showButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Plan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frage 1: Was ist dein Ziel\n Bodyweight: Resistance Band + Pull Up Bar',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              hint: Text('Select a goal'),
              value: selectedGoal,
              onChanged: (newValue) {
                setState(() {
                  selectedGoal = newValue!;
                });
              },
              items: ['bodyweight', 'definition', 'strength']
                  .map((goal) => DropdownMenuItem<String>(
                        child: Text(goal),
                        value: goal,
                      ))
                  .toList(),
            ),
            SizedBox(height: 20.0),
            const Text(
              'Frage 2: Welches Niveau haben Sie',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              hint: Text('Select a level'),
              value: selectedLevel,
              onChanged: (newValue) {
                setState(() {
                  selectedLevel = newValue!;
                });
              },
              items: ['beginner', 'advanced']
                  .map((level) => DropdownMenuItem<String>(
                        child: Text(level),
                        value: level,
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                var fetchedData = await loadTrainingSplitData(selectedGoal, selectedLevel);
                setState(() {
                  splitData = fetchedData;
                  showButton = true;
                });
              },
              child: const Text('Submit'),
            ),

            if (splitData != null && showButton) ...[
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  String currentDate = getFormattedDate();
                  await saveSelectedTrainingPlan(selectedGoal, selectedLevel, selectedSplit, currentDate);
                },
                child: const Text('Save Data'),
              ),
            ],

            if (splitData != null) ...[
              SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                hint: Text('split'),
                value: selectedSplit,
                onChanged: (newValue) {
                  setState(() {
                    selectedSplit = newValue!;
                  });
                },
                items: splitData!.keys.map((split) => DropdownMenuItem<String>(
                      child: Text(split),
                      value: split,
                    )).toList(),
              ),
              SizedBox(height: 20.0),
              if (selectedSplit.isNotEmpty && splitData![selectedSplit] != null) ...[
                for (final day in splitData![selectedSplit]!.keys) ...[
                  Text(day),
                  for (final planName in splitData![selectedSplit]![day]!.keys) ...[
                    Text(planName),
                    for (final exercise in splitData![selectedSplit]![day]![planName]!) ...[
                      Text('${exercise['id']}\tSets: ${exercise['data']['set']}, Reps: ${exercise['data']['rep']}'),
                    ],
                  ],
                ],
              ],
            ],
          ],
        ),
      ),
    )
    );
  }
}


