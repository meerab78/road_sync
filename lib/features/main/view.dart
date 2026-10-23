// Ye file bottom navigation bar dikhati hai (Home, History, Settings)
// aur tab ke hisab se page badalti hai.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../history/view.dart';
import '../home/home_view.dart';
import '../map/live_map_view.dart';
import '../settings/view.dart';
import '../trip/controller/controller.dart';
import '../trip/model.dart';
import 'controller.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  // Number ke hisab se page chunna: 0 = Home, 1 = History, 2 = Settings
  Widget getPage(int index) {
    if (index == 1) {
      return const HistoryView();
    }
    if (index == 2) {
      return const SettingsView();
    }
    return const HomeView();
  }

  // Nav bar ka ek item (icon + naam) banata hai
  Widget buildItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int selectedIndex,
    required MainController controller,
  }) {
    bool selected = selectedIndex == index;
    Color color = selected ? AppColors.primary : AppColors.textGrey;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          controller.changeTab(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.watch(mainControllerProvider);
    MainController controller = ref.read(mainControllerProvider.notifier);
    // Jab koi trip 'created' se 'started' ho, to map khud khul jaye
    ref.listen<AsyncValue<List<TripModel>>>(myTripsProvider, (previous, next) {
      if (previous == null || !previous.hasValue || !next.hasValue) {
        return;
      }

      List<TripModel> oldTrips = previous.value ?? [];
      List<TripModel> newTrips = next.value ?? [];

      for (int i = 0; i < newTrips.length; i++) {
        TripModel newTrip = newTrips[i];
        if (newTrip.status != 'started') {
          continue;
        }

        for (int j = 0; j < oldTrips.length; j++) {
          bool sameTrip = oldTrips[j].id == newTrip.id;
          if (sameTrip && oldTrips[j].status != 'started') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveMapView(tripId: newTrip.id),
              ),
            );
          }
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Page poori screen leta hai, content upar se shuru hota hai
          Positioned.fill(
            child: getPage(selectedIndex),
          ),

          // Floating nav bar neeche
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F0F172A),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        buildItem(
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home,
                          label: 'Home',
                          index: 0,
                          selectedIndex: selectedIndex,
                          controller: controller,
                        ),
                        buildItem(
                          icon: Icons.history,
                          selectedIcon: Icons.history,
                          label: 'History',
                          index: 1,
                          selectedIndex: selectedIndex,
                          controller: controller,
                        ),
                        buildItem(
                          icon: Icons.settings_outlined,
                          selectedIcon: Icons.settings,
                          label: 'Settings',
                          index: 2,
                          selectedIndex: selectedIndex,
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}