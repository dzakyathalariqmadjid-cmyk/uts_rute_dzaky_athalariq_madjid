
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../models/location_point.dart';
import '../models/route_result.dart';

import '../services/distance_calculator.dart';
import '../services/dijkstra_routing.dart';
import '../services/alternative_routing.dart';
import '../services/road_routing_service.dart';

import '../widgets/map_view_widget.dart';
import '../widgets/coordinate_input_form.dart';
import '../widgets/route_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<LocationPoint> locations = [];

  RouteResult? selectedResult;
  Map<String, RouteResult> comparisonResults = {};

  List<LatLng> roadRoutePoints = [];
  bool isLoadingRoute = false;

  final DijkstraRouting dijkstraRouting = DijkstraRouting();

  // Menambahkan lokasi.
  void addLocation(LocationPoint location) {
    if (locations.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal hanya 10 lokasi!'),
        ),
      );
      return;
    }

    setState(() {
      locations.add(location);
      selectedResult = null;
      roadRoutePoints.clear();
      comparisonResults.clear();
    });
  }

  // Menambahkan lokasi melalui peta.
  void addLocationFromMap(LatLng position) {
    if (locations.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal hanya 10 lokasi!'),
        ),
      );
      return;
    }

    addLocation(
      LocationPoint(
        name: 'Lokasi ${locations.length + 1}',
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  // Menghapus lokasi.
  void deleteLocation(int index) {
    setState(() {
      locations.removeAt(index);
      selectedResult = null;
      roadRoutePoints.clear();
      comparisonResults.clear();
    });
  }

  // Validasi lokasi.
  bool validateLocations() {
    if (locations.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan minimal 2 lokasi terlebih dahulu!',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  // Mengambil rute jalan raya dari OSRM.
  Future<void> showRoadRoute(RouteResult result) async {
    setState(() {
      selectedResult = result;
      roadRoutePoints.clear();
      isLoadingRoute = true;
    });

    try {
      final orderedLocations = result.routeOrder
          .map((index) => locations[index])
          .toList();

      final roadPoints =
          await RoadRoutingService.getRoadRoute(orderedLocations);

      if (!mounted) return;

      setState(() {
        roadRoutePoints = roadPoints;
        isLoadingRoute = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingRoute = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil rute jalan raya. '
            'Periksa koneksi internet. Detail: $e',
          ),
        ),
      );
    }
  }

  // Menghitung rute sesuai urutan input.
  RouteResult calculateSequential() {
    final points = locations
        .map((location) => location.position)
        .toList();

    return RouteResult(
      algorithm: 'Rute Berurutan',
      routeOrder: List.generate(
        locations.length,
        (index) => index,
      ),
      totalDistance: DistanceCalculator.routeDistance(points),
      routePoints: points,
    );
  }

  // Menjalankan rute berurutan.
  Future<void> runSequential() async {
    if (!validateLocations()) return;

    final result = calculateSequential();
    await showRoadRoute(result);
  }

  // Menjalankan Dijkstra.
  Future<void> runDijkstra() async {
    if (!validateLocations()) return;

    final result = dijkstraRouting.calculate(locations);
    await showRoadRoute(result);
  }

  // Menjalankan Nearest Neighbor.
  Future<void> runNearestNeighbor() async {
    if (!validateLocations()) return;

    final result = AlternativeRouting.calculate(locations);
    await showRoadRoute(result);
  }

  // Membandingkan ketiga algoritma.
  void compareRoutes() {
    if (!validateLocations()) return;

    setState(() {
      comparisonResults = {
        'Rute Berurutan': calculateSequential(),
        'Dijkstra': dijkstraRouting.calculate(locations),
        'Nearest Neighbor': AlternativeRouting.calculate(locations),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Logistics Routing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Peta dan Rute Pengiriman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Tambahkan 2 sampai 10 lokasi untuk '
              'menghitung rute perjalanan.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 15),

            // Peta.
            SizedBox(
              height: 350,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    MapViewWidget(
                      locations: locations,
                      routePoints: roadRoutePoints.isNotEmpty
                          ? roadRoutePoints
                          : selectedResult?.routePoints ?? [],
                      onMapTap: addLocationFromMap,
                    ),

                    if (isLoadingRoute)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Sedang mencari rute jalan raya...',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Form input.
            CoordinateInputForm(
              onAdd: addLocation,
            ),

            const SizedBox(height: 15),

            // Daftar lokasi.
            const Text(
              'Daftar Lokasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (locations.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Belum ada lokasi yang ditambahkan.',
                    ),
                  ),
                ),
              ),

            ...locations.asMap().entries.map((entry) {
              final index = entry.key;
              final location = entry.value;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      'P${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(location.name),
                  subtitle: Text(
                    'Lat: ${location.latitude}\n'
                    'Lng: ${location.longitude}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => deleteLocation(index),
                  ),
                ),
              );
            }),

            const SizedBox(height: 15),

            // Pilihan algoritma.
            const Text(
              'Pilih Algoritma Rute',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoadingRoute ? null : runSequential,
                icon: const Icon(Icons.format_list_numbered),
                label: const Text('Rute Berurutan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoadingRoute ? null : runDijkstra,
                icon: const Icon(Icons.route),
                label: const Text('Algoritma Dijkstra'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isLoadingRoute ? null : runNearestNeighbor,
                icon: const Icon(Icons.alt_route),
                label: const Text('Nearest Neighbor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            // Hasil perhitungan.
            if (selectedResult != null) ...[
              const SizedBox(height: 15),

              const Text(
                'Hasil Perhitungan Rute',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              RouteSummaryCard(
                result: selectedResult!,
                locations: locations,
              ),

              if (roadRoutePoints.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.alt_route,
                      color: Colors.blue,
                    ),
                    title: const Text('Rute Jalan Raya'),
                    subtitle: Text(
                      '${roadRoutePoints.length} titik koordinat '
                      'jalan berhasil dimuat.',
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 15),

            // Perbandingan algoritma.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: compareRoutes,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Bandingkan Semua Rute'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            if (comparisonResults.isNotEmpty) ...[
              const SizedBox(height: 15),

              const Text(
                'Perbandingan Jarak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ...comparisonResults.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value.totalDistance.toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),

              Builder(
                builder: (context) {
                  final shortest = comparisonResults.values.reduce(
                    (a, b) => a.totalDistance <= b.totalDistance
                        ? a
                        : b,
                  );

                  final sequential =
                      comparisonResults['Rute Berurutan']!;

                  final saving =
                      sequential.totalDistance -
                      shortest.totalDistance;

                  final percentage = sequential.totalDistance > 0
                      ? (saving / sequential.totalDistance) * 100
                      : 0.0;

                  return Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rute dengan Jarak Terpendek',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            shortest.algorithm,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          Text(
                            '${shortest.totalDistance.toStringAsFixed(2)} km',
                          ),

                          const Divider(),

                          Text(
                            'Penghematan jarak: '
                            '${saving.toStringAsFixed(2)} km',
                          ),

                          Text(
                            'Persentase penghematan: '
                            '${percentage.toStringAsFixed(2)}%',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
