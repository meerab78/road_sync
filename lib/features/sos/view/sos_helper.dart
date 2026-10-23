import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/controller.dart';

Future<void> triggerSos(BuildContext context, WidgetRef ref) async {
  String? choice = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Send SOS?'),
        content: const Text(
          'SMS: sent automatically from your SIM.\n'
              'WhatsApp: opens with the message ready, you tap Send.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, 'cancel');
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, 'whatsapp');
            },
            child: const Text('WhatsApp'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, 'sms');
            },
            child: const Text('Send SMS'),
          ),
        ],
      );
    },
  );

  if (choice != 'sms' && choice != 'whatsapp') {
    return;
  }

  bool viaWhatsapp = choice == 'whatsapp';
  String error =
  await ref.read(sosControllerProvider.notifier).sendSos(viaWhatsapp);

  if (!context.mounted) {
    return;
  }

  String text = error;
  if (error == '' && !viaWhatsapp) {
    text = 'SOS SMS sent';
  }
  if (text != '') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}