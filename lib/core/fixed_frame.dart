import 'package:flutter/material.dart';

/// Constraints content to phone-like width on wide screens.
class FixedFrame extends StatelessWidget {
  final Widget child;
  const FixedFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth > 420) {
        return Scaffold(
          backgroundColor: const Color(0xFF3A2C22),
          body: Center(
            child: SizedBox(width: 390, height: c.maxHeight, child: child),
          ),
        );
      }
      return child;
    });
  }
}
