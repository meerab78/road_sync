import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../model.dart';

class LocationService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Permission check. Sab theek ho to '' wapas, warna error message.
  Future<String> checkPermission() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return 'Please turn on GPS (location) on your phone';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'Location permission was denied';
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Location permission is blocked. Enable it from phone settings';
    }

    return '';
  }

  Stream<Position> positionStream() {
    LocationSettings settings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'RoadSync',
        notificationText: 'Sharing your live location with trip members',
        enableWakeLock: true,
      ),
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  // Meri location Firestore mein save
  Future<void> saveLocation({
    required String tripId,
    required String userId,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    DocumentReference<Map<String, dynamic>> doc = firestore
        .collection('trips')
        .doc(tripId)
        .collection('locations')
        .doc(userId);

    await doc.set({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Trip ke saare members ki locations (live)
  Stream<List<MemberLocation>> watchLocations(String tripId) async* {
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = firestore
        .collection('trips')
        .doc(tripId)
        .collection('locations')
        .snapshots();

    await for (QuerySnapshot<Map<String, dynamic>> snapshot in snapshots) {
      List<MemberLocation> list = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          list.add(MemberLocation.fromMap(doc.id, data));
        }
      }

      yield list;
    }
  }
}