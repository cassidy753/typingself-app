import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'naming_engine.dart';

class ShareCard {
  static void share(BuildContext context, PersonalityName name) {
    final text = '''
我係 ${name.mbti} ${name.enneagram}：${name.nameCanto} ${name.emoji}

${name.tagline}

「型得你」— 了解自己，贏返自己
下載：https://xingdeni.app
''';

    Share.share(
      text,
      subject: '型得你 — 我係${name.nameCanto}',
    );
  }

  // TODO: Generate image card for IG Story share
  // Will use RepaintBoundary + RenderRepaintBoundary to capture widget as image
}
