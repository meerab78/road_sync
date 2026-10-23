import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteInfo {
  final LatLng start;
  final LatLng end;
  final List<LatLng> points;
  final double distanceKm;
  final double minutes;

  RouteInfo({
    required this.start,
    required this.end,
    required this.points,
    required this.distanceKm,
    required this.minutes,
  });

  String get summary {
    String time = '${minutes.round()} min';
    if (minutes >= 60) {
      int hours = minutes ~/ 60;
      int mins = (minutes % 60).round();
      time = '$hours h $mins min';
    }
    return '${distanceKm.toStringAsFixed(1)} km • $time';
  }
}

class RouteService {
  // Jagah ka naam -> latitude/longitude
  Future<LatLng?> geocode(String place) async {
    Uri uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': place,
      'format': 'json',
      'limit': '1',
    });

    http.Response response = await http.get(
      uri,
      headers: {'User-Agent': 'RoadSyncApp/1.0'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    List<dynamic> list = jsonDecode(response.body);
    if (list.isEmpty) {
      return null;
    }

    double lat = double.parse(list[0]['lat'].toString());
    double lon = double.parse(list[0]['lon'].toString());
    return LatLng(lat, lon);
  }

  Future<RouteInfo?> getRoute(String departure, String destination) async {
    try {
      LatLng? start = await geocode(departure);
      // Nominatim ek second mein ek request chahta hai
      await Future.delayed(const Duration(milliseconds: 1100));
      LatLng? end = await geocode(destination);

      if (start == null || end == null) {
        return null;
      }

      String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }

      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> routes = data['routes'] ?? [];
      if (routes.isEmpty) {
        return null;
      }

      Map<String, dynamic> route = routes[0];
      List<dynamic> coords = route['geometry']['coordinates'];

      List<LatLng> points = [];
      for (int i = 0; i < coords.length; i++) {
        double lon = double.parse(coords[i][0].toString());
        double lat = double.parse(coords[i][1].toString());
        points.add(LatLng(lat, lon));
      }

      double meters = double.parse(route['distance'].toString());
      double seconds = double.parse(route['duration'].toString());

      return RouteInfo(
        start: start,
        end: end,
        points: points,
        distanceKm: meters / 1000,
        minutes: seconds / 60,
      );
    } catch (e) {
      return null;
    }
  }
}

// key = "departure|destination". Ek baar aane par cache ho jata hai.
final routeProvider = FutureProvider.family<RouteInfo?, String>((ref, key) {
  List<String> parts = key.split('|');
  return RouteService().getRoute(parts[0], parts[1]);
});