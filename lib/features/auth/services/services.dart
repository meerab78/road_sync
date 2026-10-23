import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notification/service.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() {
    return auth.authStateChanges();
  }

  Future<void> login(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
    await NotificationService().saveToken();
  }

  Future<void> signUp(String name, String email, String password) async {
    UserCredential result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now().toString(),
      });
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}