import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/services.dart';


// Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});


final authStateProvider = StreamProvider<User?>((ref) {
  AuthService service = ref.watch(authServiceProvider);
  return service.authStateChanges();
});

class AuthState {
  final bool isLoading;
  final String errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage = ''});
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<bool> login(String email, String password) async {
    if (email == '' || password == '') {
      state = const AuthState(errorMessage: 'Please enter email and password');
      return false;
    }

    state = const AuthState(isLoading: true);

    try {
      await ref.read(authServiceProvider).login(email, password);
      state = const AuthState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(errorMessage: e.message ?? 'Something went wrong');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    if (name == '' || email == '' || password == '') {
      state = const AuthState(errorMessage: 'Please fill all fields');
      return false;
    }

    state = const AuthState(isLoading: true);

    try {
      await ref.read(authServiceProvider).signUp(name, email, password);
      state = const AuthState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(errorMessage: e.message ?? 'Something went wrong');
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});