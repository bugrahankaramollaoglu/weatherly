import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/cities.dart';
import 'package:weatherly/weather_page.dart';

import 'weather_page.dart';

class CurrentWeather {
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

  CurrentWeather({
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

class NextDayWeather {
  String day;
  String icon;
  String degree;

  NextDayWeather({
    required this.day,
    required this.icon,
    required this.degree,
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
  String selectedCity = '';
  bool _isDropdownOpen = false;

  LatLng _currentLatLng = const LatLng(0, 0);
  String? _apiResponse = 'empty response';

  CurrentWeather currentWeather = CurrentWeather(
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
    initializeDateFormatting('tr', null);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
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
      Map<String, dynamic> jsonMap = json.decode(_apiResponse!);

      // Ensure 'result' key exists and contains at least one element
      if (jsonMap.containsKey('result') && jsonMap['result'].isNotEmpty) {
        Map<String, dynamic> firstResult = jsonMap['result'][0];

        setState(() {
          currentWeather.date = firstResult['date'] ?? '';
          currentWeather.day = firstResult['day'] ?? '';
          currentWeather.icon = firstResult['icon'] ?? '';
          currentWeather.description = firstResult['description'] ?? '';
          currentWeather.status = firstResult['status'] ?? '';
          currentWeather.degree = firstResult['degree'] ?? '0';
          currentWeather.min = firstResult['min'] ?? '';
          currentWeather.max = firstResult['max'] ?? '';
          currentWeather.night = firstResult['night'] ?? '0';
          currentWeather.humidity = firstResult['humidity'] ?? '';

          _currentDegree = double.parse(currentWeather.degree).toInt();
          currentWeather.date = formatDate(currentWeather.date);
        });
      } else {
        throw Exception('Invalid response structure');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _currentDegree = 0;
      });
    }
  }

  String formatDate(String dateString) {
    // Parse the date string into a DateTime object
    DateTime date = DateFormat('dd.MM.yyyy').parse(dateString);

    // Format the DateTime object into "dd MonthName" format
    String formattedDate = DateFormat('dd MMMM', 'tr').format(date);

    return formattedDate;
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

      for (String word in words) {
        String lowercaseWord = word.toLowerCase();

        if (_cities.contains(lowercaseWord)) {
          location =
              _cities.firstWhere((city) => city.toLowerCase() == lowercaseWord);
          break;
        }
      }

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (_currentLocation)!,
                    style: GoogleFonts.habibi(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isDropdownOpen = !_isDropdownOpen;
                      });
                    },
                    iconSize: 35,
                    icon: Icon(Icons.location_on_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentWeather.date} ',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${currentWeather.day}',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30), // Add some spacing between widgets
              Container(
                width: 150, // Adjust the width as needed
                height: 150, // Adjust the height as needed
                child: Image.network('${currentWeather.icon}'),
              ),
              SizedBox(height: 30), // Add some spacing between widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_currentDegree°',
                    style: GoogleFonts.lato(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '/',
                    style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.w300,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    currentWeather.night.length >= 2
                        ? '${currentWeather.night.substring(0, 2)}°'
                        : '',
                    style: GoogleFonts.lato(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Add some spacing between widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Text('MON'),
                    Container(
                      width: 50, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                      child: Image.network('${currentWeather.icon}'),
                    ),
                    Text('40'),
                  ]),
                  Column(children: [
                    Text('MON'),
                    Container(
                      width: 50, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                      child: Image.network('${currentWeather.icon}'),
                    ),
                    Text('40'),
                  ]),
                  Column(children: [
                    Text('MON'),
                    Container(
                      width: 50, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                      child: Image.network('${currentWeather.icon}'),
                    ),
                    Text('40'),
                  ]),
                  Column(children: [
                    Text('MON'),
                    Container(
                      width: 50, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                      child: Image.network('${currentWeather.icon}'),
                    ),
                    Text('40'),
                  ]),
                  Column(children: [
                    Text('MON'),
                    Container(
                      width: 50, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                      child: Image.network('${currentWeather.icon}'),
                    ),
                    Text('40'),
                  ]),
                ],
              ),
              Row(
                children: [],
              ),
              SizedBox(
                height: 200,
              ),
              ElevatedButton(
                onPressed: () {
                  print('iste: ${currentWeather.date}');
                },
                child: const Text('Change Theme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
