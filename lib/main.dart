import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.dark,
        ),
      ),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _cityController = TextEditingController();
  String _cityName = 'Karachi';
  String _country = 'Pakistan';
  double _temp = 0;
  double _feelsLike = 0;
  int _humidity = 0;
  double _windSpeed = 0;
  String _condition = 'Loading...';
  String _icon = '☀️';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather('Karachi');
  }

  Future<void> _loadWeather(String city) async {
    setState(() => _loading = true);
    try {
      // Geocode
      final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
      );
      final geoRes = await http.get(geoUrl);
      final geoData = json.decode(geoRes.body);

      if (geoData['results'] == null || geoData['results'].isEmpty) {
        setState(() {
          _condition = 'City not found';
          _loading = false;
        });
        return;
      }

      final loc = geoData['results'][0];
      final lat = loc['latitude'];
      final lon = loc['longitude'];

      // Weather
      final wUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&timezone=auto',
      );
      final wRes = await http.get(wUrl);
      final wData = json.decode(wRes.body);
      final c = wData['current'];

      setState(() {
        _cityName = loc['name'] ?? city;
        _country = loc['country'] ?? '';
        _temp = (c['temperature_2m'] as num).toDouble();
        _feelsLike = (c['apparent_temperature'] as num).toDouble();
        _humidity = (c['relative_humidity_2m'] as num).toInt();
        _windSpeed = (c['wind_speed_10m'] as num).toDouble();
        _condition = _weatherDesc(c['weather_code'] as int);
        _icon = _weatherIcon(c['weather_code'] as int);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _condition = 'Error: ${e.toString().substring(0, 30)}';
        _loading = false;
      });
    }
  }

  String _weatherDesc(int code) {
    const m = {
      0: 'Clear sky', 1: 'Mainly clear', 2: 'Partly cloudy', 3: 'Overcast',
      45: 'Fog', 48: 'Rime fog', 51: 'Light drizzle', 53: 'Drizzle', 55: 'Dense drizzle',
      61: 'Slight rain', 63: 'Moderate rain', 65: 'Heavy rain',
      71: 'Slight snow', 73: 'Snow', 75: 'Heavy snow',
      95: 'Thunderstorm', 96: 'Thunderstorm with hail', 99: 'Heavy thunderstorm',
    };
    return m[code] ?? 'Unknown';
  }

  String _weatherIcon(int code) {
    if (code == 0 || code == 1) return '☀️';
    if (code == 2 || code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 65) return '🌧️';
    if (code >= 71 && code <= 75) return '❄️';
    if (code >= 95) return '⛈️';
    return '☀️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C4F), Color(0xFF2C5364), Color(0xFF3A6B8A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search city...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) _loadWeather(v.trim());
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final v = _cityController.text.trim();
                        if (v.isNotEmpty) _loadWeather(v);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.13),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Go'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Main card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          children: [
                            Text(
                              '$_cityName, $_country'.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(_icon, style: const TextStyle(fontSize: 80)),
                            const SizedBox(height: 10),
                            Text(
                              '${_temp.round()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 90,
                                fontWeight: FontWeight.w200,
                                height: 1,
                              ),
                            ),
                            Text(
                              _condition,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _detail('WIND', '${_windSpeed.round()} km/h'),
                                _detail('HUMIDITY', '$_humidity%'),
                                _detail('FEELS', '${_feelsLike.round()}°'),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
