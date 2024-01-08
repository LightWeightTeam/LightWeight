import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> addDocumentToCollection() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String email = user.email ?? '';
    String userId = user.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('userId')
          .set({
        'email': email
      });

      print('Dokument erstellt');
    } catch (e) {
      print(e);
    }
  } else {
    print('Benutzer ist nicht angemeldet');
  }
}
