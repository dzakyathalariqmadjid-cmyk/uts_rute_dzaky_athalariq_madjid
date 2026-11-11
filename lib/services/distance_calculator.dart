
import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceCalculator {
  // Menghitung jarak antara dua titik koordinat
  static double haversine(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;

    double lat1 = point1.latitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;

    double deltaLat =
        (point2.latitude - point1.latitude) * pi / 180;

    double deltaLng =
        (point2.longitude - point1.longitude) * pi / 180;

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) *
            cos(lat2) *
            sin(deltaLng / 2) *
            sin(deltaLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Menghitung total jarak berdasarkan urutan titik
  static double routeDistance(List<LatLng> points) {
    double totalDistance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += haversine(
        points[i],
        points[i + 1],
      );
    }

    return totalDistance;
  }
}
