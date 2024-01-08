import 'package:flutter/material.dart';
import '../backend/firebase_nutrition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grundkalorienrechner',
      home: GrundKalorienScreen(),
    );
  }
}

class GrundKalorienScreen extends StatefulWidget {
  @override
  _GrundKalorienScreenState createState() => _GrundKalorienScreenState();
}

class _GrundKalorienScreenState extends State<GrundKalorienScreen> {
  final TextEditingController geschlechtController = TextEditingController();
  final TextEditingController alterController = TextEditingController();
  final TextEditingController gewichtController = TextEditingController();
  final TextEditingController groesseController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<String> foodInfo = [];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grundkalorienrechner'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: geschlechtController,
              decoration: InputDecoration(labelText: 'Geschlecht'),
            ),
            TextField(
              controller: alterController,
              decoration: InputDecoration(labelText: 'Alter'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: gewichtController,
              decoration: InputDecoration(labelText: 'Gewicht'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: groesseController,
              decoration: InputDecoration(labelText: 'Größe'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            ElevatedButton(
              onPressed: () async {
                await berechneUndSpeichereGrundKalorien(
                  geschlechtController.text,
                  int.parse(alterController.text),
                  double.parse(gewichtController.text),
                  double.parse(groesseController.text),
                );
              },
              child: Text('Berechnen'),
            ),
          ],
        ),
      ),
    );
  }
}