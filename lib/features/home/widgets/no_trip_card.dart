// Home par ye card dikhta hai jab user ki koi active trip na ho.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NoTripCard extends StatelessWidget {
  const NoTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.route, size: 32, color: AppColors.primary),
          SizedBox(height: 10),
          Text(
            'No active trip',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create a new trip or join one with a code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}