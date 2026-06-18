/// Model data untuk satu hasil scan yang disimpan ke history.
class ScanRecord {
  ScanRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
    required this.solution,
  });

  final String id;
  final String title;
  final String subtitle;
  final String status;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  final List<String> solution;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'status': status,
    'confidence': confidence,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
    'solution': solution,
  };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
    id: json['id'],
    title: json['title'],
    subtitle: json['subtitle'],
    status: json['status'],
    confidence: (json['confidence'] as num).toDouble(),
    imagePath: json['imagePath'],
    timestamp: DateTime.parse(json['timestamp']),
    solution: List<String>.from(json['solution'] ?? []),
  );

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays == 0) {
      final h = timestamp.hour.toString().padLeft(2, '0');
      final m = timestamp.minute.toString().padLeft(2, '0');
      return 'Today, $h:$m';
    } else if (diff.inDays == 1) {
      final h = timestamp.hour.toString().padLeft(2, '0');
      final m = timestamp.minute.toString().padLeft(2, '0');
      return 'Yesterday, $h:$m';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}, '
          '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
