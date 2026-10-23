import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared/app_logo.dart';
import '../../../core/shared/custom_button.dart';
import '../../../core/shared/custom_text_field.dart';
import '../../../core/shared/responsive_center.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/controller.dart' show AuthState, authControllerProvider;
import 'signup_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void onLoginPressed() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    ref.read(authControllerProvider.notifier).login(email, password);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthState authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ResponsiveCenter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppLogo(),
            const SizedBox(height: 36),
            CustomTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              controller: passwordController,
              label: 'Password',
              hint: 'Enter your password',
              isPassword: true,
            ),
            if (authState.errorMessage != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  authState.errorMessage,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            CustomButton(
              text: 'Sign In  →',
              isLoading: authState.isLoading,
              onPressed: onLoginPressed,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupView(),
                      ),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}