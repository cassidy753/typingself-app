import 'package:flutter/material.dart';

/// 書卷翻頁 — 頁面從右揭入（似揭書）
Route createFlipRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.6, 0.0);
      const curve = Curves.easeOutCubic;
      final tween = Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: curve));
      final fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

/// 潛入動畫 — 內容從中心放大浮現
Widget zoomInWidget({required Widget child, required Animation<double> animation}) {
  return ScaleTransition(
    scale: Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    ),
    child: FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      ),
      child: child,
    ),
  );
}

/// 逐行文字 — 俾成段文字逐行 fade in
class StaggeredText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final double lineHeight;
  final Duration staggerDuration;

  const StaggeredText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    this.lineHeight = 1.8,
    this.staggerDuration = const Duration(milliseconds: 200),
  });

  @override
  State<StaggeredText> createState() => _StaggeredTextState();
}

class _StaggeredTextState extends State<StaggeredText> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    final lines = widget.text.split('\n');
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: widget.staggerDuration.inMilliseconds * lines.length + 400));
    _animations = List.generate(lines.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i / lines.length, (i + 0.6) / lines.length, curve: Curves.easeIn),
        ),
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.text.split('\n');
    return Column(
      crossAxisAlignment: widget.textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: List.generate(lines.length, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[i].value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - _animations[i].value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: widget.lineHeight > 1.0 ? 2.0 : 0),
            child: Text(lines[i], style: widget.style, textAlign: widget.textAlign),
          ),
        );
      }),
    );
  }
}
