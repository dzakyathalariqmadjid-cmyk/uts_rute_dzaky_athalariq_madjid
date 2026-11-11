
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/location_point.dart';

class RoadRoutingService {
  static Future<List<LatLng>> getRoadRoute(
    List<LocationPoint> locations,
  ) async {
    if (locations.length < 2) {
      throw Exception('Minimal harus ada 2 lokasi.');
    }

    // Mengubah koordinat menjadi format longitude,latitude.
    final coordinates = locations
        .map(
          (location) =>
              '${location.longitude},${location.latitude}',
        )
        .join(';');

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$coordinates?overview=full&geometries=geojson&steps=false',
    );

    final response = await http
        .get(url)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil rute jalan raya.');
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok' ||
        (data['routes'] as List).isEmpty) {
      throw Exception('Rute jalan raya tidak ditemukan.');
    }

    final coordinatesData =
        data['routes'][0]['geometry']['coordinates'] as List;

    // OSRM memberikan format [longitude, latitude].
    return coordinatesData.map((coordinate) {
      return LatLng(
        (coordinate[1] as num).toDouble(),
        (coordinate[0] as num).toDouble(),
      );
    }).toList();
  }
}
