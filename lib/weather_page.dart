import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:weatherly/cities.dart';

class MyWeather {
  String date = '';
  String day = '';
  String icon = '';
  String description = '';
  String status = '';
  String degree = '';
  String min = '';
  String max = '';
  String night = '';
  String humidity = '';

  MyWeather({
    required this.date,
    required this.day,
    required this.icon,
    required this.description,
    required this.status,
    required this.degree,
    required this.min,
    required this.max,
    required this.night,
    required this.humidity,
  });
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? _currentLocation = 'Deneme...';
  int _currentDegree = 0;
  LatLng _currentLatLng = const LatLng(0, 0);
  String? _apiResponse = 'empty response';
  MyWeather myWeather = MyWeather(
    date: '',
    day: '',
    icon: '',
    description: '',
    status: '',
    degree: '',
    min: '',
    max: '',
    night: '',
    humidity: '',
  );

  final List<String> _cities = getCities();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    print('CALISTIIIIIIIIIIIIIIIIIIIIIIIII');
    await _getCurrentLocation();
    fetchWeather();
  }

  String? kapitalize(String? str) {
    if (str == null) {
      return null;
    }

    return str[0].toUpperCase() + str.substring(1);
  }

  Future<void> _getLongLat(String? location) async {
    if (location == null) {
      return;
    }

    location = kapitalize(location);

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
      // final jsonResponse = json.decode(_apiResponse!);
      // final List<dynamic> results = jsonResponse['result'];

      // Parse the JSON string
      Map<String, dynamic> jsonMap = json.decode(_apiResponse!);

      // Extract the first element from the result array
      Map<String, dynamic> firstResult = jsonMap['result'][0];

      // Store the properties in separate variables
      myWeather.date = firstResult['date'];
      myWeather.day = firstResult['day'];
      myWeather.icon = firstResult['icon'];
      myWeather.description = firstResult['description'];
      myWeather.status = firstResult['status'];
      myWeather.degree = firstResult['degree'];
      myWeather.min = firstResult['min'];
      myWeather.max = firstResult['max'];
      myWeather.night = firstResult['night'];
      myWeather.humidity = firstResult['humidity'];

      // Extract degree from the first element
      // final firstDegree = results.isNotEmpty ? results[0]['degree'] : null;

      setState(() {
        _currentDegree = double.parse(myWeather.degree).toInt();
      });
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

      String? location;

      String placemarksStr = placemarks.toString();
      List<String> words = placemarksStr.split(' ');

      for (int i = 0; i < words.length; i++) {
        words[i] = words[i].toLowerCase().replaceAll(',', '');
      }

      print(words);

      for (String word in words) {
        String lowercaseWord = word.toLowerCase();

        if (_cities.contains(lowercaseWord)) {
          location =
              _cities.firstWhere((city) => city.toLowerCase() == lowercaseWord);
          break;
        }
      }

      print('location: $location');

      if (location != null && location.isNotEmpty) {
        setState(() {
          _currentLocation = location;
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
        child: RefreshIndicator(
          onRefresh: () => _initializeLocation(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Column(
              children: [
                Text(
                  (_currentLocation)!,
                  style: GoogleFonts.habibi(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Image.network('${myWeather.icon}'),
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
      ),
    );
  }
}
