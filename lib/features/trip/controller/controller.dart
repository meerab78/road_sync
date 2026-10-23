import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model.dart';
import '../service/trip_service.dart' show TripService;

// ---------- Providers ----------

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService();
});

// Current user ki id
final currentUserIdProvider = Provider<String>((ref) {
  TripService service = ref.watch(tripServiceProvider);
  return service.getCurrentUserId();
});

// Meri saari trips (live)
final myTripsProvider = StreamProvider.autoDispose<List<TripModel>>((ref) {
  TripService service = ref.watch(tripServiceProvider);
  return service.watchMyTrips();
});

// Ek trip (live), id dene par milti hai
final tripProvider =
StreamProvider.autoDispose.family<TripModel, String>((ref, tripId) {
  TripService service = ref.watch(tripServiceProvider);
  return service.watchTrip(tripId);
});

// Firebase ke saare users (invite list ke liye)
final usersProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  TripService service = ref.watch(tripServiceProvider);
  return service.watchUsers();
});

// Mujhe jo trips ke invites aaye hain
final myInvitesProvider = StreamProvider.autoDispose<List<TripModel>>((ref) {
  TripService service = ref.watch(tripServiceProvider);
  return service.watchMyInvites();
});

// Home par dikhane ke liye: pehle live trip, warna jo abhi start nahi hui
TripModel? findActiveTrip(List<TripModel> trips) {
  for (int i = 0; i < trips.length; i++) {
    if (trips[i].status == 'started') {
      return trips[i];
    }
  }

  for (int i = 0; i < trips.length; i++) {
    if (trips[i].status == 'created') {
      return trips[i];
    }
  }

  return null;
}

String cleanError(Object error) {
  String message = error.toString();
  return message.replaceFirst('Exception: ', '');
}

// ---------- Screen ki halat (loading aur error) ----------

class TripFormState {
  final bool isLoading;
  final String errorMessage;

  const TripFormState({this.isLoading = false, this.errorMessage = ''});
}

class TripController extends Notifier<TripFormState> {
  @override
  TripFormState build() {
    return const TripFormState();
  }

  void clearError() {
    state = const TripFormState();
  }

  Future<String?> createTrip({
    required String title,
    required String departure,
    required String destination,
    required String pickupPoint,
    required String stayAt,
    required int radius,
  }) async {
    if (title == '' || departure == '' || destination == '') {
      state = const TripFormState(
        errorMessage: 'Please fill trip title, departure and destination',
      );
      return null;
    }

    state = const TripFormState(isLoading: true);

    try {
      String tripId = await ref.read(tripServiceProvider).createTrip(
        title: title,
        departure: departure,
        destination: destination,
        pickupPoint: pickupPoint,
        stayAt: stayAt,
        radius: radius,
      );
      state = const TripFormState();
      return tripId;
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
      return null;
    }
  }

  Future<String?> joinTrip(String code) async {
    String cleanCode = code.trim().toUpperCase();

    if (cleanCode == '') {
      state = const TripFormState(errorMessage: 'Please enter the trip code');
      return null;
    }

    state = const TripFormState(isLoading: true);

    try {
      String tripId = await ref.read(tripServiceProvider).joinTrip(cleanCode);
      state = const TripFormState();
      return tripId;
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
      return null;
    }
  }

  Future<void> startTrip(String tripId) async {
    state = const TripFormState(isLoading: true);

    try {
      await ref.read(tripServiceProvider).startTrip(tripId);
      state = const TripFormState();
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
    }
  }

  Future<void> endTrip(String tripId) async {
    state = const TripFormState(isLoading: true);

    try {
      await ref.read(tripServiceProvider).endTrip(tripId);
      state = const TripFormState();
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
    }
  }
  Future<void> inviteUser({
    required String tripId,
    required String userId,
    required String userName,
  }) async {
    try {
      await ref.read(tripServiceProvider).inviteUser(tripId, userId, userName);
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
    }
  }

  Future<bool> acceptInvite(String tripId) async {
    try {
      await ref.read(tripServiceProvider).acceptInvite(tripId);
      return true;
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
      return false;
    }
  }

  Future<void> declineInvite(String tripId) async {
    try {
      await ref.read(tripServiceProvider).declineInvite(tripId);
    } catch (e) {
      state = TripFormState(errorMessage: cleanError(e));
    }
  }
}

final tripControllerProvider =
NotifierProvider<TripController, TripFormState>(() {
  return TripController();
});