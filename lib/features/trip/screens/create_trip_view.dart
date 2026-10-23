// Screen 3: Create Trip. Form bharo aur "Create & Broadcast Trip" dabao.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/features/trip/screens/trip_detail_view.dart';

import '../../../core/shared/custom_button.dart';
import '../../../core/shared/custom_text_field.dart';
import '../../../core/shared/responsive_page.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/controller.dart';

class CreateTripView extends ConsumerStatefulWidget {
  const CreateTripView({super.key});

  @override
  ConsumerState<CreateTripView> createState() => _CreateTripViewState();
}

class _CreateTripViewState extends ConsumerState<CreateTripView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController departureController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController pickupController = TextEditingController();
  TextEditingController stayController = TextEditingController();

  int selectedRadius = 20;

  @override
  void initState() {
    super.initState();
    // Purana error saaf karo (screen khulte hi)
    Future.microtask(() {
      ref.read(tripControllerProvider.notifier).clearError();
    });
  }

  Color getButtonColor(int radius) {
    if (selectedRadius == radius) {
      return AppColors.primary;
    }
    return AppColors.white;
  }

  Color getTextColor(int radius) {
    if (selectedRadius == radius) {
      return AppColors.white;
    }
    return AppColors.textDark;
  }

  Future<void> onCreatePressed() async {
    final String? result =
    await ref.read(tripControllerProvider.notifier).createTrip(
      title: titleController.text.trim(),
      departure: departureController.text.trim(),
      destination: destinationController.text.trim(),
      pickupPoint: pickupController.text.trim(),
      stayAt: stayController.text.trim(),
      radius: selectedRadius,
    );

    if (result == null || !mounted) {
      return;
    }

    String newTripId = result;

    // Create screen hata kar Trip Details kholo
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsView(tripId: newTripId),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    departureController.dispose();
    destinationController.dispose();
    pickupController.dispose();
    stayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TripFormState formState = ref.watch(tripControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trip')),
      body: ResponsivePage(
        bottomPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: titleController,
              label: 'Trip Title',
              hint: 'Northern Trip 2026',
            ),
            CustomTextField(
              controller: departureController,
              label: 'Departure',
              hint: 'Islamabad G-9',
            ),
            CustomTextField(
              controller: destinationController,
              label: 'Destination',
              hint: 'Hunza Valley',
            ),
            CustomTextField(
              controller: pickupController,
              label: 'Pickup Point',
              hint: 'Abbottabad Interchange',
            ),
            CustomTextField(
              controller: stayController,
              label: 'Stay At (Hotel)',
              hint: 'Naran City Hotel',
            ),
            const Text(
              'GEOFENCE SAFE RADIUS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: '5 m',
                    color: getButtonColor(10),
                    textColor: getTextColor(10),
                    onPressed: () {
                      setState(() {
                        selectedRadius = 10;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: '20 m',
                    color: getButtonColor(20),
                    textColor: getTextColor(20),
                    onPressed: () {
                      setState(() {
                        selectedRadius = 20;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: '50 m',
                    color: getButtonColor(50),
                    textColor: getTextColor(50),
                    onPressed: () {
                      setState(() {
                        selectedRadius = 50;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (formState.errorMessage != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  formState.errorMessage,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            CustomButton(
              text: 'Create & Broadcast Trip',
              isLoading: formState.isLoading,
              onPressed: onCreatePressed,
            ),
          ],
        ),
      ),
    );
  }
}