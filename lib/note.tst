  Future getCurrentWeather() async {
    try {
      String cityName = "London";
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherApiKey'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "An unexpected error occured";
      }
      setState(() {
        temp = data['list'][0]['main']['temp'];
      });
    } catch (e) {
      throw e.toString();
    }
  }

  double temp = 0;
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  temp == 0
          ? const Center(child: CircularProgressIndicator())
          :


           // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       for (int i = 0; i < 5; i++)
                  //         HourlyForcastItem(
                  //           time: data['list'][i + 1]['dt'].toString(),
                  //           temperature:
                  //               data['list'][i + 1]['main']['temp'].toString(),
                  //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                  //                       'Clouds' ||
                  //                   data['list'][i + 1]['weather'][0]['main'] ==
                  //                       'Rain'
                  //               ? Icons.cloud
                  //               : Icons.sunny,
                  //         ),
                  //     ],
                  //   ),
                  // ),