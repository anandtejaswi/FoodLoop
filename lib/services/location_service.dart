// ============================================================
// services/location_service.dart  –  GPS + OSM Geocoding
// ============================================================

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationService {
  // ─── Singleton ───────────────────────────────────────────────
  LocationService._();
  static final LocationService instance = LocationService._();

  // Nominatim OSM reverse-geocoding base URL
  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';

  // ─── Request permission & get current position ───────────────
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // ─── Convert LatLng → human-readable address (OSM Nominatim) ─
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        '$_nominatimBase/reverse?format=json&lat=$lat&lon=$lng&zoom=16&addressdetails=1',
      );
      final resp = await http.get(url, headers: {'User-Agent': 'FoodLoopApp/1.0'});
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return json['display_name'] as String? ?? 'Unknown location';
      }
    } catch (_) {}
    return 'Unknown location';
  }

  // ─── Convert address string → LatLng (OSM Nominatim search) ──
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      final url = Uri.parse(
        '$_nominatimBase/search?format=json&q=${Uri.encodeComponent(address)}&limit=1',
      );
      final resp = await http.get(url, headers: {'User-Agent': 'FoodLoopApp/1.0'});
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          return LatLng(
            double.parse(first['lat'] as String),
            double.parse(first['lon'] as String),
          );
        }
      }
    } catch (_) {}
    return null;
  }

  // ─── Calculate distance between two points (metres) ──────────
  double distanceBetween(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // ─── Format distance for UI display ──────────────────────────
  String formatDistance(double metres) {
    if (metres < 1000) return '${metres.toStringAsFixed(0)} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }
}
