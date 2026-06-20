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
  bool saved = false;
  bool saving = false;

  String get diseaseName {
    final raw = widget.result.entries
        .where((entry) => entry.key.toString().toLowerCase().contains('class') ||
            entry.key.toString().toLowerCase().contains('label') ||
            entry.key.toString().toLowerCase().contains('pred') ||
            entry.key.toString().toLowerCase().contains('title'))
        .map((entry) => entry.value)
        .cast<String>()
        .firstOrNull;

    final value = raw ?? widget.result['class'] ?? widget.result['label'] ?? widget.result['prediction'] ?? widget.result['title'] ?? '';

    final text = value.toString();
    final lower = text.toLowerCase();

    if (lower.contains('bulai')) return 'Bulai';
    if (lower.contains('hawar')) return 'Hawar Daun';
    if (lower.contains('karat')) return 'Karat Daun';
    if (lower.contains('sehat') || lower.contains('healthy')) return 'Daun Sehat';

    return text.isEmpty ? 'Hasil Deteksi' : text;
  }

  String get causeText {
    final keys = [
      'Penyebab',
      'penyebab',
      'cause',
      'Cause',
      'description',
      'profil'
    ];

    for (final key in keys) {
      if (widget.result[key] != null && widget.result[key].toString().isNotEmpty) {
        return widget.result[key].toString();
      }
    }

    return 'Informasi penyakit tidak tersedia';
  }

  List<String> get actionItems {
    final raw = widget.result['Solusi'] ??
        widget.result['solusi'] ??
        widget.result['solution'] ??
        widget.result['actions'] ??
        widget.result['rekomendasi'] ??
        [];

    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    if (raw is String) {
      return raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return [];
  }

  double get confidenceValue {
    final rawValue = widget.result['confidence'];
    if (rawValue is num) {
      final value = rawValue.toDouble();
      return value > 1 ? value : value * 100;
    }
    return 0;
  }

  Future<void> saveHistory() async {
    if (saved) return;

    setState(() => saving = true);

    final record = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: diseaseName,
      subtitle: causeText,
      status: diseaseName,
      confidence: confidenceValue / 100,
      imagePath: widget.imagePath ?? '',
      timestamp: DateTime.now(),
      solution: actionItems,
    );

    await HistoryService.instance.add(record);

    if (!mounted) return;

    setState(() {
      saved = true;
      saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaizeColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MaizeAppBar(
              centerTitle: 'Hasil Pindai',
              showLogo: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ImagePreview(path: widget.imagePath),
                    const SizedBox(height: 16),
                    _ResultCard(
                      title: diseaseName,
                      confidence: confidenceValue,
                    ),
                    const SizedBox(height: 20),
                    _Profile(text: causeText),
                    const SizedBox(height: 20),
                    _ActionPlan(items: actionItems),
                    const SizedBox(height: 20),
                    if (!widget.readOnly)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 360;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: isWide
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth,
                                child: FilledButton.icon(
                                  onPressed: saving ? null : saveHistory,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: MaizeColors.primary,
                                    foregroundColor: MaizeColors.onPrimary,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.bookmark_add),
                                  label: Text(
                                    saved ? 'Tersimpan' : 'Simpan Riwayat',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: isWide
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text(
                                    'Ulangi',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 1,
        child: path != null
            ? Image.file(File(path!), fit: BoxFit.cover)
            : Container(color: Colors.grey.shade200),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.title, required this.confidence});

  final String title;
  final double confidence;

  Color get color {
    if (title == 'Bulai') return Colors.blue;
    if (title == 'Hawar Daun') return Colors.amber;
    if (title == 'Karat Daun') return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text('Skor Prediksi AI'),
              const Spacer(),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (confidence / 100).clamp(0.0, 1.0),
            minHeight: 8,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text(
              'Profil Penyakit',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(text, style: const TextStyle(height: 1.5, fontSize: 15)),
      ],
    );
  }
}

class _ActionPlan extends StatelessWidget {
  const _ActionPlan({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rencana Tindakan yang Direkomendasikan',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('Belum ada rencana tindakan.'),
          )
        else
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
