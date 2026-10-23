// Screen 5: Invite Friends. Registered users ki list, Invite button,
// pending invites, aur code share karne ka button.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/shared/custom_button.dart';
import '../../../core/shared/responsive_page.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/controller.dart';
import '../model.dart';
import '../widget/trip_code_card.dart';

class InviteView extends ConsumerWidget {
  final String tripId;

  const InviteView({super.key, required this.tripId});

  Future<void> shareInvite(TripModel trip) async {
    String message = 'Join my trip "${trip.title}" on RoadSync!\n'
        'Trip code: ${trip.code}\n'
        'Open RoadSync, tap "Join Code" and enter this code.';

    await SharePlus.instance.share(ShareParams(text: message));
  }

  // Ek user ki row: avatar, naam, aur right side par koi bhi widget
  Widget buildUserRow({
    required String name,
    required String subtitle,
    required Widget trailing,
  }) {
    String letter = '?';
    if (name != '') {
      letter = name.substring(0, 1).toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
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
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<TripModel> tripAsync = ref.watch(tripProvider(tripId));
    AsyncValue<List<AppUser>> usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Friends')),
      body: tripAsync.when(
        data: (trip) {
          // Friends ki list: Joined / Pending / Invite button
          List<Widget> friendRows = [];
          if (usersAsync.hasValue) {
            List<AppUser> users = usersAsync.value ?? [];

            for (int i = 0; i < users.length; i++) {
              AppUser user = users[i];
              Widget trailing;

              if (trip.memberIds.contains(user.id)) {
                trailing = const Text(
                  'Joined',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              } else if (trip.invitedIds.contains(user.id)) {
                trailing = const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              } else {
                trailing = ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(70, 36),
                  ),
                  onPressed: () {
                    ref.read(tripControllerProvider.notifier).inviteUser(
                      tripId: trip.id,
                      userId: user.id,
                      userName: user.name,
                    );
                  },
                  child: const Text('Invite'),
                );
              }

              friendRows.add(
                buildUserRow(
                  name: user.name,
                  subtitle: user.email,
                  trailing: trailing,
                ),
              );
            }
          }

          if (friendRows.isEmpty) {
            friendRows.add(
              const Text(
                'No other users found yet.',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          // Pending invites ki list
          List<Widget> pendingRows = [];
          for (int i = 0; i < trip.invitedIds.length; i++) {
            String invitedId = trip.invitedIds[i];
            String invitedName = trip.invitedNames[invitedId] ?? 'User';

            pendingRows.add(
              buildUserRow(
                name: invitedName,
                subtitle: 'Invite sent',
                trailing: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }

          if (pendingRows.isEmpty) {
            pendingRows.add(
              const Text(
                'No pending invites.',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          return ResponsivePage(
            bottomPadding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Share this code with friends to join tracking.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      TripCodeCard(code: trip.code),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                buildLabel('INVITE VIA SOCIAL'),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Share Code via WhatsApp / SMS',
                  color: AppColors.green,
                  onPressed: () {
                    shareInvite(trip);
                  },
                ),
                const SizedBox(height: 20),
                buildLabel('FRIENDS ON ROADSYNC'),
                const SizedBox(height: 10),
                Column(children: friendRows),
                const SizedBox(height: 16),
                buildLabel('PENDING INVITES'),
                const SizedBox(height: 10),
                Column(children: pendingRows),
              ],
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}