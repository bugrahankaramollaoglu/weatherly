import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:weatherly/cities.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? _currentLocation = 'Deneme...';
  int _currentDegree = 0;
  LatLng _currentLatLng = const LatLng(0, 0);
  String? _apiResponse = 'asd';

  final List<String> _cities = getCities();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    fetchWeather();
  }

  Future<void> _getLongLat(String? location) async {
    if (location == null) {
      return;
    }

    final Map<String, LatLng> coordinates = getCoordinates();
    _currentLatLng = coordinates[location] ?? const LatLng(31, 31);
  }

  Future<void> fetchWeather() async {
/* curl --request GET  --url 'https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=artvin'
--header 'authorization: apikey 7vKjwRWY743SxEXH2pg9g2:5xQeRee2G7KQhuO9bIZHU8' */

    String locationn = _currentLocation!.toLowerCase();

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$locationn',
        ),
        headers: {
          'authorization':
              'apikey 7vKjwRWY743SxEXH2pg9g2:5xQeRee2G7KQhuO9bIZHU8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _apiResponse = response.body;
          _getCurrentDegree();
        });
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _apiResponse = 'Error: $e';
      });
    }
  }

  Future<void> _getCurrentDegree() async {
    try {
      // Parse JSON response
      final jsonResponse = json.decode(_apiResponse!);
      final List<dynamic> results = jsonResponse['result'];

      // Extract degree from the first element
      final firstDegree = results.isNotEmpty ? results[0]['degree'] : null;

      if (firstDegree != null) {
        setState(() {
          _currentDegree = double.parse(firstDegree).toInt();
        });
      } else {
        throw Exception('No degree value found');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _currentDegree = 0;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Permission denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String? locality;
      for (Placemark placemark in placemarks) {
        String city = placemark.locality ?? '';
        String city2 = placemark.administrativeArea ?? '';
        if (_cities.contains(city)) {
          locality = city;
          break;
        }
        if (_cities.contains(city2)) {
          locality = city2;
          break;
        }
      }

      if (locality != null && locality.isNotEmpty) {
        setState(() {
          _currentLocation = locality;
        });
      } else {
        setState(() {
          _currentLocation = 'Unknown';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Error getting location';
      });
    }
    _getLongLat(_currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            children: [
              Text(
                _currentLocation!,
                style: GoogleFonts.roboto(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Image.network(
                  'https://static.vecteezy.com/system/resources/previews/020/716/723/original/3d-minimal-weather-forecast-concept-partly-cloudy-in-the-morning-weather-icon-3d-illustration-png.png'),
              Text(
                '$_currentDegree°',
                style: GoogleFonts.lato(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Row(
                children: [],
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Change Theme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
