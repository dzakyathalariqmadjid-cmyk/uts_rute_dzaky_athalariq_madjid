
import 'package:latlong2/latlong.dart' show LatLng, Distance, LengthUnit;

import '../models/location_point.dart';
import '../models/route_result.dart';

class DijkstraRouting {
  final Distance distanceCalculator = const Distance();

  double _calculateDistance(LocationPoint a, LocationPoint b) {
    return distanceCalculator.as(
      LengthUnit.Kilometer,
      a.position,
      b.position,
    );
  }

  RouteResult calculate(List<LocationPoint> locations) {
    if (locations.length < 2) {
      throw Exception('Minimal harus ada 2 lokasi.');
    }

    final int n = locations.length;

    // Membuat graph jarak antarlokasi.
    final List<List<double>> graph = List.generate(
      n,
      (i) => List.generate(
        n,
        (j) => i == j
            ? 0.0
            : _calculateDistance(locations[i], locations[j]),
      ),
    );

    // Membuat Minimum Spanning Tree menggunakan Prim.
    final List<List<int>> mst = List.generate(n, (_) => []);
    final List<bool> visited = List.filled(n, false);
    final List<double> minDistance = List.filled(n, double.infinity);
    final List<int> parent = List.filled(n, -1);

    minDistance[0] = 0;

    for (int count = 0; count < n; count++) {
      int current = -1;

      for (int i = 0; i < n; i++) {
        if (!visited[i] &&
            (current == -1 || minDistance[i] < minDistance[current])) {
          current = i;
        }
      }

      if (current == -1) break;

      visited[current] = true;

      if (parent[current] != -1) {
        mst[current].add(parent[current]);
        mst[parent[current]].add(current);
      }

      for (int next = 0; next < n; next++) {
        if (!visited[next] && graph[current][next] < minDistance[next]) {
          minDistance[next] = graph[current][next];
          parent[next] = current;
        }
      }
    }

    // Menentukan urutan kunjungan lokasi.
    final List<int> routeOrder = [0];
    final Set<int> remaining = {
      for (int i = 1; i < n; i++) i,
    };

    int current = 0;
    double totalDistance = 0;

    while (remaining.isNotEmpty) {
      List<int> bestPath = [];
      int bestDestination = -1;
      double bestDistance = double.infinity;

      for (final destination in remaining) {
        final List<int> path = _findPath(mst, current, destination);

        double pathDistance = 0;

        for (int i = 0; i < path.length - 1; i++) {
          pathDistance += graph[path[i]][path[i + 1]];
        }

        if (pathDistance < bestDistance) {
          bestDistance = pathDistance;
          bestPath = path;
          bestDestination = destination;
        }
      }

      if (bestDestination == -1 || bestPath.isEmpty) {
        break;
      }

      for (int i = 1; i < bestPath.length; i++) {
        final int point = bestPath[i];

        if (!routeOrder.contains(point)) {
          routeOrder.add(point);
        }
      }

      totalDistance += bestDistance;
      remaining.remove(bestDestination);
      current = bestDestination;
    }

    final List<LatLng> routePoints = routeOrder
        .map((index) => locations[index].position)
        .toList();

    return RouteResult(
      algorithm: 'Dijkstra',
      routeOrder: routeOrder,
      totalDistance: totalDistance,
      routePoints: routePoints,
    );
  }

  List<int> _findPath(
    List<List<int>> graph,
    int start,
    int destination,
  ) {
    final List<int> queue = [start];
    final Map<int, int> previous = {};
    final Set<int> visited = {start};

    while (queue.isNotEmpty) {
      final int current = queue.removeAt(0);

      if (current == destination) {
        final List<int> path = [destination];
        int node = destination;

        while (node != start) {
          node = previous[node]!;
          path.add(node);
        }

        return path.reversed.toList();
      }

      for (final neighbor in graph[current]) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          previous[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    return [];
  }
}
