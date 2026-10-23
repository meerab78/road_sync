// Trip ka code dikhata hai aur Copy button deta hai.
// Trip Details aur Invite dono screens mein use hota hai.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripCodeCard extends StatelessWidget {
  final String code;

  const TripCodeCard({super.key, required this.code});

  Future<void> copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            'CODE:',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              code,
              style: const TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              copyCode(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}