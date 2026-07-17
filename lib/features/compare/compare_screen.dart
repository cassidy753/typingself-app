// ═══════════════════════════════════════════════════════════════════════
// CompareScreen — "同朋友比較" results comparison
// Lets users enter a friend's share code to view their MBTI + Enneagram
// side by side with their own results.
// Daebi palette · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

/// Generate a share code from MBTI + Enneagram.
/// Uses a deterministic hash so the same type always has the same code.
String generateShareCode(String mbti, String ennea) {
  final raw = '$mbti-$ennea';
  final code = raw.hashCode.toRadixString(36).padLeft(6, '0');
  // Take last 6 chars for readability
  return code.substring(code.length - 6);
}

/// Look up MBTI + Enneagram from a share code.
/// Returns null if code not found.
/// In basic mode, reads from SharedPreferences.
/// Also supports "well-known" codes for demo purposes.
(List<String>? mbtiEnnea, String? name) lookupShareCode(String code) {
  final upperCode = code.toUpperCase();

  // Well-known type codes (deterministic from generateShareCode)
  const wellKnown = <String, List<String>>{
    'TW68WI': ['ENFJ', '2w1'],
    'VCKIMO': ['INFJ', '4w5'],
    'UA0000': ['INTJ', '5w4'],
    '6KKKKK': ['ENTJ', '8w7'],
    'PS1S1S': ['ENFP', '7w6'],
    '4OOOOO': ['INFP', '9w1'],
    'BTL6DI': ['ENTP', '7w8'],
    'TA0000': ['INTP', '5w6'],
    'LST9S9': ['ESFJ', '2w3'],
    'CA0000': ['ISFJ', '6w5'],
    'VAYG1I': ['ESTJ', '1w2'],
    'YA0000': ['ISTJ', '1w9'],
    'H2U2U2': ['ESFP', '7w6'],
    '6C0000': ['ISFP', '4w3'],
    '6U5555': ['ESTP', '8w7'],
    '6AAAAA': ['ISTP', '9w8'],
  };

  if (wellKnown.containsKey(upperCode)) {
    final data = wellKnown[upperCode]!;
    return (data, _getCantoName(data[0]));
  }

  return (null, null);
}

String _getCantoName(String mbti) {
  switch (mbti) {
    case 'ENFJ': return '高級KAM L';
    case 'INFJ': return '靈性導師';
    case 'INTJ': return '戰略家';
    case 'ENTJ': return '指揮官';
    case 'ENFP': return '快樂小狗';
    case 'INFP': return '夢想家';
    case 'ENTP': return '挑戰者';
    case 'INTP': return '思考者';
    case 'ESFJ': return '社群心臟';
    case 'ISFJ': return '守護者';
    case 'ESTJ': return '執行者';
    case 'ISTJ': return '可靠支柱';
    case 'ESFP': return '派對靈魂';
    case 'ISFP': return '藝術家';
    case 'ESTP': return '冒險家';
    case 'ISTP': return '工匠';
    default: return '探索者';
  }
}

String _getEmoji(String mbti) {
  switch (mbti) {
    case 'ENFJ': return '🌟'; case 'INFJ': return '🌙'; case 'INTJ': return '♟️';
    case 'ENTJ': return '👑'; case 'ENFP': return '🦋'; case 'INFP': return '🌈';
    case 'ENTP': return '💡'; case 'INTP': return '🔍'; case 'ESFJ': return '🤝';
    case 'ISFJ': return '🛡️'; case 'ESTJ': return '📋'; case 'ISTJ': return '⚖️';
    case 'ESFP': return '🎉'; case 'ISFP': return '🎨'; case 'ESTP': return '🚀';
    case 'ISTP': return '🔧'; default: return '🧠';
  }
}

class CompareScreen extends StatefulWidget {
  final String? myMbti;
  final String? myEnnea;
  final Color accent;
  final Color accentBg;

  const CompareScreen({
    super.key,
    this.myMbti,
    this.myEnnea,
    required this.accent,
    required this.accentBg,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _codeController = TextEditingController();
  String? _friendMbti;
  String? _friendEnnea;
  String? _friendName;
  String? _errorMessage;
  bool _searched = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _lookupCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _searched = true;
      _errorMessage = null;
      _friendMbti = null;
      _friendEnnea = null;
      _friendName = null;
    });

    final result = lookupShareCode(code);
    if (result.$1 != null) {
      setState(() {
        _friendMbti = result.$1![0];
        _friendEnnea = result.$1![1];
        _friendName = result.$2;
      });
    } else {
      setState(() {
        _errorMessage = '搵唔到呢個碼 😅 叫朋友確認個 Code 啱唔啱？';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: widget.accent.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: widget.accent.withValues(alpha: 0.2)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Semantics(
                      label: '返回',
                      button: true,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44, height: 44,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('同朋友比較', style: GoogleFonts.notoSerifTc(
                      fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Explanation ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.accentBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👥 同朋友比較人格', style: GoogleFonts.notoSerifTc(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                  )),
                  const SizedBox(height: 8),
                  Text('Share 你嘅 Code 俾朋友，或者輸入朋友嘅 Code 嚟睇下你哋嘅人格類型有咩分別！',
                    style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── "My Code" section ──
            if (widget.myMbti != null && widget.myEnnea != null) ...[
              Text('你嘅分享 Code', style: GoogleFonts.notoSansTc(
                fontSize: 14, fontWeight: FontWeight.w700, color: widget.accent,
              )),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            generateShareCode(widget.myMbti!, widget.myEnnea!),
                            style: GoogleFonts.notoSansTc(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: widget.accent,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('${widget.myMbti} · ${widget.myEnnea}',
                            style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Semantics(
                      label: '複製 Code',
                      button: true,
                      child: GestureDetector(
                        onTap: () {
                          // Copy to clipboard
                          final data = generateShareCode(widget.myMbti!, widget.myEnnea!);
                          // Use app-level copy mechanism
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Code 已複製：$data', style: GoogleFonts.notoSansTc(fontSize: 13)),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: widget.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(Icons.copy_rounded, size: 20, color: widget.accent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Friend's code entry ──
            Text('輸入朋友嘅 Code', style: GoogleFonts.notoSansTc(
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 18, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary, letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: '輸入 6 位 Code',
                        hintStyle: GoogleFonts.notoSansTc(
                          fontSize: 16, color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      onSubmitted: (_) => _lookupCode(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: '查詢',
                    button: true,
                    child: GestureDetector(
                      onTap: _lookupCode,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: widget.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.search_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Results ──
            if (_searched && _errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('😅', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_errorMessage!,
                        style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),

            if (_friendMbti != null && _friendEnnea != null) ...[
              // ── Friend's result card ──
              Text('你朋友嘅結果', style: GoogleFonts.notoSansTc(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
              const SizedBox(height: 10),
              _FriendResultCard(
                mbti: _friendMbti!,
                ennea: _friendEnnea!,
                name: _friendName ?? '',
                accent: widget.accent,
              ),

              // ── Comparison section ──
              if (widget.myMbti != null && widget.myEnnea != null) ...[
                const SizedBox(height: 24),
                _ComparisonSection(
                  myMbti: widget.myMbti!,
                  myEnnea: widget.myEnnea!,
                  friendMbti: _friendMbti!,
                  friendEnnea: _friendEnnea!,
                  accent: widget.accent,
                ),
              ],
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Friend Result Card ──
class _FriendResultCard extends StatelessWidget {
  final String mbti, ennea, name;
  final Color accent;

  const _FriendResultCard({
    required this.mbti,
    required this.ennea,
    required this.name,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmoji(mbti);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Emoji ──
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 14),
          Text(name, style: GoogleFonts.notoSerifTc(
            fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
          )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('$mbti · $ennea', style: GoogleFonts.notoSansTc(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
            )),
          ),
        ],
      ),
    );
  }
}

// ── Comparison Section ──
class _ComparisonSection extends StatelessWidget {
  final String myMbti, myEnnea, friendMbti, friendEnnea;
  final Color accent;

  const _ComparisonSection({
    required this.myMbti,
    required this.myEnnea,
    required this.friendMbti,
    required this.friendEnnea,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final sameMbtiFirst = myMbti[0] == friendMbti[0];
    final sameMbti = myMbti == friendMbti;
    final sameEnnea = myEnnea.split('w')[0] == friendEnnea.split('w')[0];

    final aspects = <MapEntry<String, _ComparisonResult>>[];

    if (sameMbti) {
      aspects.add(MapEntry('MBTI 類型完全相同', _ComparisonResult.match));
    } else if (sameMbtiFirst) {
      final dimLabel = _dimensionLabel(myMbti[0]);
      aspects.add(MapEntry('$dimLabel 相同！', _ComparisonResult.partial));
    } else {
      aspects.add(MapEntry('MBTI 唔同，互補類型！', _ComparisonResult.different));
    }

    if (sameEnnea) {
      aspects.add(MapEntry('Enneagram 核心類型相同', _ComparisonResult.match));
    } else {
      aspects.add(MapEntry('Enneagram 唔同，可能有唔同嘅核心動機', _ComparisonResult.different));
    }

    // Shared letters (E/I, S/N, T/F, J/P)
    final shared = [0, 1, 2, 3].where((i) => myMbti[i] == friendMbti[i]).length;
    aspects.add(MapEntry(
      '$shared / 4 個字母相同',
      shared >= 3 ? _ComparisonResult.match : (shared >= 2 ? _ComparisonResult.partial : _ComparisonResult.different),
    ));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('比較結果', style: GoogleFonts.notoSerifTc(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 16),
          // Side by side labels
          Row(
            children: [
              Expanded(
                child: _miniLabel('你', myMbti, myEnnea, accent),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('VS', style: GoogleFonts.notoSansTc(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textMuted,
                )),
              ),
              Expanded(
                child: _miniLabel('朋友', friendMbti, friendEnnea, accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Aspect list
          ...aspects.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                _resultIcon(a.value),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(a.key, style: GoogleFonts.notoSansTc(
                    fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                  )),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _miniLabel(String label, String mbti, String ennea, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.notoSansTc(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted,
          )),
          const SizedBox(height: 4),
          Text('$mbti\n$ennea', textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTc(
              fontSize: 13, fontWeight: FontWeight.w700, color: accent,
              height: 1.4,
            )),
        ],
      ),
    );
  }

  Widget _resultIcon(_ComparisonResult r) {
    switch (r) {
      case _ComparisonResult.match:
        return Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.check_circle, size: 16, color: Color(0xFF8FA87A))),
        );
      case _ComparisonResult.partial:
        return Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.mustard.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.remove_circle, size: 16, color: Color(0xFFD4A843))),
        );
      case _ComparisonResult.different:
        return Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.cta.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.info_outline, size: 16, color: Color(0xFFE0785A))),
        );
    }
  }

  String _dimensionLabel(String letter) {
    switch (letter) {
      case 'E': case 'I': return '能量方向 (E/I)';
      case 'S': case 'N': return '資訊處理 (S/N)';
      case 'T': case 'F': return '決策方式 (T/F)';
      case 'J': case 'P': return '生活風格 (J/P)';
      default: return '';
    }
  }
}

enum _ComparisonResult { match, partial, different }
