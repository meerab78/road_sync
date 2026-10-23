// Screen 6: Live Map. Sab members ki car, geofence circle,
// red alert, SOS button aur neeche trip status.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadsync/core/theme/app_colors.dart';
import 'package:roadsync/features/location/controller/controller.dart';
import 'package:roadsync/features/location/model.dart';
import 'package:roadsync/features/location/service/location_service.dart';
import 'package:roadsync/features/map/route_service.dart';
import 'package:roadsync/features/trip/controller/controller.dart';
import 'package:roadsync/features/trip/model.dart';

import '../../core/shared/custom_button.dart';
import '../sos/view/sos_helper.dart';

class LiveMapView extends ConsumerStatefulWidget {
  final String tripId;

  const LiveMapView({super.key, required this.tripId});

  @override
  ConsumerState<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends ConsumerState<LiveMapView> {
  late LocationService locationService;
  StreamSubscription<Position>? subscription;
  Timer? timer;
  Position? lastPosition;
  MapController mapController = MapController();

  String myId = '';
  String myName = '';
  String permissionError = '';
  bool mapCentered = false;
  bool closing = false;
  bool routeFitted = false;

  @override
  void initState() {
    super.initState();
    locationService = ref.read(locationServiceProvider);
    myId = ref.read(currentUserIdProvider);
    startSharing();
  }

  @override
  void dispose() {
    stopSharing();
    mapController.dispose();
    super.dispose();
  }

  Future<void> startSharing() async {
    String error = await locationService.checkPermission();
    if (error != '') {
      if (mounted) {
        setState(() {
          permissionError = error;
        });
      }
      return;
    }

    myName = await ref.read(tripServiceProvider).getCurrentUserName();

    // GPS hilne par location save
    subscription = locationService.positionStream().listen((position) {
      lastPosition = position;
      saveMyLocation();
    });

    // Har 15 second: location dobara save (taake khada user offline na lage)
    // aur screen refresh (taake "last seen" time badle)
    timer = Timer.periodic(const Duration(seconds: 15), (t) {
      saveMyLocation();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void stopSharing() {
    subscription?.cancel();
    subscription = null;
    timer?.cancel();
    timer = null;
  }

  // Dhyan: await nahi lagaya, kyunke internet na ho to Firestore
  // write ko queue kar leta hai aur net aate hi bhej deta hai.
  void saveMyLocation() {
    Position? position = lastPosition;
    if (position == null) {
      return;
    }

    locationService.saveLocation(
      tripId: widget.tripId,
      userId: myId,
      name: myName,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  MemberLocation? findLocation(List<MemberLocation> list, String userId) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].userId == userId) {
        return list[i];
      }
    }
    return null;
  }

  // Member admin se radius se zyada door hai?
  bool isOutOfZone(
      MemberLocation member,
      MemberLocation? adminLocation,
      TripModel trip,
      ) {
    if (adminLocation == null) {
      return false;
    }
    if (member.userId == trip.adminId) {
      return false;
    }

    double distance = Geolocator.distanceBetween(
      adminLocation.latitude,
      adminLocation.longitude,
      member.latitude,
      member.longitude,
    );

    return distance > trip.geofenceRadius;
  }

  Widget buildMarker(String name, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(Icons.directions_car, color: color, size: 28),
      ],
    );
  }

  Widget buildMemberRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void moveToMe() {
    Position? position = lastPosition;
    if (position == null) {
      return;
    }
    mapController.move(LatLng(position.latitude, position.longitude), 17);
  }
  Future<void> confirmEndTrip(String tripId) async {
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

    if (confirmed == true) {
      await ref.read(tripControllerProvider.notifier).endTrip(tripId);
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<TripModel> tripAsync = ref.watch(tripProvider(widget.tripId));
    AsyncValue<List<MemberLocation>> locationsAsync =
    ref.watch(locationsProvider(widget.tripId));

    ref.listen<AsyncValue<TripModel>>(tripProvider(widget.tripId),
            (previous, next) {
          if (next.hasValue) {
            TripModel? updated = next.value;
            if (updated != null && updated.status == 'ended' && !closing) {
              closing = true;
              stopSharing();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('The trip has ended')),
              );
              Navigator.pop(context);
            }
          }
        });

    if (!tripAsync.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    TripModel trip = tripAsync.value!;
    List<MemberLocation> locations = [];
    if (locationsAsync.hasValue) {
      locations = locationsAsync.value ?? [];
    }

    MemberLocation? adminLocation = findLocation(locations, trip.adminId);
    AsyncValue<RouteInfo?> routeAsync = ref.watch(
      routeProvider('${trip.departure}|${trip.destination}'),
    );
    RouteInfo? routeInfo;
    if (routeAsync.hasValue) {
      routeInfo = routeAsync.value;
    }

    // Route aate hi camera poore raaste par
    if (routeInfo != null && !routeFitted) {
      routeFitted = true;
      mapCentered = true;
      List<LatLng> routePoints = routeInfo.points;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(routePoints),
            padding: const EdgeInsets.fromLTRB(40, 140, 40, 260),
          ),
        );
      });
    }

    // Markers, out-of-zone names, active count
    List<Marker> markers = [];
    List<String> outNames = [];
    int activeCount = 0;

    for (int i = 0; i < locations.length; i++) {
      MemberLocation member = locations[i];
      bool out = isOutOfZone(member, adminLocation, trip);

      Color color = AppColors.primary;
      String label = member.name;

      if (member.userId == myId) {
        label = '${member.name} (You)';
      }
      if (!member.isOnline) {
        color = AppColors.textGrey;
        label = '$label · ${member.lastSeenText}';
      } else {
        activeCount++;
      }
      if (out) {
        color = AppColors.red;
        outNames.add(member.name);
      }

      markers.add(
        Marker(
          point: LatLng(member.latitude, member.longitude),
          width: 150,
          height: 56,
          child: buildMarker(label, color),
        ),
      );
    }

    // Geofence circle (center = admin)
    List<CircleMarker> circles = [];
    if (adminLocation != null) {
      circles.add(
        CircleMarker(
          point: LatLng(adminLocation.latitude, adminLocation.longitude),
          radius: trip.geofenceRadius.toDouble(),
          useRadiusInMeter: true,
          color: AppColors.primary.withValues(alpha: 0.15),
          borderColor: AppColors.primary,
          borderStrokeWidth: 2,
        ),
      );
    }

    // Map ka shuruati center
    LatLng startCenter = const LatLng(30.3753, 69.3451);
    if (locations.isNotEmpty) {
      startCenter = LatLng(locations[0].latitude, locations[0].longitude);
    }

    // Pehli location milte hi map wahan le jao (sirf ek baar)
    if (!mapCentered && locations.isNotEmpty) {
      mapCentered = true;
      LatLng target = startCenter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.move(target, 17);
      });
    }

    // Neeche sheet ki member rows
    List<Widget> memberRows = [];
    for (int i = 0; i < trip.memberIds.length; i++) {
      String memberId = trip.memberIds[i];
      String memberName = trip.memberNames[memberId] ?? 'Member';
      MemberLocation? loc = findLocation(locations, memberId);

      if (loc == null) {
        memberRows.add(
          buildMemberRow('$memberName (Waiting for location)', AppColors.textGrey),
        );
      } else if (isOutOfZone(loc, adminLocation, trip)) {
        memberRows.add(buildMemberRow('$memberName (Out Zone)', AppColors.red));
      } else if (!loc.isOnline) {
        memberRows.add(
          buildMemberRow('$memberName (${loc.lastSeenText})', AppColors.textGrey),
        );
      } else {
        memberRows.add(buildMemberRow('$memberName (Live)', AppColors.green));
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: startCenter, initialZoom: 17),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.roadsync',
              ),
              if (routeInfo != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeInfo.points,
                      strokeWidth: 5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              if (routeInfo != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: routeInfo.start,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.trip_origin,
                        color: AppColors.green,
                        size: 28,
                      ),
                    ),
                    Marker(
                      point: routeInfo.end,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              CircleLayer(circles: circles),
              MarkerLayer(markers: markers),
            ],
          ),

          // Upar: back button, alerts
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: AppColors.textDark,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const Spacer(),
                      if (myId == trip.adminId)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: AppColors.white,
                          ),
                          onPressed: () {
                            confirmEndTrip(trip.id);
                          },
                          icon: const Icon(Icons.stop_circle, size: 18),
                          label: const Text('End Trip'),
                        ),
                    ],
                  ),
                  if (routeInfo != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${trip.departure} → ${trip.destination}\n${routeInfo.summary}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  if (outNames.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightRed,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠ GEOFENCE ALERT TRIGGERED!',
                            style: TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${outNames.join(', ')} is out of geofence area (${trip.geofenceRadius}m)',
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (permissionError != '')
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        permissionError,
                        style: const TextStyle(color: AppColors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Neeche: my location + SOS + status sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'myLocation',
                        backgroundColor: AppColors.white,
                        onPressed: moveToMe,
                        child: const Icon(
                          Icons.my_location,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'sos',
                        backgroundColor: AppColors.red,
                        onPressed: () {
                          triggerSos(context, ref);
                        },
                        child: const Text(
                          'SOS',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '• $activeCount Members Active • ${outNames.length} Out Alert',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 140),
                          child: SingleChildScrollView(
                            child: Column(children: memberRows),
                          ),
                        ),
                        if (myId == trip.adminId)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: CustomButton(
                              text: '■ End Trip',
                              color: AppColors.lightRed,
                              textColor: AppColors.red,
                              onPressed: () {
                                confirmEndTrip(trip.id);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}