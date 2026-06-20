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
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'Semua';
  String searchText = '';

  final filters = ['Semua', 'Daun Sehat', 'Karat Daun', 'Hawar Daun', 'Bulai'];

  @override
  void initState() {
    super.initState();
    HistoryService.instance.addListener(refresh);

    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.toLowerCase();
      });
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    HistoryService.instance.removeListener(refresh);
    searchController.dispose();
    super.dispose();
  }

  List<ScanRecord> get filteredData {
    var data = HistoryService.instance.records;

    if (selectedFilter != 'Semua') {
      data = data.where((item) => formatTitle(item.title) == selectedFilter).toList();
    }

    if (searchText.isNotEmpty) {
      data = data.where((item) {
        final title = formatTitle(item.title).toLowerCase();
        return title.contains(searchText);
      }).toList();
    }

    return data;
  }

  String formatTitle(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('karat')) {
      return 'Karat Daun';
    }
    if (lower.contains('hawar')) {
      return 'Hawar Daun';
    }
    if (lower.contains('bulai')) {
      return 'Bulai';
    }
    if (lower.contains('sehat') || lower.contains('healthy')) {
      return 'Daun Sehat';
    }
    return 'Tidak diketahui';
  }

  Future<void> deleteAll() async {
    await HistoryService.instance.clear();
  }

  void _openInsights(ScanRecord item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InsightsScreen(
          imagePath: item.imagePath,
          readOnly: true,
          result: {
            'class': item.title,
            'confidence': item.confidence,
            'Penyebab': item.subtitle,
            'Solusi': item.solution,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MaizeColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const MaizeAppBar(),
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
                            const Text(
                              'Riwayat Pindai',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tinjau kembali hasil diagnostik lapangan sebelumnya.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: deleteAll,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari berdasarkan penyakit atau status...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final item = filters[index];
                        final active = selectedFilter == item;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = item;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xffDDF5D8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                color: active ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w600,
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
            const SizedBox(height: 12),
            Expanded(
              child: filteredData.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) async {
                            await HistoryService.instance.remove(item.id);
                          },
                          child: InkWell(
                            onTap: () => _openInsights(item),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(item.imagePath),
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formatTitle(item.title),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          item.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _StatusPill(
                                              status: formatTitle(item.title),
                                            ),
                                            const Spacer(),
                                            Text(
                                              item.formattedTime,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _openInsights(item),
                                    icon: const Icon(Icons.chevron_right),
                                    splashRadius: 20,
                                  ),
                                ],
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
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (status) {
      case 'Daun Sehat':
        bg = const Color(0xffC8F2C2);
        text = const Color(0xff2E7D32);
        break;
      case 'Karat Daun':
        bg = const Color(0xffffcccc);
        text = const Color(0xffC62828);
        break;
      case 'Hawar Daun':
        bg = const Color(0xffffed99);
        text = const Color(0xff8D6E00);
        break;
      case 'Bulai':
        bg = const Color(0xffD6E4FF);
        text = const Color(0xff1565C0);
        break;
      default:
        bg = Colors.grey.shade200;
        text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
