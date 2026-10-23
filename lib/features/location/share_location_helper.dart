import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:roadsync/features/location/service/location_service.dart';

Future<void> shareMyLocation(BuildContext context, String name) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Getting your location...')),
  );

  LocationService locationService = LocationService();
  String error = await locationService.checkPermission();

  if (error != '') {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
    return;
  }

  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  } catch (e) {
    position = await Geolocator.getLastKnownPosition();
  }

  if (position == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location')),
      );
    }
    return;
  }

  String link =
      'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  String who = 'My';
  if (name != '') {
    who = '$name\'s';
  }

  await SharePlus.instance.share(
    ShareParams(text: '$who live location (RoadSync): $link'),
  );
}