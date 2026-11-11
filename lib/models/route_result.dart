
import 'package:latlong2/latlong.dart';

class RouteResult {
  final String algorithm;
  final List<int> routeOrder;
  final double totalDistance;
  final List<LatLng> routePoints;

  RouteResult({
    required this.algorithm,
    required this.routeOrder,
    required this.totalDistance,
    required this.routePoints,
  });
}
