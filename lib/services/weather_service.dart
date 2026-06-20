import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _fallbackLatitude = -6.2088;
  static const _fallbackLongitude = 106.8456;

  static Future<Map<String, dynamic>> getCurrentWeather() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    Position position;

    if (!serviceEnabled) {
      position = Position(
        longitude: _fallbackLongitude,
        latitude: _fallbackLatitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } else if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        position = Position(
          longitude: _fallbackLongitude,
          latitude: _fallbackLatitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      } else {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
      }
    } else {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
      } catch (_) {
        position = Position(
          longitude: _fallbackLongitude,
          latitude: _fallbackLatitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${position.latitude}'
      '&longitude=${position.longitude}'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&timezone=Asia/Singapore',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data cuaca');
    }

    final weatherData = jsonDecode(response.body);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'weather': weatherData,
    };
  }
}
