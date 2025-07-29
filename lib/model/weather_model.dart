import 'package:flutter/cupertino.dart';
import 'package:weatherly/model/previous_day.dart';

class WeatherInfo {
  final String date;
  final String day;
  final String iconUrl;
  final String description;
  final int degree;
  final int min;
  final int max;
  final int humidity;

  WeatherInfo({
    required this.date,
    required this.day,
    required this.iconUrl,
    required this.description,
    required this.degree,
    required this.min,
    required this.max,
    required this.humidity,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      date: json['date'],
      day: json['day'],
      iconUrl: json['icon'],
      description: json['description'],
      degree: double.parse(json['degree'].toString()).toInt(),
      min: double.parse(json['min'].toString()).toInt(),
      max: double.parse(json['max'].toString()).toInt(),
      humidity: int.parse(json['humidity'].toString()),
    );
  }
}
