// ═══════════════════════════════════════════════════════════════════════
// BgmPlayerWidget — Minimal floating BGM play/pause button
// Sits at the bottom-right of the screen as a subtle circular control.
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'bgm_service.dart';

class BgmPlayerWidget extends StatefulWidget {
  const BgmPlayerWidget({super.key});

  @override
  State<BgmPlayerWidget> createState() => _BgmPlayerWidgetState();
}

class _BgmPlayerWidgetState extends State<BgmPlayerWidget> {
  final BgmService _bgm = BgmService();

  @override
  void initState() {
    super.initState();
    _bgm.addListener(_onBgmChanged);
  }

  @override
  void dispose() {
    _bgm.removeListener(_onBgmChanged);
    super.dispose();
  }

  void _onBgmChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if BGM is disabled in settings
    if (!_bgm.enabled) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.10);
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Positioned(
      right: 16,
      bottom: 80, // above the bottom nav bar
      child: GestureDetector(
        onTap: _bgm.togglePlayPause,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.5,
            ),
          ),
          child: Icon(
            _bgm.showPause ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 22,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
