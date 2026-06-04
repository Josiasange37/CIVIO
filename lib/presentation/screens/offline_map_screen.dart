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
    final center = locations.isNotEmpty
        ? LatLng(locations.first.lat, locations.first.lon)
        : const LatLng(3.8667, 11.5167);

    return Scaffold(
      backgroundColor: EkemaColors.canvas,
      appBar: AppBar(
        title: const Text('Localisation des bureaux'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
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
              ),
              MarkerLayer(
                markers: locations.map((loc) {
                  return Marker(
                    point: LatLng(loc.lat, loc.lon),
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: EkemaColors.canvas,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: EkemaShadows.sm,
                          ),
                          child: Text(
                            loc.name,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: EkemaColors.brand,
                            ),
                          ),
                        ),
                        const Icon(Icons.location_on, color: EkemaColors.brand, size: 32),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (locations.isNotEmpty)
            Positioned(
              left: EkemaSpacing.lg,
              right: EkemaSpacing.lg,
              bottom: EkemaSpacing.xl,
              child: Material(
                borderRadius: BorderRadius.circular(EkemaRadius.md),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(EkemaSpacing.lg),
                  decoration: BoxDecoration(
                    color: EkemaColors.canvas,
                    borderRadius: BorderRadius.circular(EkemaRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: EkemaColors.brandLight,
                          borderRadius: BorderRadius.circular(EkemaRadius.sm),
                        ),
                        child: const Icon(Icons.place_outlined, color: EkemaColors.brand),
                      ),
                      const SizedBox(width: EkemaSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locations.first.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                            ),
                            Text(
                              'Bureau administratif',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: EkemaColors.textSecondary,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
