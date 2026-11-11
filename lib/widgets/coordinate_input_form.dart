
import 'package:flutter/material.dart';

import '../models/location_point.dart';

class CoordinateInputForm extends StatefulWidget {
  final Function(LocationPoint) onAdd;

  const CoordinateInputForm({
    super.key,
    required this.onAdd,
  });

  @override
  State<CoordinateInputForm> createState() =>
      _CoordinateInputFormState();
}

class _CoordinateInputFormState
    extends State<CoordinateInputForm> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController latitudeController =
      TextEditingController();

  final TextEditingController longitudeController =
      TextEditingController();

  void addLocation() {
    String name = nameController.text.trim();

    double? latitude =
        double.tryParse(latitudeController.text.trim());

    double? longitude =
        double.tryParse(longitudeController.text.trim());

    if (name.isEmpty ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data lokasi!'),
        ),
      );
      return;
    }

    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat latitude atau longitude tidak valid!'),
        ),
      );
      return;
    }

    widget.onAdd(
      LocationPoint(
        name: name,
        latitude: latitude,
        longitude: longitude,
      ),
    );

    nameController.clear();
    latitudeController.clear();
    longitudeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi berhasil ditambahkan!'),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Lokasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lokasi',
                hintText: 'Contoh: Gudang Utama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Contoh: -7.2575',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Contoh: 112.7521',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addLocation,
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Tambah Lokasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
