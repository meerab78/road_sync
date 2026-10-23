class UserSettings {
  final String name;
  final String email;
  final String emergencyName;
  final String emergencyNumber;
  final int radius;
  final bool notificationsOn;

  UserSettings({
    required this.name,
    required this.email,
    required this.emergencyName,
    required this.emergencyNumber,
    required this.radius,
    required this.notificationsOn,
  });

  factory UserSettings.fromMap(Map<String, dynamic> data) {
    int radius = 20;
    if (data['defaultRadius'] != null) {
      radius = int.parse(data['defaultRadius'].toString());
    }

    bool notificationsOn = true;
    if (data['notificationsOn'] != null) {
      notificationsOn = data['notificationsOn'] == true;
    }

    return UserSettings(
      name: (data['name'] ?? 'User').toString(),
      email: (data['email'] ?? '').toString(),
      emergencyName: (data['emergencyName'] ?? '').toString(),
      emergencyNumber: (data['emergencyNumber'] ?? '').toString(),
      radius: radius,
      notificationsOn: notificationsOn,
    );
  }
}