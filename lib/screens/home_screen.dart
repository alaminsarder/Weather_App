import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService weatherService = WeatherService();
  final TextEditingController controller = TextEditingController();

  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadWeather("Dhaka");
  }

  Future<void> loadWeather(String city) async {
    if (city.isEmpty) return;
    setState(() => isLoading = true);
    final data = await weatherService.fetchWeather(city);
    setState(() {
      weatherData = data;
      isLoading = false;
    });
  }

  Future<void> loadLocation() async {
    setState(() => isLoading = true);

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final data = await weatherService.fetchByLocation(
        position.latitude, position.longitude);

    setState(() {
      weatherData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔍 Search + Location
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Search city",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => loadWeather(controller.text.trim()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: loadLocation,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (weatherData == null ||
                  weatherData!['cod'].toString() != "200")
                const Center(child: Text("City not found"))
              else
                buildWeatherUI(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWeatherUI() {
    final list = weatherData!['list'];
    final city = weatherData!['city']['name'];
    final current = list[0];

    final temp = current['main']['temp'];
    final humidity = current['main']['humidity'];
    final wind = current['wind']['speed'];
    final icon = current['weather'][0]['icon'];
    final desc = current['weather'][0]['description'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.network(
                  "https://openweathermap.org/img/wn/$icon@2x.png",
                  width: 60,
                ),
                const SizedBox(width: 10),
                Text("${temp.round()}°C",
                    style: const TextStyle(
                        fontSize: 42, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(city,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500)),
                Text(DateFormat('EEEE hh:mm a').format(DateTime.now())),
                Text(desc),
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
    );
  }

  Widget buildChart(String type) {
    List<FlSpot> spots = [];
    final list = weatherData!['list'];

    for (int i = 0; i < 8; i++) {
      final item = list[i];
      double value = 0;

      if (type == "temp") {
        value = item['main']['temp'].toDouble();
      } else if (type == "pop") {
        value = (item['pop'] * 100).toDouble();
      } else {
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
