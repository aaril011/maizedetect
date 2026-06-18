import 'dart:io';

import 'package:flutter/material.dart';

import 'history_service.dart';
import 'maize_theme.dart';
import 'scan_record.dart';
import 'widgets/maize_app_bar.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
    this.imagePath,
    this.readOnly = false,
    required this.result,
  });

  final String? imagePath;
  final bool readOnly;
  final Map<String, dynamic> result;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _saved = false;
  bool _saving = false;

  Future<void> _saveToHistory() async {
    if (_saved || _saving) return;

    setState(() => _saving = true);

    final conf = widget.result['confidence'] ?? 0;

    final record = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.result['prediction'] ?? 'Tidak diketahui',
      subtitle: widget.result['cause'] ?? '',
      status: widget.result['prediction'] ?? 'Tidak diketahui',
      confidence: conf > 1 ? conf / 100 : conf,
      imagePath: widget.imagePath ?? '',
      timestamp: DateTime.now(),

      solution: List<String>.from(widget.result['solution'] ?? []),
    );

    await HistoryService.instance.add(record);

    if (!mounted) return;

    setState(() {
      _saved = true;
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Berhasil disimpan ke History!'),
          ],
        ),
        backgroundColor: const Color(0xFF064E3B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: MaizeColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MaizeAppBar(
              centerTitle: 'Scan Result',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              trailing: const Icon(Icons.ios_share),
              showLogo: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResultHero(imagePath: widget.imagePath),
                    const SizedBox(height: 16),
                    _DiagnosisCard(textTheme: textTheme, result: widget.result),
                    const SizedBox(height: 16),
                    _DiseaseProfile(
                      textTheme: textTheme,
                      result: widget.result,
                    ),
                    const SizedBox(height: 16),
                    _ActionPlan(
                      textTheme: textTheme,
                      solution: widget.result['solution'] ?? [],
                    ),
                    const SizedBox(height: 16),

                    // ── Save to History ─────────────────────────────────────
                    if (!widget.readOnly)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _saved
                            ? _SavedBadge(key: const ValueKey('saved'))
                            : FilledButton.icon(
                                key: const ValueKey('Simpan'),
                                onPressed: _saving ? null : _saveToHistory,
                                style: FilledButton.styleFrom(
                                  backgroundColor: MaizeColors.primary,
                                  foregroundColor: MaizeColors.onPrimary,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.bookmark_add_outlined),
                                label: Text(
                                  _saving ? 'Menyimpan...' : 'Simpan Riwayat',
                                ),
                              ),
                      ),

                    const SizedBox(height: 10),

                    // ── Scan Another Leaf ───────────────────────────────────
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: MaizeColors.primary.withValues(alpha: 0.2),
                        ),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: MaizeColors.primary,
                      ),
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Pindai daun lain'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Saved Badge (muncul setelah berhasil save) ───────────────────────────────

class _SavedBadge extends StatelessWidget {
  const _SavedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: MaizeColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark, color: MaizeColors.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            'Tersimpan di Riwayat ✓',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: MaizeColors.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result Hero ──────────────────────────────────────────────────────────────

class _ResultHero extends StatelessWidget {
  const _ResultHero({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imagePath != null
                ? Image.file(File(imagePath!), fit: BoxFit.cover)
                : Container(
                    color: MaizeColors.surfaceContainer,
                    child: const Icon(Icons.image, size: 80),
                  ),
            const _Marker(top: 0.3, left: 0.4, size: 48),
            const _Marker(top: 0.5, left: 0.25, size: 40),
            const _Marker(top: 0.2, right: 0.3, size: 54),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MaizeColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: MaizeColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Analysis Complete',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: MaizeColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({this.top, this.left, this.right, required this.size});

  final double? top;
  final double? left;
  final double? right;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top != null ? size * top! * 2 : null,
      left: left != null ? size * left! * 2 : null,
      right: right != null ? size * right! * 2 : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MaizeColors.error, width: 2),
          color: MaizeColors.error.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

// ─── Diagnosis Card ───────────────────────────────────────────────────────────

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({required this.textTheme, required this.result});

  final TextTheme textTheme;

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaizeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MaizeColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result['prediction'] ?? '-'),
                    Text(result['cause'] ?? '-'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(0xFF93000A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'High Priority',
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF93000A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('AI Confidence Score', style: textTheme.labelLarge),
              const Spacer(),
              Text(
                '${result['confidence']}%',
                style: textTheme.titleLarge?.copyWith(
                  color: MaizeColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ((result['confidence'] ?? 0) / 100),
              minHeight: 8,
              color: MaizeColors.secondary,
              backgroundColor: MaizeColors.surfaceContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Disease Profile ──────────────────────────────────────────────────────────

class _DiseaseProfile extends StatelessWidget {
  const _DiseaseProfile({required this.textTheme, required this.result});

  final TextTheme textTheme;

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: MaizeColors.secondary),
            const SizedBox(width: 6),
            Text(
              'Disease Profile',
              style: textTheme.titleLarge?.copyWith(
                color: MaizeColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          result['cause'] ?? 'Informasi penyakit tidak tersedia',
          style: textTheme.bodyMedium?.copyWith(
            color: MaizeColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Action Plan ──────────────────────────────────────────────────────────────

class _ActionPlan extends StatelessWidget {
  const _ActionPlan({required this.textTheme, required this.solution});

  final TextTheme textTheme;
  final List<dynamic> solution;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Icon(Icons.healing, color: MaizeColors.secondary),

            const SizedBox(width: 6),

            Text(
              'Recommended Action Plan',
              style: textTheme.titleLarge?.copyWith(
                color: MaizeColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        for (final item in solution)
          _ActionCard(
            icon: Icons.check_circle,
            title: 'Solusi',
            text: item.toString(),
            iconBackground: MaizeColors.secondaryContainer,
            iconColor: MaizeColors.onSecondaryContainer,
          ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.iconBackground,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MaizeColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: MaizeColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: textTheme.bodySmall?.copyWith(
                    color: MaizeColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
