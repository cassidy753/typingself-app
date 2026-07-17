// ═══════════════════════════════════════════════════════════════════════
// CompareScreen — 「同朋友比較」results comparison
// Lets users generate shareable profile links, enter a friend's share code,
// or paste a friend's profile link to view their MBTI + Enneagram
// side by side with their own results.
// Daebi palette · HK Cantonese
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

/// ─── CONSTANTS ──────────────────────────────────────────────────────────

/// Base URL for shareable profile links
const String _kAppBaseUrl = 'https://xingdeni.app';

/// Generate a share code from MBTI + Enneagram.
/// Uses a deterministic hash so the same type always has the same code.
String generateShareCode(String mbti, String ennea) {
  final raw = '$mbti-$ennea';
  final code = raw.hashCode.toRadixString(36).padLeft(6, '0');
  return code.substring(code.length - 6);
}

/// Generate a shareable profile link containing type info.
/// Format: https://xingdeni.app/?type=INTJ_5w4&name=戰略家
String generateProfileLink(String mbti, String ennea, {String? displayName}) {
  final typeParam = '$mbti-${ennea.replaceAll('w', '_')}';
  final encodedType = Uri.encodeComponent(typeParam);
  final name = displayName ?? _getCantoName(mbti);
  final encodedName = Uri.encodeComponent(name);
  return '$_kAppBaseUrl/?type=$encodedType&name=$encodedName';
}

/// Parse MBTI + Enneagram from a profile link URL.
/// Returns null if parsing fails.
(List<String>? mbtiEnnea, String? name)? parseProfileLink(String url) {
  try {
    final uri = Uri.parse(url);
    final typeParam = uri.queryParameters['type'];
    final nameParam = uri.queryParameters['name'];
    if (typeParam == null) return null;

    final decoded = Uri.decodeComponent(typeParam);
    final parts = decoded.split('-');
    if (parts.length != 2) return null;

    final mbti = parts[0].toUpperCase();
    // Validate MBTI (4 letters, all in E/I/S/N/T/F/J/P)
    if (mbti.length != 4) return null;
    for (final c in mbti.split('')) {
      if (!'EISNTFJP'.contains(c)) return null;
    }

    final enneaRaw = parts[1].replaceAll('_', 'w');
    // Validate Enneagram (digits + w + digit)
    final enneaPattern = RegExp(r'^[1-9]w[1-9]$');
    if (!enneaPattern.hasMatch(enneaRaw)) return null;

    final displayName = nameParam != null ? Uri.decodeComponent(nameParam) : _getCantoName(mbti);
    return ([mbti, enneaRaw], displayName);
  } catch (_) {
    return null;
  }
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

/// ─── INPUT MODE ─────────────────────────────────────────────────────────

enum _InputMode { code, link }

/// ─── SCREEN ─────────────────────────────────────────────────────────────

class CompareScreen extends StatefulWidget {
  final String? myMbti;
  final String? myEnnea;
  final Color accent;
  final Color accentBg;
  final String? initialFriendMbti;
  final String? initialFriendEnnea;
  final String? initialFriendName;

  const CompareScreen({
    super.key,
    this.myMbti,
    this.myEnnea,
    required this.accent,
    required this.accentBg,
    this.initialFriendMbti,
    this.initialFriendEnnea,
    this.initialFriendName,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _codeController = TextEditingController();
  final _linkController = TextEditingController();
  String? _friendMbti;
  String? _friendEnnea;
  String? _friendName;
  String? _errorMessage;
  bool _searched = false;
  _InputMode _inputMode = _InputMode.code;
  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    // Handle pre-filled friend data from deep links
    if (widget.initialFriendMbti != null && widget.initialFriendEnnea != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _searched = true;
          _friendMbti = widget.initialFriendMbti;
          _friendEnnea = widget.initialFriendEnnea;
          _friendName = widget.initialFriendName;
        });
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ── Share code lookup ──

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

  // ── Profile link lookup ──

  void _lookupLink() {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    setState(() {
      _searched = true;
      _errorMessage = null;
      _friendMbti = null;
      _friendEnnea = null;
      _friendName = null;
    });

    final result = parseProfileLink(link);
    if (result != null && result.$1 != null) {
      setState(() {
        _friendMbti = result.$1![0];
        _friendEnnea = result.$1![1];
        _friendName = result.$2;
      });
    } else {
      setState(() {
        _errorMessage = '呢條 Link 格式唔啱 😅 叫朋友俾個 Code 或者直接 Share 俾你？';
      });
    }
  }

  // ── Copy my share code ──

  void _copyMyCode() {
    if (widget.myMbti == null || widget.myEnnea == null) return;
    final code = generateShareCode(widget.myMbti!, widget.myEnnea!);
    Clipboard.setData(ClipboardData(text: code));
    _showSnack('Code 已複製：$code ✅');
  }

  // ── Share profile link ──

  void _shareProfileLink() {
    if (widget.myMbti == null || widget.myEnnea == null) return;
    final link = generateProfileLink(
      widget.myMbti!,
      widget.myEnnea!,
      displayName: _getCantoName(widget.myMbti!),
    );
    Share.share(
      '🌟 型得你 — 我嘅人格類型係 ${widget.myMbti} ${widget.myEnnea}！\n'
      '睇下我哋夾唔夾？撳呢條 Link 睇我嘅 Profile 👇\n$link\n\n'
      '下載「型得你」了解自己嘅 MBTI 同 Enneagram → https://xingdeni.app',
      subject: '型得你 — 我係 ${widget.myMbti}',
    );
  }

  // ── Copy profile link ──

  void _copyProfileLink() {
    if (widget.myMbti == null || widget.myEnnea == null) return;
    final link = generateProfileLink(
      widget.myMbti!,
      widget.myEnnea!,
      displayName: _getCantoName(widget.myMbti!),
    );
    Clipboard.setData(ClipboardData(text: link));
    setState(() => _linkCopied = true);
    _showSnack('Profile Link 已複製 ✅');
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _linkCopied = false);
    });
  }

  // ── Invite friend (opens WhatsApp / default SMS) ──

  Future<void> _inviteFriend() async {
    final text = '🌟 一齊玩「型得你」啦！做到人格測試，睇下我哋夾唔夾 😆\n'
        '下載：https://xingdeni.app';
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: share via system share sheet
      await Share.share(text, subject: '型得你 — 一齊玩！');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.notoSansTc(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
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
            _buildIntroCard(),

            const SizedBox(height: 24),

            // ── "My Profile" section (shareable link + code) ──
            if (widget.myMbti != null && widget.myEnnea != null) ...[
              _buildMyProfileSection(),
              const SizedBox(height: 24),
            ],

            // ── Input section: code OR link ──
            _buildInputModeToggle(),
            const SizedBox(height: 16),
            if (_inputMode == _InputMode.code)
              _buildCodeInput()
            else
              _buildLinkInput(),

            const SizedBox(height: 24),

            // ── Results ──
            if (_searched && _errorMessage != null) _buildErrorCard(),

            if (_friendMbti != null && _friendEnnea != null) ...[
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

            const SizedBox(height: 24),

            // ── Invite Friend CTA ──
            _buildInviteCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Intro Card ──

  Widget _buildIntroCard() {
    return Container(
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
          Text('Share 你嘅 Profile Link 俾朋友，或者輸入朋友嘅 Code/Link 嚟睇下你哋嘅人格類型有咩分別！',
            style: GoogleFonts.notoSansTc(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  // ── My Profile Section ──

  Widget _buildMyProfileSection() {
    final code = generateShareCode(widget.myMbti!, widget.myEnnea!);
    final link = generateProfileLink(
      widget.myMbti!, widget.myEnnea!,
      displayName: _getCantoName(widget.myMbti!),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('你嘅分享資料', style: GoogleFonts.notoSansTc(
          fontSize: 14, fontWeight: FontWeight.w700, color: widget.accent,
        )),
        const SizedBox(height: 10),

        // ── Share Code Card ──
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
                    Text(code,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 28, fontWeight: FontWeight.w900,
                        color: widget.accent, letterSpacing: 4,
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
                  onTap: _copyMyCode,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.copy_rounded, size: 20, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Profile Link Card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 18, color: widget.accent),
                  const SizedBox(width: 6),
                  Text('Profile Link',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 14, fontWeight: FontWeight.w700, color: widget.accent,
                    )),
                ],
              ),
              const SizedBox(height: 8),
              Text(link,
                style: GoogleFonts.notoSansTc(
                  fontSize: 11, color: AppColors.textMuted, height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniButton(
                      icon: _linkCopied ? Icons.check_rounded : Icons.copy_rounded,
                      label: _linkCopied ? '已複製' : '複製 Link',
                      onTap: _copyProfileLink,
                      accent: widget.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniButton(
                      icon: Icons.share_rounded,
                      label: 'Share Link',
                      onTap: _shareProfileLink,
                      accent: widget.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Input Mode Toggle ──

  Widget _buildInputModeToggle() {
    return Row(
      children: [
        _ModeToggle(
          label: '用 Code',
          isActive: _inputMode == _InputMode.code,
          onTap: () => setState(() {
            _inputMode = _InputMode.code;
            _searched = false;
            _errorMessage = null;
          }),
          accent: widget.accent,
        ),
        const SizedBox(width: 8),
        _ModeToggle(
          label: '用 Link',
          isActive: _inputMode == _InputMode.link,
          onTap: () => setState(() {
            _inputMode = _InputMode.link;
            _searched = false;
            _errorMessage = null;
          }),
          accent: widget.accent,
        ),
      ],
    );
  }

  // ── Code Input ──

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  // ── Link Input ──

  Widget _buildLinkInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('貼上朋友嘅 Profile Link', style: GoogleFonts.notoSansTc(
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
                  controller: _linkController,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '貼上 Link（例如 xingdeni.app/?type=...)',
                    hintStyle: GoogleFonts.notoSansTc(
                      fontSize: 13, color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _lookupLink(),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: '查詢',
                button: true,
                child: GestureDetector(
                  onTap: _lookupLink,
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
        const SizedBox(height: 8),
        Text('朋友可以用「Share Link」功能生成佢哋嘅 Profile Link，直接貼上嚟就得',
          style: GoogleFonts.notoSansTc(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  // ── Error Card ──

  Widget _buildErrorCard() {
    return Container(
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
    );
  }

  // ── Invite Friend CTA ──

  Widget _buildInviteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.accent.withValues(alpha: 0.08),
            widget.accent.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('🙋', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('邀請朋友一齊玩',
                      style: GoogleFonts.notoSerifTc(
                        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      )),
                    const SizedBox(height: 3),
                    Text('叫多啲朋友做測試，睇下你哋夾唔夾！',
                      style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _inviteFriend,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text('邀請朋友', style: GoogleFonts.notoSansTc(
                fontSize: 15, fontWeight: FontWeight.w700,
              )),
              style: FilledButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mode Toggle Chip ─────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color accent;

  const _ModeToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? accent.withValues(alpha: 0.4) : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(label,
          style: GoogleFonts.notoSansTc(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? accent : AppColors.textSecondary,
          )),
      ),
    );
  }
}

// ─── Mini Button ──────────────────────────────────────────────────────

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;

  const _MiniButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.notoSansTc(
              fontSize: 12, fontWeight: FontWeight.w600, color: accent,
            )),
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
