import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> getCurrentWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif');
    }

    // Cek permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }

    // Ambil lokasi
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${position.latitude}'
      '&longitude=${position.longitude}'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&timezone=Asia/Singapore',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil cuaca');
    }

    final weatherData = jsonDecode(response.body);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'weather': weatherData,
    };
  }
}
