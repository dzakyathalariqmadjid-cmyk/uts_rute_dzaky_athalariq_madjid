
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/location_point.dart';

class MapViewWidget extends StatelessWidget {
  final List<LocationPoint> locations;
  final List<LatLng> routePoints;
  final Function(LatLng) onMapTap;

  const MapViewWidget({
    super.key,
    required this.locations,
    required this.routePoints,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = locations.isNotEmpty
        ? locations.first.position
        : const LatLng(-2.5, 118.0);

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: locations.isNotEmpty ? 13 : 4.5,
        onTap: (tapPosition, point) {
          onMapTap(point);
        },
      ),
      children: [
        // Tampilan peta OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.smart_logistics',
        ),

        // Garis rute perjalanan
        if (routePoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ],
          ),

        // Marker lokasi
        MarkerLayer(
          markers: locations.asMap().entries.map((entry) {
            int index = entry.key;
            LocationPoint location = entry.value;

            return Marker(
              point: location.position,
              width: 150,
              height: 85,
              child: Tooltip(
                message:
                    '${location.name}\n'
                    'Lat: ${location.latitude}\n'
                    'Lng: ${location.longitude}',
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 35,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Text(
                        'P${index + 1} - ${location.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
