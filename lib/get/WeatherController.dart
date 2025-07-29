import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:weatherly/get/CityController.dart';

import '../model/weather_model.dart';

class WeatherController extends GetxController
{
  var weatherList = <WeatherInfo>[].obs;
  var isLoading = false.obs;
  CityController cityController = Get.put(CityController());
  String get cityChosen => cityController.selectedCity.value;

  Future<void> fetchData(String city) async {
    isLoading.value = true;

    final String apiCall =
        'https://api.collectapi.com/weather/getWeather?data.city=$city';
    const String apiKey = '7vKjwRWY743SxEXH2pg9g2:5xQeRee2G7KQhuO9bIZHU8';

    final response = await http.get(
      Uri.parse(apiCall),
      headers: {
        'content-type': 'application/json',
        'authorization': 'apikey $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> result = data['result'];
      weatherList.assignAll(result.map((item) => WeatherInfo.fromJson(item)).toList());
    }
    isLoading.value = false;
  }
}