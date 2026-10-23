class TripModel {
  final String id;
  final String title;
  final String departure;
  final String destination;
  final String pickupPoint;
  final String stayAt;
  final int geofenceRadius;
  final String adminId;
  final String adminName;
  final String code;
  final String status; // created, started ya ended
  final List<String> memberIds;
  final Map<String, String> memberNames;
  final List<String> invitedIds;
  final Map<String, String> invitedNames;

  TripModel({
    required this.id,
    required this.title,
    required this.departure,
    required this.destination,
    required this.pickupPoint,
    required this.stayAt,
    required this.geofenceRadius,
    required this.adminId,
    required this.adminName,
    required this.code,
    required this.status,
    required this.memberIds,
    required this.memberNames,
    required this.invitedIds,
    required this.invitedNames,
  });

  String get route {
    return '$departure → $destination';
  }

  factory TripModel.fromMap(String id, Map<String, dynamic> data) {
    // members ki id list
    List<String> ids = [];
    List<dynamic> rawIds = data['memberIds'] ?? [];
    for (int i = 0; i < rawIds.length; i++) {
      ids.add(rawIds[i].toString());
    }

    // members ke naam (id -> naam)
    Map<String, String> names = {};
    Map<String, dynamic> rawNames = data['memberNames'] ?? {};
    for (String key in rawNames.keys) {
      names[key] = rawNames[key].toString();
    }

    // invite kiye huay users
    List<String> invIds = [];
    List<dynamic> rawInvIds = data['invitedIds'] ?? [];
    for (int i = 0; i < rawInvIds.length; i++) {
      invIds.add(rawInvIds[i].toString());
    }

    Map<String, String> invNames = {};
    Map<String, dynamic> rawInvNames = data['invitedNames'] ?? {};
    for (String key in rawInvNames.keys) {
      invNames[key] = rawInvNames[key].toString();
    }

    int radius = 20;
    if (data['geofenceRadius'] != null) {
      radius = int.parse(data['geofenceRadius'].toString());
    }

    return TripModel(
      id: id,
      title: (data['title'] ?? '').toString(),
      departure: (data['departure'] ?? '').toString(),
      destination: (data['destination'] ?? '').toString(),
      pickupPoint: (data['pickupPoint'] ?? '').toString(),
      stayAt: (data['stayAt'] ?? '').toString(),
      geofenceRadius: radius,
      adminId: (data['adminId'] ?? '').toString(),
      adminName: (data['adminName'] ?? '').toString(),
      code: (data['code'] ?? '').toString(),
      status: (data['status'] ?? 'created').toString(),
      memberIds: ids,
      memberNames: names,
      invitedIds: invIds,
      invitedNames: invNames,
    );
  }
}

// Firebase mein register hua ek user (invite list ke liye)
class AppUser {
  final String id;
  final String name;
  final String email;

  AppUser({required this.id, required this.name, required this.email});
}