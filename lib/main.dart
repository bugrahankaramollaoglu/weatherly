import 'package:flutter/material.dart';
import 'package:weatherly/weather_page.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherPage(),
    ),
  );
}
