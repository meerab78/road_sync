import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model.dart';

class SettingsService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  String getUserId() {
    User? user = auth.currentUser;
    if (user == null) {
      return '';
    }
    return user.uid;
  }

  Future<UserSettings> getSettings() async {
    String uid = getUserId();
    DocumentSnapshot<Map<String, dynamic>> doc =
    await firestore.collection('users').doc(uid).get();

    Map<String, dynamic>? data = doc.data();
    if (data == null) {
      data = {};
    }
    return UserSettings.fromMap(data);
  }

  Stream<UserSettings> watchSettings() async* {
    String uid = getUserId();

    Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
    firestore.collection('users').doc(uid).snapshots();

    await for (DocumentSnapshot<Map<String, dynamic>> doc in snapshots) {
      Map<String, dynamic>? data = doc.data();
      if (data == null) {
        data = {};
      }
      yield UserSettings.fromMap(data);
    }
  }

  Future<void> saveEmergencyContact(String name, String number) async {
    String uid = getUserId();
    await firestore.collection('users').doc(uid).set({
      'emergencyName': name,
      'emergencyNumber': number,
    }, SetOptions(merge: true));
  }

  Future<void> saveRadius(int radius) async {
    String uid = getUserId();
    await firestore.collection('users').doc(uid).set({
      'defaultRadius': radius,
    }, SetOptions(merge: true));
  }

  Future<void> saveNotifications(bool value) async {
    String uid = getUserId();
    await firestore.collection('users').doc(uid).set({
      'notificationsOn': value,
    }, SetOptions(merge: true));
  }
}