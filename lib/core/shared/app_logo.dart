import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.directions_car, color: AppColors.white, size: 36),
        ),
        SizedBox(height: 12),
        Text(
          'RoadSync',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Live Tracking & Fleet Safety',
          style: TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
      ],
    );
  }
}