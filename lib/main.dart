// App yahan se start hoti hai. Firebase on karti hai,
// phir dekhti hai: user login hai to MainView, warna LoginView.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controller/controller.dart';
import 'features/auth/view/login_view.dart';
import 'features/main/view.dart';
import 'features/notification/service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (FirebaseAuth.instance.currentUser != null) {
    NotificationService().saveToken();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<User?> authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'RoadSync',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainView();
          }
          return const LoginView();
        },
        loading: () {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stack) {
          return Scaffold(body: Center(child: Text('Error: $error')));
        },
      ),
    );
  }
}