
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadsync/features/location/service/location_service.dart';

class SosService {
  // Location le kar SOS ka message banata hai. Masla ho to Exception.
  Future<String> buildMessage(String name) async {
    LocationService locationService = LocationService();
    String permissionError = await locationService.checkPermission();
    if (permissionError != '') {
      throw Exception(permissionError);
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
      throw Exception('Could not get your location. Please try again');
    }

    String link =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    return 'SOS! $name needs help. My location: $link';
  }

  // SIM se khud SMS bhejta hai (Send dabane ki zaroorat nahi)
  // SIM se khud SMS bhejta hai (Send dabane ki zaroorat nahi)
  Future<void> sendSms({required String number, required String name}) async {
    String message = await buildMessage(name);

    const MethodChannel channel = MethodChannel('roadsync/sms');

    try {
      await channel.invokeMethod('sendSms', {
        'number': number,
        'message': message,
      });
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'SMS failed');
    }
  }

  // WhatsApp khol deta hai, message likha hua hota hai (Send khud dabana hai)
  Future<void> openWhatsapp({
    required String number,
    required String name,
  }) async {
    String message = await buildMessage(name);

    String digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      digits = '92${digits.substring(1)}';
    }

    Uri uri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
    );
    bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      throw Exception('Could not open WhatsApp');
    }
  }
}