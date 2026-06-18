import 'dart:io';

import 'package:flutter/material.dart';

import 'history_service.dart';
import 'insights_screen.dart';
import 'maize_theme.dart';
import 'scan_record.dart';
import 'widgets/maize_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  static const _filters = [
    'Semua',
    'Sehat',
    'Karat Daun',
    'Hawar Daun',
    'Bulai',
  ];

  @override
  void initState() {
    super.initState();
    HistoryService.instance.addListener(_onHistoryChanged);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    HistoryService.instance.removeListener(_onHistoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onHistoryChanged() => setState(() {});

  List<ScanRecord> get _filtered {
    var list = HistoryService.instance.records;

    // Filter by status
    if (_selectedFilter != 'Semua') {
      list = list.where((r) => r.status == _selectedFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (r) =>
                r.title.toLowerCase().contains(_searchQuery) ||
                r.subtitle.toLowerCase().contains(_searchQuery) ||
                r.status.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return list;
  }

  Future<void> _deleteRecord(ScanRecord record) async {
    await HistoryService.instance.remove(record.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Record dihapus'),
          action: SnackBarAction(
            label: 'Batal',
            onPressed: () async {
              await HistoryService.instance.add(record);
            },
          ),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hapus Semua History?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Semua data riwayat hasil scan akan '
                  'dihapus secara permanen.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx, false);
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),

                      onPressed: () {
                        Navigator.pop(ctx, true);
                      },

                      child: const Text(
                        'Hapus Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await HistoryService.instance.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filtered;

    return ColoredBox(
      color: MaizeColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const MaizeAppBar(),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Riwayat Pindai',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Tinjau kembali hasil diagnostik lapangan sebelumnya.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: MaizeColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 24,
                              ),
                              tooltip: 'Hapus semua history',
                              color: Colors.red,
                              onPressed: _clearAll,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SearchAndFilterBar(
                          controller: _searchController,
                          selectedFilter: _selectedFilter,
                          filters: _filters,
                          onFilterSelected: (f) =>
                              setState(() => _selectedFilter = f),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? _EmptyState(
                            hasRecords: HistoryService.instance.records.isEmpty,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: MaizeColors.error.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: MaizeColors.error,
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  await _deleteRecord(item);
                                  return false;
                                },
                                child: _HistoryCard(
                                  item: item,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InsightsScreen(
                                        imagePath: item.imagePath.isEmpty
                                            ? null
                                            : item.imagePath,
                                        readOnly: true,
                                        result: {},
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search & Filter Bar ─────────────────────────────────────────────────────

class _SearchAndFilterBar extends StatefulWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterSelected,
  });

  final TextEditingController controller;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterSelected;

  @override
  State<_SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<_SearchAndFilterBar> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: MaizeColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari penyakit atau status...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 21,
                color: MaizeColors.primary,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 19),
                      onPressed: () {
                        widget.controller.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.filters.length,
            itemBuilder: (context, index) {
              final filter = widget.filters[index];
              final active = filter == widget.selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    widget.onFilterSelected(filter);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFDFF4D8) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? Colors.transparent
                            : MaizeColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap});

  final ScanRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: MaizeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MaizeColors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1403271A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _thumbnail(item.imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MaizeColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: MaizeColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusPill(status: item.status),
                      const Spacer(),
                      Text(
                        item.formattedTime,
                        style: textTheme.labelSmall?.copyWith(
                          color: MaizeColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: MaizeColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(String path) {
    if (path.isNotEmpty && File(path).existsSync()) {
      return Image.file(File(path), width: 92, height: 92, fit: BoxFit.cover);
    }
    return Container(
      width: 92,
      height: 92,
      color: MaizeColors.surfaceContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.grass,
        color: MaizeColors.primary.withValues(alpha: 0.4),
        size: 36,
      ),
    );
  }
}

// ─── Status Pill ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Sehat':
        bg = const Color(0xFFC8F2C2);
        fg = const Color(0xFF1B5E20);
        break;

      case 'Karat Daun':
        bg = const Color(0xFFFFCDD2);
        fg = const Color(0xFFC62828);
        break;

      case 'Hawar Daun':
        bg = const Color(0xFFFFEB99);
        fg = const Color(0xFF8D6E00);
        break;

      case 'Bulai':
        bg = const Color(0xFFD6E4FF);
        fg = const Color(0xFF1E40AF);
        break;

      default:
        bg = Colors.grey.shade200;
        fg = Colors.black87;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasRecords});

  /// true jika memang belum ada record sama sekali (bukan karena filter)
  final bool hasRecords;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasRecords ? Icons.history : Icons.search_off_rounded,
              size: 72,
              color: MaizeColors.primary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              hasRecords
                  ? 'Belum ada history scan'
                  : 'Tidak ada hasil yang cocok',
              style: textTheme.titleMedium?.copyWith(
                color: MaizeColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasRecords
                  ? 'Setelah scan daun jagung, simpan hasilnya dan akan muncul di sini.'
                  : 'Coba ubah kata kunci atau filter yang dipilih.',
              style: textTheme.bodySmall?.copyWith(
                color: MaizeColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
