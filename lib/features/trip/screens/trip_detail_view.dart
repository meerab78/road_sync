// Screen 4: Trip Details. Code, members, aur admin ke Start / End buttons.
// Data Firestore se live aata hai, to koi member join kare to list khud update hoti hai.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared/custom_button.dart';
import '../../../core/shared/responsive_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../map/live_map_view.dart';
import '../controller/controller.dart';
import '../model.dart';
import '../widget/member_tile.dart';
import '../widget/trip_code_card.dart';
import 'invite_view.dart';

class TripDetailsView extends ConsumerStatefulWidget {
  final String tripId;
  const TripDetailsView({super.key, required this.tripId});
  @override
  ConsumerState<TripDetailsView> createState() => _TripDetailsViewState();
}
class _TripDetailsViewState extends ConsumerState<TripDetailsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tripControllerProvider.notifier).clearError();
    });
  }

  String getStatusText(String status) {
    if (status == 'started') {
      return 'LIVE';
    }
    if (status == 'ended') {
      return 'ENDED';
    }
    return 'NOT STARTED';
  }

  Future<void> confirmEndTrip() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('End Trip?'),
          content: const Text('This will end the trip for all members.'),
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
              child: const Text('End Trip'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await ref.read(tripControllerProvider.notifier).endTrip(widget.tripId);
    }
  }
  Widget buildContent(TripModel trip, String myId, TripFormState formState) {
    bool isAdmin = trip.adminId == myId;
    // Members ki list banao
    List<Widget> memberTiles = [];
    for (int i = 0; i < trip.memberIds.length; i++) {
      String memberId = trip.memberIds[i];
      String memberName = trip.memberNames[memberId] ?? 'Member';

      memberTiles.add(
        MemberTile(
          name: memberName,
          isAdmin: memberId == trip.adminId,
          isMe: memberId == myId,
        ),
      );
    }

    // Neeche ke buttons / message
    List<Widget> bottomWidgets = [];

    if (trip.status == 'ended') {
      bottomWidgets.add(
        const Text(
          'This trip has ended.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    } else if (isAdmin) {
      if (trip.status == 'created') {
        bottomWidgets.add(
          CustomButton(
            text: '▶ Start Trip For Members',
            color: AppColors.green,
            isLoading: formState.isLoading,
            onPressed: () {
              ref.read(tripControllerProvider.notifier).startTrip(trip.id);
            },
          ),
        );
        bottomWidgets.add(const SizedBox(height: 10));
      }

      bottomWidgets.add(
        CustomButton(
          text: '■ End Trip Permanently',
          color: AppColors.lightRed,
          textColor: AppColors.red,
          onPressed: confirmEndTrip,
        ),
      );
    } else {
      String message = 'Waiting for the admin to start the trip.';
      if (trip.status == 'started') {
        message = 'The trip is live!';
      }
      bottomWidgets.add(
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textGrey),
        ),
      );
    }

    return ResponsivePage(
      bottomPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dark card: title, route, status, code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getStatusText(trip.status),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  trip.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Route: ${trip.route}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (trip.pickupPoint != '')
                  Text(
                    'Pickup: ${trip.pickupPoint}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (trip.stayAt != '')
                  Text(
                    'Stay: ${trip.stayAt}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                Text(
                  'Geofence: ${trip.geofenceRadius} m',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),
                TripCodeCard(code: trip.code),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'TRIP MEMBERS (${trip.memberIds.length} JOINED)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 10),
          Column(children: memberTiles),
          const SizedBox(height: 6),
          if (trip.status != 'ended')
            CustomButton(
              text: 'Invite Friends',
              color: AppColors.white,
              textColor: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InviteView(tripId: trip.id),
                  ),
                );
              },
            ),
          if (trip.status == 'started')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomButton(
                text: 'Open Live Map',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveMapView(tripId: trip.id),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          if (formState.errorMessage != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                formState.errorMessage,
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          Column(children: bottomWidgets),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<TripModel> tripAsync = ref.watch(tripProvider(widget.tripId));
    String myId = ref.watch(currentUserIdProvider);
    TripFormState formState = ref.watch(tripControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: tripAsync.when(
        data: (trip) {
          return buildContent(trip, myId, formState);
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