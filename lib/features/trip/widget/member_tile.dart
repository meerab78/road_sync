// Members list ki ek row: avatar, naam, aur Admin/Member.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MemberTile extends StatelessWidget {
  final String name;
  final bool isAdmin;
  final bool isMe;

  const MemberTile({
    super.key,
    required this.name,
    required this.isAdmin,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    String letter = '?';
    if (name != '') {
      letter = name.substring(0, 1).toUpperCase();
    }

    String displayName = name;
    if (isMe) {
      displayName = '$name (You)';
    }

    String role = 'Member';
    Color roleColor = AppColors.textGrey;
    if (isAdmin) {
      role = 'Admin / Leader';
      roleColor = AppColors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFDBEAFE),
            child: Text(
              letter,
              style: const TextStyle(
                color: AppColors.primary,
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
                  displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(fontSize: 11, color: roleColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}