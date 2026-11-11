
import 'package:latlong2/latlong.dart';

class LocationPoint {
  final String name;
  final double latitude;
  final double longitude;

  LocationPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  LatLng get position {
    return LatLng(latitude, longitude);
  }
}
