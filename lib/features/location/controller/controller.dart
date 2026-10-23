import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model.dart';
import '../service/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationsProvider = StreamProvider.autoDispose
    .family<List<MemberLocation>, String>((ref, tripId) {
  LocationService service = ref.watch(locationServiceProvider);
  return service.watchLocations(tripId);
});