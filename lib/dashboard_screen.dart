import 'package:flutter/material.dart';
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

  Map<String, dynamic>? weatherData;
  bool isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroSection(
                      textTheme: textTheme,
                      onTapScan: widget.onTapScan,
                    ),
                    const SizedBox(height: 24),
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
                      value: '94%',
                      subtitle: '+2% dari minggu lalu',
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _healthCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Kelembaban Tanah',
                      value: 'Cukup',
                      subtitle: 'Kondisi stabil',
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _healthCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Risiko Penyakit',
                      value: 'Rendah',
                      subtitle: 'Pemeriksaan berikutnya: 3 hari',
                      iconColor: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Kondisi Lapangan',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MaizeColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _WeatherPanel(
                      textTheme: textTheme,
                      weatherData: weatherData,
                      isLoading: isLoadingWeather,
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
  const _HeroSection({required this.textTheme, this.onTapScan});

  final TextTheme textTheme;
  final VoidCallback? onTapScan;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 280,
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
                    MaizeColors.primary.withValues(alpha: 0.85),
                    MaizeColors.primary.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Pembaruan Pagi',
                    style: textTheme.labelLarge?.copyWith(
                      color: MaizeColors.primaryFixed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kondisi lapangan terlihat stabil hari ini.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MaizeColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kondisinya menguntungkan, tidak ada masalah mendesak yang teridentifikasi untuk lahan di bagian utama.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MaizeColors.inverseOnSurface.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: MaizeColors.tertiaryFixed,
                        foregroundColor: MaizeColors.tertiaryContainer,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: onTapScan,
                      icon: const Icon(Icons.center_focus_strong),
                      label: const Text(
                        'Pindai Sekarang',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

class _WeatherPanel extends StatelessWidget {
  const _WeatherPanel({
    required this.textTheme,
    required this.weatherData,
    required this.isLoading,
  });

  final TextTheme textTheme;
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
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (weatherData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Gagal memuat data cuaca'),
        ),
      );
    }

    final current = weatherData!['weather']['current'];

    final temperature = current['temperature_2m'];
    final humidity = current['relative_humidity_2m'];
    final windSpeed = current['wind_speed_10m'];
    final weatherCode = current['weather_code'];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MaizeColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MaizeColors.surfaceVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HARI INI',
                        style: textTheme.labelLarge?.copyWith(
                          color: MaizeColors.onSurfaceVariant,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$temperature°C',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: MaizeColors.onSurface,
                        ),
                      ),
                      Text(
                        getWeatherDescription(weatherCode),
                        style: textTheme.bodyMedium?.copyWith(
                          color: MaizeColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.wb_cloudy_outlined,
                  size: 48,
                  color: MaizeColors.secondary,
                ),
              ],
            ),
            Divider(height: 32, color: MaizeColors.outlineVariant),
            _weatherRow(textTheme, 'Angin', '$windSpeed km/h'),
            const SizedBox(height: 8),
            _weatherRow(textTheme, 'Kelembaban', '$humidity%'),
          ],
        ),
      ),
    );
  }

  Widget _weatherRow(TextTheme textTheme, String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: MaizeColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: MaizeColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
