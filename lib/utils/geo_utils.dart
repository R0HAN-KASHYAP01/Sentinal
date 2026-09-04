// FILE: lib/utils/geo_utils.dart
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' as latlng;

class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusKm = 6371.0;

  /// Great-circle distance between two coordinates, in kilometers.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// Point at [bearingDeg] degrees and [distanceKm] km from (lat, lng).
  static latlng.LatLng destinationPoint(
    double lat,
    double lng,
    double bearingDeg,
    double distanceKm,
  ) {
    final angularDistance = distanceKm / _earthRadiusKm;
    final bearing = _degToRad(bearingDeg);
    final lat1 = _degToRad(lat);
    final lng1 = _degToRad(lng);

    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angularDistance) +
          math.cos(lat1) * math.sin(angularDistance) * math.cos(bearing),
    );
    final lng2 = lng1 +
        math.atan2(
          math.sin(bearing) * math.sin(angularDistance) * math.cos(lat1),
          math.cos(angularDistance) - math.sin(lat1) * math.sin(lat2),
        );

    return latlng.LatLng(_radToDeg(lat2), _radToDeg(lng2));
  }

  /// Bounding box that contains a circle of [radiusKm] centered at (lat, lng).
  /// Used to auto-fit the map's initial zoom to the 100 km radius.
  static LatLngBounds boundsForRadius(double lat, double lng, double radiusKm) {
    final north = destinationPoint(lat, lng, 0, radiusKm);
    final south = destinationPoint(lat, lng, 180, radiusKm);
    final east = destinationPoint(lat, lng, 90, radiusKm);
    final west = destinationPoint(lat, lng, 270, radiusKm);

    return LatLngBounds(
      latlng.LatLng(south.latitude, west.longitude),
      latlng.LatLng(north.latitude, east.longitude),
    );
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}