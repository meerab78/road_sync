
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model.dart';

class TripService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  String getCurrentUserId() {
    User? user = auth.currentUser;
    if (user == null) {
      return '';
    }
    return user.uid;
  }

  // Users collection se current user ka naam lata hai
  Future<String> getCurrentUserName() async {
    User? user = auth.currentUser;
    if (user == null) {
      return 'User';
    }

    DocumentSnapshot<Map<String, dynamic>> doc =
    await firestore.collection('users').doc(user.uid).get();

    Map<String, dynamic>? data = doc.data();
    if (data == null) {
      return 'User';
    }
    return data['name'].toString();
  }

  // ROAD-1234 jaisa code banata hai, aur check karta hai ke pehle se na ho
  Future<String> createUniqueCode() async {
    Random random = Random();

    while (true) {
      int number = 1000 + random.nextInt(9000);
      String code = 'ROAD-$number';

      Query<Map<String, dynamic>> query = firestore.collection('trips');
      query = query.where('code', isEqualTo: code);
      query = query.limit(1);
      QuerySnapshot<Map<String, dynamic>> result = await query.get();

      if (result.docs.isEmpty) {
        return code;
      }
    }
  }

  // Naya trip banata hai aur trip ki id wapas karta hai
  Future<String> createTrip({
    required String title,
    required String departure,
    required String destination,
    required String pickupPoint,
    required String stayAt,
    required int radius,
  }) async {
    User? user = auth.currentUser;
    if (user == null) {
      throw Exception('Please login first');
    }

    String name = await getCurrentUserName();
    String code = await createUniqueCode();

    CollectionReference<Map<String, dynamic>> trips =
    firestore.collection('trips');
    DocumentReference<Map<String, dynamic>> newTrip = trips.doc();

    await newTrip.set({
      'title': title,
      'departure': departure,
      'destination': destination,
      'pickupPoint': pickupPoint,
      'stayAt': stayAt,
      'geofenceRadius': radius,
      'adminId': user.uid,
      'adminName': name,
      'code': code,
      'status': 'created',
      'memberIds': [user.uid],
      'memberNames': {user.uid: name},
      'createdAt': DateTime.now().toString(),
    });

    return newTrip.id;
  }

  // Code se trip dhoondta hai aur user ko member bana deta hai
  Future<String> joinTrip(String code) async {
    User? user = auth.currentUser;
    if (user == null) {
      throw Exception('Please login first');
    }

    Query<Map<String, dynamic>> query = firestore.collection('trips');
    query = query.where('code', isEqualTo: code);
    query = query.limit(1);
    QuerySnapshot<Map<String, dynamic>> result = await query.get();

    if (result.docs.isEmpty) {
      throw Exception('Trip not found. Please check the code.');
    }

    QueryDocumentSnapshot<Map<String, dynamic>> doc = result.docs.first;
    Map<String, dynamic> data = doc.data();

    if (data['status'] == 'ended') {
      throw Exception('This trip has already ended.');
    }

    String name = await getCurrentUserName();

    await doc.reference.update({
      'memberIds': FieldValue.arrayUnion([user.uid]),
      'memberNames.${user.uid}': name,
    });

    return doc.id;
  }

  Future<void> startTrip(String tripId) async {
    await firestore.collection('trips').doc(tripId).update({
      'status': 'started',
    });
  }

  Future<void> endTrip(String tripId) async {
    await firestore.collection('trips').doc(tripId).update({
      'status': 'ended',
    });
  }

  // Ek trip ko live sunta rehta hai (badalte hi screen update)
  Stream<TripModel> watchTrip(String tripId) async* {
    DocumentReference<Map<String, dynamic>> tripRef =
    firestore.collection('trips').doc(tripId);

    Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
    tripRef.snapshots();

    await for (DocumentSnapshot<Map<String, dynamic>> doc in snapshots) {
      Map<String, dynamic>? data = doc.data();
      if (data != null) {
        yield TripModel.fromMap(doc.id, data);
      }
    }
  }

  // Wo saari trips jin mein user member hai
  Stream<List<TripModel>> watchMyTrips() async* {
    User? user = auth.currentUser;
    if (user == null) {
      return;
    }

    Query<Map<String, dynamic>> query = firestore.collection('trips');
    query = query.where('memberIds', arrayContains: user.uid);

    Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = query.snapshots();

    await for (QuerySnapshot<Map<String, dynamic>> snapshot in snapshots) {
      List<TripModel> trips = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        trips.add(TripModel.fromMap(doc.id, doc.data()));
      }

      yield trips;
    }
  }
  // Saare registered users (apne ilawa)
  Stream<List<AppUser>> watchUsers() async* {
    String myId = getCurrentUserId();

    Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
    firestore.collection('users').snapshots();

    await for (QuerySnapshot<Map<String, dynamic>> snapshot in snapshots) {
      List<AppUser> users = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        if (doc.id != myId) {
          Map<String, dynamic> data = doc.data();
          users.add(
            AppUser(
              id: doc.id,
              name: (data['name'] ?? 'User').toString(),
              email: (data['email'] ?? '').toString(),
            ),
          );
        }
      }

      yield users;
    }
  }

  // Kisi user ko trip mein invite karta hai (pending mein jata hai)
  Future<void> inviteUser(String tripId, String userId, String userName) async {
    await firestore.collection('trips').doc(tripId).update({
      'invitedIds': FieldValue.arrayUnion([userId]),
      'invitedNames.$userId': userName,
    });
  }

  // Wo trips jin mein mujhe invite kiya gaya hai
  Stream<List<TripModel>> watchMyInvites() async* {
    User? user = auth.currentUser;
    if (user == null) {
      return;
    }

    Query<Map<String, dynamic>> query = firestore.collection('trips');
    query = query.where('invitedIds', arrayContains: user.uid);

    Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = query.snapshots();

    await for (QuerySnapshot<Map<String, dynamic>> snapshot in snapshots) {
      List<TripModel> trips = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        TripModel trip = TripModel.fromMap(doc.id, doc.data());
        if (trip.status != 'ended') {
          trips.add(trip);
        }
      }

      yield trips;
    }
  }

  // Invite accept: member ban jao, pending se hata do
  Future<void> acceptInvite(String tripId) async {
    User? user = auth.currentUser;
    if (user == null) {
      throw Exception('Please login first');
    }

    String name = await getCurrentUserName();

    await firestore.collection('trips').doc(tripId).update({
      'memberIds': FieldValue.arrayUnion([user.uid]),
      'memberNames.${user.uid}': name,
      'invitedIds': FieldValue.arrayRemove([user.uid]),
      'invitedNames.${user.uid}': FieldValue.delete(),
    });
  }

  // Invite decline: sirf pending se hata do
  Future<void> declineInvite(String tripId) async {
    User? user = auth.currentUser;
    if (user == null) {
      throw Exception('Please login first');
    }

    await firestore.collection('trips').doc(tripId).update({
      'invitedIds': FieldValue.arrayRemove([user.uid]),
      'invitedNames.${user.uid}': FieldValue.delete(),
    });
  }
}