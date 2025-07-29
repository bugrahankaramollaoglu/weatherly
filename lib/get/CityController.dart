import 'package:get/get.dart';

class CityController extends GetxController {
  var selectedCity = 'samsun'.obs;

  void changeCity(String newCity) {
    selectedCity.value = newCity;
  }
}