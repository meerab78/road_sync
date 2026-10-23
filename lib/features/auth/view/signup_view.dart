import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared/app_logo.dart';
import '../../../core/shared/custom_button.dart';
import '../../../core/shared/custom_text_field.dart';
import '../../../core/shared/responsive_center.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/controller.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> onSignupPressed() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    bool success = await ref
        .read(authControllerProvider.notifier)
        .signUp(name, email, password);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthState authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(backgroundColor: AppColors.white),
      body: ResponsiveCenter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppLogo(),
            const SizedBox(height: 32),
            CustomTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Meerab Khan',
            ),
            CustomTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              controller: passwordController,
              label: 'Password',
              hint: 'At least 6 characters',
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
              text: 'Create Account  →',
              isLoading: authState.isLoading,
              onPressed: onSignupPressed,
            ),
          ],
        ),
      ),
    );
  }
}