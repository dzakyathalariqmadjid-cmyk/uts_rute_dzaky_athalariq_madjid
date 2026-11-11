
import '../models/location_point.dart';
import '../models/route_result.dart';
import 'distance_calculator.dart';

class AlternativeRouting {
  static RouteResult calculate(List<LocationPoint> locations) {
    if (locations.length < 2) {
      throw Exception('Minimal harus ada 2 lokasi.');
    }

    int n = locations.length;

    List<int> routeOrder = [];
    List<bool> visited = List.filled(n, false);

    int current = 0;
    double totalDistance = 0;

    // Memulai perjalanan dari lokasi pertama
    routeOrder.add(current);
    visited[current] = true;

    // Mencari lokasi terdekat yang belum dikunjungi
    while (routeOrder.length < n) {
      int nearest = -1;
      double shortestDistance = double.infinity;

      for (int i = 0; i < n; i++) {
        if (!visited[i]) {
          double distance = DistanceCalculator.haversine(
            locations[current].position,
            locations[i].position,
          );

          if (distance < shortestDistance) {
            shortestDistance = distance;
            nearest = i;
          }
        }
      }

      if (nearest == -1) break;

      totalDistance += shortestDistance;
      current = nearest;

      visited[current] = true;
      routeOrder.add(current);
    }

    return RouteResult(
      algorithm: 'Nearest Neighbor',
      routeOrder: routeOrder,
      totalDistance: totalDistance,
      routePoints: routeOrder
          .map((index) => locations[index].position)
          .toList(),
    );
  }
}
