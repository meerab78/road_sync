// Screen 7: Settings. Profile, emergency contact, radius,
// notifications toggle aur logout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/core/shared/custom_button.dart';
import 'package:roadsync/core/shared/responsive_page.dart';
import 'package:roadsync/core/theme/app_colors.dart';
import 'package:roadsync/features/auth/controller/controller.dart';
import 'package:roadsync/features/settings/controller/controller.dart';
import 'package:roadsync/features/settings/model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: AppColors.textGrey,
      ),
    );
  }

  Widget buildRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle != '')
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Future<void> editEmergencyContact(
      BuildContext context,
      WidgetRef ref,
      UserSettings settings,
      ) async {
    TextEditingController nameController =
    TextEditingController(text: settings.emergencyName);
    TextEditingController numberController =
    TextEditingController(text: settings.emergencyNumber);

    bool? saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+92 300 1234567',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      String name = nameController.text.trim();
      String number = numberController.text.trim();
      number = number.replaceAll(' ', '');
      await ref
          .read(settingsControllerProvider.notifier)
          .saveEmergencyContact(name, number);
    }
  }

  Widget buildRadiusChoice(
      WidgetRef ref,
      int value,
      int currentRadius,
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text('$value m'),
        selected: currentRadius == value,
        onSelected: (selected) {
          ref.read(settingsControllerProvider.notifier).saveRadius(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<UserSettings> settingsAsync = ref.watch(settingsProvider);

    if (!settingsAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    UserSettings settings = settingsAsync.value!;

    String letter = '?';
    if (settings.name != '') {
      letter = settings.name.substring(0, 1).toUpperCase();
    }

    String contactText = 'Not set';
    if (settings.emergencyNumber != '') {
      contactText = settings.emergencyNumber;
      if (settings.emergencyName != '') {
        contactText = '${settings.emergencyName} • ${settings.emergencyNumber}';
      }
    }

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        settings.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          buildLabel('PREFERENCES'),
          const SizedBox(height: 10),
          buildRow(
            icon: Icons.contact_phone,
            title: 'Emergency Contact',
            subtitle: contactText,
            trailing: TextButton(
              onPressed: () {
                editEmergencyContact(context, ref, settings);
              },
              child: const Text('Edit'),
            ),
          ),
          buildRow(
            icon: Icons.shield,
            title: 'Geofence Radius',
            subtitle: '',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildRadiusChoice(ref, 5, settings.radius),
                buildRadiusChoice(ref, 20, settings.radius),
                buildRadiusChoice(ref, 50, settings.radius),
              ],
            ),
          ),
          buildRow(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: '',
            trailing: Switch(
              value: settings.notificationsOn,
              activeThumbColor: AppColors.green,
              onChanged: (value) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .saveNotifications(value);
              },
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Log Out Account',
            color: AppColors.lightRed,
            textColor: AppColors.red,
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}