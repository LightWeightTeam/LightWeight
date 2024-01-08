import 'package:flutter/material.dart';
import '../backend/firebase_login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uid = ''; // Variable zur Speicherung der UID

  // Funktion, um die UID zu laden
  void _loadUid() async {
    String? loadedUid = await getUid(); // Annahme: Ihre Funktion zum Laden der UID
    setState(() {
      uid = loadedUid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Hallo',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Gespeicherte UID: ${uid ?? "Keine UID gefunden"}',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                _loadUid(); // Button zum Laden der UID
              },
              child: Text('UID laden'),
            ),
            ElevatedButton(
              onPressed: () {
                checkUidInFirebase(); // Rufen Sie Ihre Methode hier auf
              },
              child: Text('UID an Server senden'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/calories');
              },
              child: const Text('Grundkalorien'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              child: const Text('Tracking'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/selectedPlan');
              },
              child: const Text('Training'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/training');
              },
              child: const Text('TrainingSeite'),
            ),
          ],
        ),
      ),
    );
  }
}






/*
import 'package:flutter/material.dart';
import '../backend/firebase_login.dart';



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Hallo',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier könnte die Abmeldelogik hinzugefügt werden
              },
              child: Text('Abmelden'),
            ),
          ],
        ),
      ),
    );
  }
}
*/


