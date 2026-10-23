import 'package:cloud_firestore/cloud_firestore.dart';

class MemberLocation {
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  MemberLocation({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  int get secondsAgo {
    return DateTime.now().difference(updatedAt).inSeconds;
  }

  // 60 second se zyada purani location = offline
  bool get isOnline {
    return secondsAgo < 60;
  }

  String get lastSeenText {
    int seconds = secondsAgo;
    if (seconds < 60) {
      return 'Live';
    }
    if (seconds < 3600) {
      int minutes = seconds ~/ 60;
      return 'Last seen $minutes min ago';
    }
    int hours = seconds ~/ 3600;
    return 'Last seen $hours hr ago';
  }

  factory MemberLocation.fromMap(String id, Map<String, dynamic> data) {
    DateTime time = DateTime.now();
    dynamic raw = data['updatedAt'];
    if (raw is Timestamp) {
      time = raw.toDate();
    }

    return MemberLocation(
      userId: id,
      name: (data['name'] ?? 'Member').toString(),
      latitude: double.parse(data['latitude'].toString()),
      longitude: double.parse(data['longitude'].toString()),
      updatedAt: time,
    );
  }
}