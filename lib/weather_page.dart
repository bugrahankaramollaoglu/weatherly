import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/capitalize.dart';
import 'package:weatherly/cities.dart';

class CurrentWeather {
  String date = '';
  String day = '';
  String icon = '';
  String description = '';
  String status = '';
  String degree = '';
  String night = '';
  String humidity = '';

  CurrentWeather({
    required this.date,
    required this.day,
    required this.icon,
    required this.description,
    required this.status,
    required this.degree,
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
  String? _currentLocation = '...';
  int _currentDegree = 0;
  NextDayWeather day1 = NextDayWeather(day: '', icon: '', degree: '');
  NextDayWeather day2 = NextDayWeather(day: '', icon: '', degree: '');
  NextDayWeather day3 = NextDayWeather(day: '', icon: '', degree: '');
  NextDayWeather day4 = NextDayWeather(day: '', icon: '', degree: '');
  NextDayWeather day5 = NextDayWeather(day: '', icon: '', degree: '');
  String? _apiResponse = 'empty response';
  bool isDarkTheme = false;

  CurrentWeather currentWeather = CurrentWeather(
    date: '',
    day: '',
    icon: '',
    description: '',
    status: '',
    degree: '',
    night: '',
    humidity: '',
  );

  final List<String> _cities = getCities();

  void _showCityPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select a city'),
          actions: _cities.map((String city) {
            return CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _currentLocation = city;
                  _initializeLocation();
                });
                Navigator.pop(context);
              },
              child: Text(city),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

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

    // final Map<String, LatLng> coordinates = getCoordinates();
  }

  Future<void> fetchWeather() async {
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

      List<dynamic> resultList = jsonMap['result'];
      day1.day = resultList[1]['day'];
      day1.icon = resultList[1]['icon'];
      day1.degree = resultList[1]['degree'];

      day2.day = resultList[2]['day'];
      day2.icon = resultList[2]['icon'];
      day2.degree = resultList[2]['degree'];

      day3.day = resultList[3]['day'];
      day3.icon = resultList[3]['icon'];
      day3.degree = resultList[3]['degree'];

      day4.day = resultList[4]['day'];
      day4.icon = resultList[4]['icon'];
      day4.degree = resultList[4]['degree'];

      day5.day = resultList[5]['day'];
      day5.icon = resultList[5]['icon'];
      day5.degree = resultList[5]['degree'];

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
    DateTime date = DateFormat('dd.MM.yyyy').parse(dateString);

    String formattedDate = DateFormat('dd MMMM', 'tr').format(date);

    return formattedDate;
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Seçim yapınız...')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_rounded),
                title: const Text('Konuma Göre Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _showLocationPicker(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_rounded),
                title: const Text('Listeden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _showCityListDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context) {
    _initializeLocation();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Konumunuza göre ayarlandı.'),
    ));
  }

  void _showCityListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Bir şehir seçiniz')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _cities.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_cities[index].capitalize()),
                  onTap: () {
                    setState(() {
                      _currentLocation = _cities[index];
                      fetchWeather();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'İzin Verilmedi';
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
      backgroundColor: isDarkTheme
          ? const Color.fromARGB(255, 24, 24, 23)
          : Colors.lightBlueAccent.withOpacity(0.6),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (_currentLocation)!,
                  style: GoogleFonts.saira(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showDialog(context);
                      // _showCityPicker(context);
                      // _currentLocation = _selectedCity;
                      // _initializeLocation();
                    });
                  },
                  iconSize: 35,
                  icon: const Icon(Icons.location_on_rounded),
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
                  currentWeather.day,
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Add some spacing between widgets
            SizedBox(
              width: 150, // Adjust the width as needed
              height: 150, // Adjust the height as needed
              child: Image.network(currentWeather.icon),
            ),
            const SizedBox(height: 30), // Add some spacing between widgets
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
            const SizedBox(height: 50), // Add some spacing between widgets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text(
                    day1.day.substring(0, 3),
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                    child: Image.network(day1.icon),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${day1.degree.substring(0, 2)}°',
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
                Column(children: [
                  Text(
                    day2.day.substring(0, 3),
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                      height:
                          10), // Add a space of 10 pixels between the children

                  SizedBox(
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                    child: Image.network(day2.icon),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${day2.degree.substring(0, 2)}°',
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
                Column(children: [
                  Text(
                    day3.day.substring(0, 3),
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                    child: Image.network(day3.icon),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${day3.degree.substring(0, 2)}°',
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
                Column(children: [
                  Text(
                    day4.day.substring(0, 3),
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                    child: Image.network(day4.icon),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${day4.degree.substring(0, 2)}°',
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
                Column(children: [
                  Text(
                    day5.day.substring(0, 3),
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                    child: Image.network(day5.icon),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${day5.degree.substring(0, 2)}°',
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isDarkTheme = !isDarkTheme;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Adjust the border radius as needed
                ),
                backgroundColor: Colors.white, // Change the background color
                elevation: 15, // Adjust the elevation
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Adjust the padding
              ),
              child: const Text(
                'Temayı Değiştir',
                style: TextStyle(
                  fontSize: 16, // Adjust the font size
                  fontWeight: FontWeight.bold, // Adjust the font weight
                  color: Colors.black, // Change the text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
