// Home Dashboard. Trip, invites, quick controls aur SOS card.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/features/settings/controller/controller.dart';
import 'package:roadsync/features/settings/model.dart';
import 'package:roadsync/features/sos/view/sos_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../core/shared/custom_button.dart';
import '../../core/shared/responsive_page.dart';
import '../location/share_location_helper.dart';
import '../map/live_map_view.dart';
import '../trip/controller/controller.dart';
import '../trip/model.dart';
import '../trip/screens/create_trip_view.dart';
import '../trip/screens/join_trip_view.dart';
import '../trip/screens/trip_detail_view.dart';
import 'controller.dart';
import 'widgets/active_trip_card.dart';
import 'widgets/home_header.dart';
import 'widgets/invite_card.dart';
import 'widgets/no_trip_card.dart';
import 'widgets/quick_control_card.dart';
import 'widgets/sos_contact_card.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  // Invite accept karo, kamyab ho to Trip Details khol do
  Future<void> acceptAndOpen(
      BuildContext context,
      WidgetRef ref,
      String tripId,
      ) async {
    bool ok = await ref
        .read(tripControllerProvider.notifier)
        .acceptInvite(tripId);

    if (ok && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailsView(tripId: tripId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Settings se emergency number aur radius
    AsyncValue<UserSettings> settingsAsync = ref.watch(settingsProvider);
    String sosNumber = 'Not set - open Settings';
    int radius = 20;
    if (settingsAsync.hasValue) {
      UserSettings settings = settingsAsync.value!;
      if (settings.emergencyNumber != '') {
        sosNumber = settings.emergencyNumber;
      }
      radius = settings.radius;
    }

    // User ka naam
    AsyncValue<String> userName = ref.watch(userNameProvider);
    String name = '';
    if (userName.hasValue) {
      name = userName.value.toString();
    }

    // Active trip dhoondo
    AsyncValue<List<TripModel>> tripsAsync = ref.watch(myTripsProvider);
    TripModel? activeTrip;
    if (tripsAsync.hasValue) {
      List<TripModel> trips = tripsAsync.value ?? [];
      activeTrip = findActiveTrip(trips);
    }

    // Mujhe aaye huay invites
    AsyncValue<List<TripModel>> invitesAsync = ref.watch(myInvitesProvider);
    List<Widget> inviteCards = [];

    if (invitesAsync.hasValue) {
      List<TripModel> invites = invitesAsync.value ?? [];
      for (int i = 0; i < invites.length; i++) {
        TripModel invite = invites[i];
        String inviteId = invite.id;

        inviteCards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InviteCard(
              title: invite.title,
              fromName: invite.adminName,
              onAccept: () {
                acceptAndOpen(context, ref, inviteId);
              },
              onDecline: () {
                ref
                    .read(tripControllerProvider.notifier)
                    .declineInvite(inviteId);
              },
            ),
          ),
        );
      }
    }

    if (invitesAsync.hasError) {
      inviteCards.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Invite error: ${invitesAsync.error}',
            style: const TextStyle(color: AppColors.red),
          ),
        ),
      );
    }

    // Trip card: trip hai to ActiveTripCard, warna NoTripCard
    Widget tripCard;
    if (activeTrip == null) {
      tripCard = const NoTripCard();
    } else {
      String tripId = activeTrip.id;
      bool isLive = activeTrip.status == 'started';

      String statusText = '• NOT STARTED';
      String buttonText = 'View Trip';
      if (isLive) {
        statusText = '• LIVE';
        buttonText = 'Live Trip';
      }

      tripCard = ActiveTripCard(
        title: activeTrip.title,
        route: activeTrip.route,
        statusText: statusText,
        buttonText: buttonText,
        onPressed: () {
          if (isLive) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveMapView(tripId: tripId),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsView(tripId: tripId),
              ),
            );
          }
        },
      );
    }

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(name: name),
          const SizedBox(height: 16),
          Column(children: inviteCards),
          tripCard,
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '+ Create Trip',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTripView(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Join Code',
                  color: AppColors.white,
                  textColor: AppColors.textDark,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinTripView(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'QUICK CONTROLS & SAFETY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickControlCard(
                  icon: Icons.location_on,
                  iconColor: AppColors.red,
                  iconBackground: AppColors.lightRed,
                  title: 'Share Location',
                  subtitle: 'WhatsApp / SMS',
                  subtitleColor: AppColors.textGrey,
                  onTap: () {
                    shareMyLocation(context, name);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickControlCard(
                  icon: Icons.shield,
                  iconColor: AppColors.primary,
                  iconBackground: const Color(0xFFDBEAFE),
                  title: 'Geofence Zone',
                  subtitle: 'Set ${radius}m Radius',
                  subtitleColor: AppColors.green,                  onTap: () {
    int newRadius = 5;
    if (radius == 5) {
    newRadius = 20;
    } else if (radius == 20) {
    newRadius = 50;
    }
    ref
        .read(settingsControllerProvider.notifier)
        .saveRadius(newRadius);
    },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SosContactCard(
            contactNumber: sosNumber,
            onTap: () {
              triggerSos(context, ref);
            },
          ),
        ],
      ),
    );
  }
}