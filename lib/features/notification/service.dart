import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class NotificationService {
  // Phone ka FCM token users/{uid} mein save karta hai,
  // taake Node server is phone ko push bhej sake.
  Future<void> saveToken() async {
    debugPrint('saveToken called');
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      String? token = await messaging.getToken();
      User? user = FirebaseAuth.instance.currentUser;

      if (token == null || user == null) {
        return;
      }

      await writeToken(user.uid, token);

      messaging.onTokenRefresh.listen((newToken) {
        writeToken(user.uid, newToken);
      });
    }  catch (e) {
  debugPrint('FCM token error: $e');
  }
  }

  Future<void> writeToken(String uid, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}