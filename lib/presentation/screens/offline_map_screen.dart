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
                    width: 100,
                    height: 100,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: EkemaColors.textPrimary,
                            borderRadius: BorderRadius.circular(EkemaRadius.pill),
                            boxShadow: EkemaShadows.md,
                          ),
                          child: Text(
                            loc.name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: EkemaColors.brand,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: EkemaShadows.sm,
                          ),
                          child: const Icon(Icons.place, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(EkemaSpacing.lg),
              child: Row(
                children: [
                  Material(
                    color: EkemaColors.canvas,
                    borderRadius: BorderRadius.circular(EkemaRadius.pill),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(EkemaRadius.pill),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: EkemaColors.canvas,
                    borderRadius: BorderRadius.circular(EkemaRadius.pill),
                    elevation: 4,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('Bureaux à proximité', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (locations.isNotEmpty)
            Positioned(
              left: EkemaSpacing.lg,
              right: EkemaSpacing.lg,
              bottom: EkemaSpacing.xxl,
              child: Material(
                borderRadius: BorderRadius.circular(EkemaRadius.lg),
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(EkemaSpacing.xl),
                  decoration: BoxDecoration(
                    color: EkemaColors.canvas,
                    borderRadius: BorderRadius.circular(EkemaRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [EkemaColors.brand, EkemaColors.brandHover]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: EkemaSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locations.first.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            const Text('Itinéraire · OpenStreetMap', style: TextStyle(color: EkemaColors.textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Y aller'),
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
