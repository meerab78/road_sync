import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<String> getUserNameStream() async* {
    User? user = auth.currentUser;

    if (user == null) {
      return;
    }

    Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
    firestore.collection('users').doc(user.uid).snapshots();

    await for (DocumentSnapshot<Map<String, dynamic>> doc in snapshots) {
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data();
        if (data != null) {
          yield data['name'].toString();
        }
      }
    }
  }
}