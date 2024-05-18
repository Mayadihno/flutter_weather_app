import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_item.dart';
import 'dart:ui';
import 'package:weather_app/hourly_weather_forcast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "London";
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherApiKey'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "An unexpected error occured";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(
              Icons.refresh,
              size: 25,
            ),
          )
        ],
      ),
      body: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(fontSize: 25),
                ),
              );
            }

            final data = snapshot.data!;
            final currentTemp = data['list'][0]['main']['temp'];
            final currentSky = data['list'][0]['weather'][0]['main'];
            final pressure = data['list'][0]['main']['pressure'];
            final humidity = data['list'][0]['main']['humidity'];
            final speed = data['list'][0]['wind']['speed'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currentTemp ° K',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == "Rain"
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 80,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "$currentSky",
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Weather forecast height
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Weather Forcast",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final time = DateTime.parse(
                            data['list'][index + 1]['dt_txt'].toString());
                        return HourlyForcastItem(
                            time: DateFormat.j().format(time),
                            temperature: data['list'][index + 1]['main']['temp']
                                .toString(),
                            icon: data['list'][index + 1]['weather'][0]
                                            ['main'] ==
                                        'Clouds' ||
                                    data['list'][index + 1]['weather'][0]
                                            ['main'] ==
                                        'Rain'
                                ? Icons.cloud
                                : Icons.sunny);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AdditionalIitem(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          value: humidity.toString(),
                        ),
                        AdditionalIitem(
                          icon: Icons.air,
                          label: "Wind Speed",
                          value: speed.toString(),
                        ),
                        AdditionalIitem(
                          icon: Icons.beach_access,
                          label: "Pressure",
                          value: pressure.toString(),
                        ),
                      ],
                    ),
                  )
                  // Additional information
                ],
              ),
            );
          }),
    );
  }
}
