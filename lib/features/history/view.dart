import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsync/core/shared/responsive_page.dart';
import 'package:roadsync/core/theme/app_colors.dart';
import 'package:roadsync/features/trip/controller/controller.dart';
import 'package:roadsync/features/trip/model.dart';
import 'package:roadsync/features/trip/screens/trip_detail_view.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<TripModel>> tripsAsync = ref.watch(myTripsProvider);

    if (!tripsAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    List<TripModel> allTrips = tripsAsync.value ?? [];
    List<Widget> cards = [];

    for (int i = 0; i < allTrips.length; i++) {
      TripModel trip = allTrips[i];
      if (trip.status != 'ended') {
        continue;
      }

      String tripId = trip.id;

      cards.add(
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsView(tripId: tripId),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.textGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.route,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trip.memberIds.length} members • ${trip.geofenceRadius} m zone',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'ENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (cards.isEmpty) {
      cards.add(
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'No ended trips yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      );
    }

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Trip History',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Column(children: cards),
        ],
      ),
    );
  }
}