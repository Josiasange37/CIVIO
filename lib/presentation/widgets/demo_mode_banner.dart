import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

/// Small non-blocking banner shown at the top of every screen when the app
/// is running without a live Firebase connection (e.g. on Linux desktop for
/// dev/UI preview). Tappable: tap to dismiss for the current session.
class DemoModeBanner extends StatefulWidget {
  const DemoModeBanner({super.key});

  @override
  State<DemoModeBanner> createState() => _DemoModeBannerState();
}

class _DemoModeBannerState extends State<DemoModeBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    if (!AppConfig.isDemoMode) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => setState(() => _dismissed = true),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF92400E),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mode démo — Firebase non disponible. Données non synchronisées.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 14,
                color: Color(0xFF92400E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
