// Code daal kar kisi trip mein join hone ki screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/features/trip/screens/trip_detail_view.dart';
import '../../../core/shared/custom_button.dart';
import '../../../core/shared/custom_text_field.dart';
import '../../../core/shared/responsive_page.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/controller.dart';

class JoinTripView extends ConsumerStatefulWidget {
  const JoinTripView({super.key});

  @override
  ConsumerState<JoinTripView> createState() => _JoinTripViewState();
}

class _JoinTripViewState extends ConsumerState<JoinTripView> {
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tripControllerProvider.notifier).clearError();
    });
  }

  Future<void> onJoinPressed() async {
    final String? result = await ref
        .read(tripControllerProvider.notifier)
        .joinTrip(codeController.text);

    if (result == null || !mounted) {
      return;
    }

    String joinedTripId = result;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsView(tripId: joinedTripId),
      ),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TripFormState formState = ref.watch(tripControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Join a Trip')),
      body: ResponsivePage(
        bottomPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the trip code your friend shared with you.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: codeController,
              label: 'Trip Code',
              hint: 'ROAD-8821',
            ),
            if (formState.errorMessage != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  formState.errorMessage,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            CustomButton(
              text: 'Join Trip',
              isLoading: formState.isLoading,
              onPressed: onJoinPressed,
            ),
          ],
        ),
      ),
    );
  }
}