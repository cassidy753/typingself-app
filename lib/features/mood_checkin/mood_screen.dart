import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_service.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  MoodModel? _todayMood;
  List<MoodModel> _recentMoods = [];
  final _service = MoodService();

  String? _selectedMood;
  final _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': '幾好', 'color': const Color(0xFF34D399)},
    {'emoji': '😐', 'label': '普通', 'color': const Color(0xFFF59E0B)},
    {'emoji': '😔', 'label': '麻麻', 'color': const Color(0xFFEF4444)},
    {'emoji': '😡', 'label': '燥底', 'color': const Color(0xFFF97316)},
    {'emoji': '😰', 'label': '緊張', 'color': const Color(0xFF8B5CF6)},
    {'emoji': '😢', 'label': '唔開心', 'color': const Color(0xFF60A5FA)},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = await _service.getTodayMood();
    final week = await _service.getRecentWeek();
    if (mounted) {
      setState(() {
        _todayMood = today;
        _recentMoods = week;
        if (today != null) _selectedMood = today.emoji;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '今日你點？',
          style: GoogleFonts.notoSerifHk(
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_todayMood != null) _buildTodaySummary(colorScheme),
            const SizedBox(height: 24),
            _buildMoodGrid(colorScheme),
            const SizedBox(height: 24),
            _buildNoteField(colorScheme),
            const SizedBox(height: 16),
            _buildSaveButton(colorScheme),
            if (_recentMoods.length > 1) ...[
              const SizedBox(height: 32),
              _buildTrend(colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(_todayMood!.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日已記錄',
                  style: GoogleFonts.notoSansHk(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  )),
                if (_todayMood!.note != null)
                  Text(_todayMood!.note!,
                    style: GoogleFonts.notoSansHk(
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    )),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _todayMood = null;
              _selectedMood = null;
            }),
            child: const Text('改'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.04, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildMoodGrid(ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          _todayMood != null ? '更新你嘅心情' : '撳低你而家嘅心情',
          style: GoogleFonts.notoSansHk(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _moods.asMap().entries.map((entry) {
            final i = entry.key;
            final mood = entry.value;
            final isSelected = _selectedMood == mood['emoji'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood['emoji']),
              child: AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.elasticOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood['color'] as Color
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: mood['color'] as Color, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(
                            color: (mood['color'] as Color).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood['emoji'] as String,
                        style: const TextStyle(fontSize: 32))
                        .animate(target: isSelected ? 1 : 0)
                        .shake(hz: isSelected ? 6 : 0, duration: 300.ms),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'] as String,
                        style: GoogleFonts.notoSansHk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate(delay: Duration(milliseconds: 80 * i))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.08, duration: 300.ms, curve: Curves.easeOutCubic);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteField(ColorScheme colorScheme) {
    return TextField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: _todayMood != null ? '想補充咩？' : '想講多句？（optional）',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.04, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    final canSave = _selectedMood != null && _todayMood == null;
    return AnimatedScale(
      scale: canSave ? 1.0 : 0.97,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: FilledButton.icon(
        onPressed: canSave
            ? () async {
                final label = _moods.firstWhere((m) => m['emoji'] == _selectedMood)['label'] as String;
                final mood = MoodModel(
                  emoji: _selectedMood!,
                  label: label,
                  note: _noteController.text.isNotEmpty ? _noteController.text : null,
                );
                await _service.saveMood(mood);
                await _load();
                _noteController.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ 已記錄 — $_selectedMood $label'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            : null,
        icon: Icon(canSave ? Icons.check_circle : Icons.check, 
          size: canSave ? 22 : 20),
        label: Text('記錄今日心情'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.04, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTrend(ColorScheme colorScheme) {
    return FutureBuilder<int>(
      future: _service.weekTrend(),
      builder: (context, snapshot) {
        final trend = snapshot.data ?? 0;
        final icon = trend > 0 ? '📈' : trend < 0 ? '📉' : '📊';
        final msg = trend > 0 ? '呢個星期心情有改善 💪'
            : trend < 0 ? '呢個星期心情有啲回落，要撐住 🫂'
            : '呢個星期心情平穩 🧘';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7日趨勢',
                      style: GoogleFonts.notoSansHk(fontWeight: FontWeight.w700)),
                    Text(msg,
                      style: GoogleFonts.notoSansHk(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 500.ms)
          .slideY(begin: 0.06, duration: 500.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}
