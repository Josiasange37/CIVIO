import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EkemaSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback onVoiceTap;

  const EkemaSearchBar({
    super.key,
    required this.onSearch,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre situation...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.text),
            ),
          ),
          InkWell(
            onTap: onVoiceTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
