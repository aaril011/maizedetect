import 'package:flutter/material.dart';
import 'history_service.dart';
import 'maize_theme.dart';
import 'widgets/maize_app_bar.dart';
import 'package:maizedetect/services/weather_service.dart';

/// Hero background from Stitch Dashboard screen HTML (corn field).
const String _kHeroImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAh4MrKn4a9Tcc-Z_9nA5lVAJpu7U6TFTCBG62A9uBwxW2d1bTOcDONlD49ehTfhP87MXkAnUsvlIUmarhlX0rxGBhLUzEdTEiQ0ZMEUaMjQtx9mQnESMouqSj8iAAGBym0FVL_wMjOXe8j50MmtbzwFodycKymv5K5EKWImDFmP07RwN-L21uc-MrzgONhJQENf5vbdtJDwkLku39_sdXPMzD1wLEpDSCjwHgwcGO4nECNGOKuoDPEIfi2vbrBi3BgISs5KbVeoco';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onTapScan});

  final VoidCallback? onTapScan;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoadingWeather = true;

  int get totalRecords => HistoryService.instance.records.length;

  int get healthyCount => HistoryService.instance.records
      .where((record) => record.title.contains('Sehat') || record.title.contains('healthy'))
      .length;

  int get diseaseCount => totalRecords - healthyCount;

  double get healthyPercent => totalRecords == 0 ? 0 : (healthyCount / totalRecords) * 100;
  double get diseasePercent => totalRecords == 0 ? 0 : (diseaseCount / totalRecords) * 100;

  Widget _healthCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade200),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1,
                color: Color(0xff111111),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    HistoryService.instance.addListener(_refreshStats);
    _loadWeather();
  }

  @override
  void dispose() {
    HistoryService.instance.removeListener(_refreshStats);
    super.dispose();
  }

  void _refreshStats() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadWeather() async {
    try {
      final data = await WeatherService.getCurrentWeather();

      if (!mounted) return;

      setState(() {
        weatherData = data;
        isLoadingWeather = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: MaizeColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MaizeAppBar(),
            Expanded(
              child: SingleChildScrollView(
                clipBehavior: Clip.hardEdge, // ✅ PERBAIKAN: Tambahkan clipBehavior
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // ✅ PERBAIKAN: Ubah bottom padding dari 40 menjadi 16
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroSection(
                      textTheme: textTheme,
                      onTapScan: widget.onTapScan,
                      weatherData: weatherData,
                      isLoading: isLoadingWeather,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ringkasan Kesehatan Lahan',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MaizeColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _healthCard(
                      icon: Icons.eco_outlined,
                      title: 'Kondisi Tanaman',
                      value: '${healthyPercent.toStringAsFixed(0)}%',
                      subtitle: '$healthyCount dari $totalRecords hasil identifikasi',
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _healthCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Kelembaban Udara',
                      value: weatherData != null
                          ? '${(weatherData!['weather']['current']?['relative_humidity_2m'] ?? 0)}%'
                          : '--%',
                      subtitle: weatherData != null
                          ? 'Berdasarkan cuaca saat ini'
                          : 'Sedang memuat data',
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _healthCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Risiko Penyakit',
                      value: '${diseasePercent.toStringAsFixed(0)}%',
                      subtitle: '$diseaseCount hasil dengan potensi masalah',
                      iconColor: Colors.red,
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.textTheme,
    this.onTapScan,
    this.weatherData,
    this.isLoading = false,
  });

  final TextTheme textTheme;
  final VoidCallback? onTapScan;
  final Map<String, dynamic>? weatherData;
  final bool isLoading;

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
      case 2:
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      case 95:
        return 'Badai';
      default:
        return 'Tidak diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = weatherData?['weather']?['current'];
    final temperature = current?['temperature_2m'];
    final humidity = current?['relative_humidity_2m'];
    final weatherCode = current?['weather_code'] ?? 0;
    final description = getWeatherDescription(weatherCode);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _HeroBackground(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    MaizeColors.primary,
                    MaizeColors.primary.withValues(alpha: 0.88),
                    MaizeColors.primary.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Kondisi Lapangan',
                    style: textTheme.labelLarge?.copyWith(
                      color: MaizeColors.primaryFixed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLoading
                        ? 'Memuat cuaca...'
                        : '$description • ${temperature?.toStringAsFixed(0) ?? '--'}°C',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MaizeColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        color: MaizeColors.onPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLoading
                            ? 'Sedang mengambil data cuaca'
                            : 'Kelembapan $humidity%',
                        style: textTheme.bodyLarge?.copyWith(
                          color: MaizeColors.inverseOnSurface.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Lahan sedang dalam kondisi baik untuk pemeriksaan rutin.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: MaizeColors.onPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // ✅ Kurangi dari 12 menjadi 8
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: MaizeColors.tertiaryFixed,
                        foregroundColor: MaizeColors.tertiaryContainer,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6, // ✅ Kurangi dari 8 menjadi 6
                          horizontal: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        minimumSize: const Size(0, 40), // ✅ Kurangi dari 46 menjadi 40
                      ),
                      onPressed: onTapScan,
                      icon: const Icon(
                        Icons.center_focus_strong,
                        size: 18,
                      ),
                      label: const Text(
                        'Pindai',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.0,
                        ),
                      ),
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

class _HeroBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      _kHeroImageUrl,
      fit: BoxFit.cover,
      color: Colors.white.withValues(alpha: 0.5),
      colorBlendMode: BlendMode.overlay,
      errorBuilder: (context, error, stackTrace) =>
          ColoredBox(color: MaizeColors.primaryContainer),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(color: MaizeColors.primaryContainer);
      },
    );
  }
}