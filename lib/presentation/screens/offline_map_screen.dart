import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/procedure.dart';

class OfflineMapScreen extends StatelessWidget {
  final List<ProcedureLocation> locations;

  const OfflineMapScreen({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    // Center on the first location or Yaoundé
    final center = locations.isNotEmpty 
        ? LatLng(locations.first.lat, locations.first.lon) 
        : const LatLng(3.8667, 11.5167);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation des Bureaux', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.text), onPressed: () => Navigator.pop(context)),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 13.0,
          maxZoom: 18.0,
          minZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ekema.app',
            // Note: For true offline, you'd use a local MBTiles or pre-seeded tiles
            // In Flutter, AssetTileProvider would be used
          ),
          MarkerLayer(
            markers: locations.map((loc) => Marker(
              point: LatLng(loc.lat, loc.lon),
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.primary, width: 1)),
                    child: Text(loc.name, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  const Icon(Icons.location_on, color: AppColors.primary, size: 30),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
