import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService weatherService = WeatherService();
  final TextEditingController controller = TextEditingController();

  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeather("Bogura"); // ✅ Default Bogura
  }

  Future<void> loadWeather(String city) async {
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

    Position position = await Geolocator.getCurrentPosition();

    final data = await weatherService.fetchByLocation(
        position.latitude, position.longitude);

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

    final current = weatherData!['list'][0];
    final city = weatherData!['city']['name'];
    final temp = current['main']['temp'];
    final desc = current['weather'][0]['description'];
    final max = current['main']['temp_max'];
    final min = current['main']['temp_min'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F9D58), // ✅ Google green
              Color(0xFF004D40),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ Search Bar (White Water Style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: "Search city",
                            border: InputBorder.none,
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
                ),

                const SizedBox(height: 40),

                Text(city,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500)),

                Text("${temp.round()}°",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 90,
                        fontWeight: FontWeight.w200)),

                Text(desc,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 20)),

                Text("↑${max.round()}° ↓${min.round()}°",
                    style: const TextStyle(color: Colors.white60)),

                Text(DateFormat('EEE, HH:mm').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white60)),

                const SizedBox(height: 30),

                /// ✅ Glass Hourly Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      color: Colors.white.withOpacity(0.1),
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            final item = weatherData!['list'][index];
                            final t = item['main']['temp'];
                            final time = DateFormat('HH:mm')
                                .format(DateTime.parse(item['dt_txt']));

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(time,
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  const Icon(Icons.cloud, color: Colors.white),
                                  Text("${t.round()}°",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
