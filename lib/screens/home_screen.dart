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

  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadWeather("Bogura");
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
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
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

    if (weatherData == null ||
        weatherData!['list'] == null ||
        (weatherData!['list'] as List).isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Weather data not available",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final list = weatherData!['list'] as List;
    final current = list.first;
    final temp = current['main']['temp'];
    final desc = current['weather'][0]['main'];

    final totalDays = (list.length / 8).floor();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1742),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Top Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      weatherData!['city']['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            showSearchDialog(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.my_location,
                              color: Colors.white),
                          onPressed: loadLocation,
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Temperature
              Text("${temp.round()}°",
                  style: const TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.w200,
                      color: Colors.white)),

              Text(desc, style: const TextStyle(color: Colors.white70)),

              Text(
                DateFormat('h:mm a').format(DateTime.now()),
                style: const TextStyle(color: Colors.white60),
              ),

              const SizedBox(height: 30),

              /// Hourly
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final active = index == selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 75,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? Colors.purple : Colors.transparent,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('h a')
                                  .format(DateTime.parse(item['dt_txt'])),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text("${item['main']['temp'].round()}°",
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// 5 Days
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalDays,
                itemBuilder: (context, index) {
                  final dayData = list[index * 8];

                  final dayName = DateFormat('EEEE')
                      .format(DateTime.parse(dayData['dt_txt']));

                  final maxTemp = dayData['main']['temp_max'];
                  final minTemp = dayData['main']['temp_min'];

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dayName,
                            style: const TextStyle(color: Colors.white)),
                        Text("${maxTemp.round()}° / ${minTemp.round()}°",
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void showSearchDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1742),
        title: const Text("Search City", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter city name",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              loadWeather(controller.text.trim());
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }
}
