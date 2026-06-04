import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/procedure.dart';
import '../widgets/animations/animations.dart';
import '../widgets/design_system/duo_choice_card.dart';

class OfflineMapScreen extends StatefulWidget {
  final List<ProcedureLocation> locations;

  const OfflineMapScreen({super.key, required this.locations});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> with TickerProviderStateMixin {
  late AnimationController _pulse;
  late PageController _pageController;
  int _selectedIndex = 0;

  List<ProcedureLocation> get _locations {
    if (widget.locations.isNotEmpty) return widget.locations;
    return [
      ProcedureLocation(
        name: 'DGSN Centrale - Yaoundé',
        lat: 3.8667,
        lon: 11.5167,
        address: 'Face Préfecture du Mfoundi',
        phone: '1500',
      ),
      ProcedureLocation(
        name: 'PASSCAM - Yaoundé',
        lat: 3.848,
        lon: 11.502,
        address: 'Centre PASSCAM',
        phone: '1500',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locs = _locations;
    final center = LatLng(locs[_selectedIndex].lat, locs[_selectedIndex].lon);

    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13.5,
              maxZoom: 18,
              minZoom: 10,
              onTap: (_, __) {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.civio.app',
              ),
              MarkerLayer(
                markers: List.generate(locs.length, (i) {
                  final loc = locs[i];
                  final selected = i == _selectedIndex;
                  return Marker(
                    point: LatLng(loc.lat, loc.lon),
                    width: selected ? 90 : 70,
                    height: selected ? 90 : 70,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final scale = selected ? 1.0 + 0.15 * _pulse.value : 1.0;
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _MapPin(active: selected, label: loc.name.split(' ').first),
                    ),
                  );
                }),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(CivioSpacing.lg),
              child: Row(
                children: [
                  BouncyPress(
                    onTap: () => Navigator.pop(context),
                    child: _floatingChip(Icons.arrow_back_ios_new_rounded, null),
                  ),
                  const Spacer(),
                  _floatingChip(Icons.explore, 'Carte interactive'),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 100,
            left: CivioSpacing.lg,
            right: CivioSpacing.lg,
            child: StaggerFadeSlide(
              index: 0,
              child: MascotSpeechBubble(
                text: 'Trouvez le bureau le plus proche ! Balayez les cartes ci-dessous.',
                mascot: DuoMascot(size: 56, mood: 'happy'),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.22,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1F2C33),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: BorderSide(color: Color(0xFF37464F), width: 3)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF37464F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(CivioSpacing.lg),
                      child: Row(
                        children: [
                          const Icon(Icons.place, color: Color(0xFF58CC02), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            '${locs.length} bureaux',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _selectedIndex = i),
                        itemCount: locs.length,
                        itemBuilder: (context, index) {
                          final loc = locs[index];
                          return StaggerFadeSlide(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _OfficeCard(
                                location: loc,
                                selected: index == _selectedIndex,
                                onNavigate: () {},
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: DuoChoiceCard(
                        title: 'Itinéraire vers ${locs[_selectedIndex].name}',
                        subtitle: locs[_selectedIndex].address,
                        icon: Icons.directions_walk_rounded,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _floatingChip(IconData icon, String? label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: label == null ? 12 : 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF37464F), width: 2),
        boxShadow: CivioShadows.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final bool active;
  final String label;

  const _MapPin({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (active)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF46A302), width: 2),
            ),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        const SizedBox(height: 4),
        Container(
          width: active ? 44 : 36,
          height: active ? 44 : 36,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF58CC02) : CivioColors.brand,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (active ? const Color(0xFF58CC02) : CivioColors.brand).withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: active ? 4 : 0,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final ProcedureLocation location;
  final bool selected;
  final VoidCallback onNavigate;

  const _OfficeCard({
    required this.location,
    required this.selected,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      padding: const EdgeInsets.all(CivioSpacing.xl),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD7FFB8) : const Color(0xFF131F24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF58CC02) : const Color(0xFF37464F),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ? const Color(0xFF46A302) : const Color(0xFF37464F),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: selected ? const Color(0xFF2B7A0B) : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 16, color: selected ? const Color(0xFF4A7C23) : Colors.white54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? const Color(0xFF4A7C23) : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: selected ? const Color(0xFF4A7C23) : Colors.white54),
              const SizedBox(width: 6),
              Text(location.phone, style: TextStyle(color: selected ? const Color(0xFF4A7C23) : Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
