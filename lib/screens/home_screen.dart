import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadWeather();
  }

  Future<void> loadWeather() async {
    final data = await weatherService.fetchWeather("Dhaka");
    setState(() {
      weatherData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (weatherData == null || weatherData!['cod'] != "200") {
      return const Scaffold(
        body: Center(child: Text("API Error")),
      );
    }

    final current = weatherData!['list'][0];
    final temp = current['main']['temp'];
    final humidity = current['main']['humidity'];
    final wind = current['wind']['speed'];
    final description = current['weather'][0]['description'];
    final icon = current['weather'][0]['icon'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      "https://openweathermap.org/img/wn/$icon@2x.png",
                      width: 70,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${temp.round()}°C",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Weather", style: TextStyle(fontSize: 22)),
                    Text(DateFormat('EEEE hh:mm a').format(DateTime.now())),
                    Text(description),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Text("Humidity: $humidity%"),
            Text("Wind: $wind km/h"),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              tabs: const [
                Tab(text: "Temperature"),
                Tab(text: "Precipitation"),
                Tab(text: "Wind"),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildChart("temp"),
                  buildChart("pop"),
                  buildChart("wind"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart(String type) {
    List<FlSpot> spots = [];

    for (int i = 0; i < 8; i++) {
      final item = weatherData!['list'][i];
      double value = 0;

      if (type == "temp") {
        value = item['main']['temp'].toDouble();
      } else if (type == "pop") {
        value = (item['pop'] * 100).toDouble();
      } else if (type == "wind") {
        value = item['wind']['speed'].toDouble();
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.3),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
