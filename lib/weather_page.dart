import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weatherly/cities.dart';
import 'package:weatherly/longlat.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? _currentLocation = 'Loading...';
  int _currentDegree = 0;
  LatLng _longLat = LatLng(0, 0);

  final List<String> _cities = getCities();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getLongLat(_currentLocation);
    _getCurrentDegree();
  }

  Future<void> _getLongLat(String? location) async {}

  Future<void> _getCurrentDegree() async {}

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
              Row(
                children: [],
              ),
              ElevatedButton(
                onPressed: () {
                  print(_currentLocation);
                },
                child: Text('Change Theme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
