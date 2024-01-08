/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lightweight/Ursprung/home.dart';
import 'utils.dart';
import 'auth_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) => MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      navigatorKey: navigatorKey,
      title: 'Meine Flutter App',
      theme: ThemeData(
        // Definiert das App-Thema, z. B. Farbschemas, Schriftarten usw.
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }


class MainPage extends StatelessWidget{
  const MainPage({super.key});


  @override
  Widget build(BuildContext context) => Scaffold(
    body:StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else if (snapshot.hasData){
          return  const HomePage();
        } else {
          return const AuthPage();
        }
      },
    ),
  );
}*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lightweight/frontend/login.dart';
import 'package:lightweight/frontend/selectPlan.dart';
import 'package:lightweight/frontend/signUp.dart';
import 'package:lightweight/frontend/home.dart';
import 'package:lightweight/frontend/utils.dart';
import 'package:lightweight/frontend/calories.dart';
import 'package:lightweight/frontend/search.dart';
import 'package:lightweight/frontend/training.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Überprüfe, ob der Benutzer bereits angemeldet ist
  User? user = FirebaseAuth.instance.currentUser;

  runApp(MaterialApp(
    scaffoldMessengerKey: Utils.messengerKey,
    navigatorKey: navigatorKey,
    title: 'Meine Flutter App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: user != null ? '/home' : '/login', 
    routes: {
      '/login': (context) => const LoginPage(),
      '/signUp': (context) => const SignupPage(),
      '/home': (context) => HomePage(),
      '/calories': (context) => GrundKalorienScreen(),
      '/search': (context) => FoodSearchScreen(),
      '/selectedPlan': (context) => SelectPlanPage(),
      '/training': (context) => TrainingPage(),
    },
  ));
}

final navigatorKey = GlobalKey<NavigatorState>();


