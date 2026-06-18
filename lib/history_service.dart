import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scan_record.dart';

/// Singleton service yang mengelola penyimpanan history scan ke device.
class HistoryService extends ChangeNotifier {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  static const _key = 'scan_history';

  List<ScanRecord> _records = [];

  /// Daftar record diurutkan terbaru ke terlama.
  List<ScanRecord> get records => List.unmodifiable(_records);

  /// Muat data dari SharedPreferences. Panggil sekali saat startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _records = raw
        .map((e) {
          try {
            return ScanRecord.fromJson(
                jsonDecode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ScanRecord>()
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  /// Simpan record baru ke history.
  Future<void> add(ScanRecord record) async {
    _records.insert(0, record);
    await _persist();
    notifyListeners();
  }

  /// Hapus satu record berdasarkan id.
  Future<void> remove(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  /// Hapus semua history.
  Future<void> clear() async {
    _records.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _records
        .map((r) => jsonEncode(r.toJson()))
        .toList();
    await prefs.setStringList(_key, raw);
  }
}
