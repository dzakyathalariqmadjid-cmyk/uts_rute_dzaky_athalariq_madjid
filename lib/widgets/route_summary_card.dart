
import 'package:flutter/material.dart';

import '../models/location_point.dart';
import '../models/route_result.dart';

class RouteSummaryCard extends StatelessWidget {
  final RouteResult result;
  final List<LocationPoint> locations;

  const RouteSummaryCard({
    super.key,
    required this.result,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    String routeNames = result.routeOrder
        .map((index) => locations[index].name)
        .join(' → ');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.algorithm,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            const Text(
              'Total Jarak Perjalanan',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            Text(
              '${result.totalDistance.toStringAsFixed(2)} km',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Urutan Perjalanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              routeNames,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
