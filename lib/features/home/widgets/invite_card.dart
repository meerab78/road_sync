import 'package:flutter/material.dart';
import 'package:roadsync/core/shared/custom_button.dart';
import 'package:roadsync/core/theme/app_colors.dart';

class InviteCard extends StatelessWidget {
  final String title;
  final String fromName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InviteCard({
    super.key,
    required this.title,
    required this.fromName,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRIP INVITATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Invited by $fromName',
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Accept',
                  color: AppColors.green,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: 'Decline',
                  color: AppColors.lightRed,
                  textColor: AppColors.red,
                  onPressed: onDecline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}