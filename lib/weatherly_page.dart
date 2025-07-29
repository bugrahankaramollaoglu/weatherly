import 'package:weatherly/get/CityController.dart';

import 'get/WeatherController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'get/ThemeController.dart';
import 'model/previous_day.dart';

class WeatherlyPage extends StatefulWidget {
  const WeatherlyPage({super.key});

  @override
  State<WeatherlyPage> createState() => _WeatherlyPageState();
}

class _WeatherlyPageState extends State<WeatherlyPage> {
  final NextDay pDay1 = NextDay(
    nextDay: 'Çar',
    imageUrl:
        'https://cdnydm.com/permedia/LC1i84c3Z2MtLUDNbzWz8A.png?size=512x512',
    celc: 30,
  );

  final WeatherController controller = Get.put(WeatherController());
  final ThemeController themeController = Get.put(ThemeController());
  final CityController cityController = Get.put(CityController());

  @override
  Widget build(BuildContext context) {
    controller.fetchData(cityController.selectedCity.value);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value == true) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white70),
          );
        }

        if (controller.weatherList.isEmpty) {
          return const Center(child: Text('No weather data available'));
        }

        final pDay1 = controller.weatherList[0];

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchData(cityController.selectedCity.value);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cityController.selectedCity.value,
                        style: GoogleFonts.saira(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return CitySelectionWidget();
                            },
                          );
                        },
                        icon: Icon(
                          Icons.location_on,
                          size: 40,
                          color: themeController.isDark.value
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(pDay1.date, style: GoogleFonts.kreon(fontSize: 25)),
                  SizedBox(height: 40),
                  Image.network(pDay1.iconUrl, width: 150, height: 150),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${pDay1.degree}°',
                        style: GoogleFonts.saira(fontSize: 35),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '/ ${pDay1.min}°',
                        style: GoogleFonts.saira(
                          fontSize: 25,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.weatherList
                        .take(5)
                        .map(
                          (nDay) => NextDayWidget(
                            nDay: NextDay(
                              nextDay: nDay.day.substring(0, 3),
                              imageUrl: nDay.iconUrl,
                              celc: nDay.degree.toInt(),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 70),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      themeController.changeTheme();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Text(
                        'Change Theme',
                        style: GoogleFonts.saira(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class CitySelectionWidget extends StatelessWidget {
  final List<String> cities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya',
    'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur',
    'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne',
    'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane',
    'Hakkari', 'Hatay', 'Isparta', 'Mersin', 'Istanbul', 'İzmir', 'Kars', 'Kastamonu',
    'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya',
    'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde',
    'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Şanlıurfa',
    'Şırnak', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Uşak', 'Van', 'Yozgat',
    'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale', 'Batman', 'Şırnak',
    'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce'
  ];

  final CityController cityController = Get.find();
  final WeatherController weatherController = Get.find();

  CitySelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Select a City',
            style: GoogleFonts.saira(
              fontSize: 22,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: cities.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final city = cities[index];
                return ListTile(
                  title: Text(
                    city,
                    style: GoogleFonts.saira(fontSize: 20),
                  ),
                  trailing: cityController.selectedCity.value == city
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    cityController.changeCity(city);
                    weatherController.fetchData(cityController.selectedCity.value);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}