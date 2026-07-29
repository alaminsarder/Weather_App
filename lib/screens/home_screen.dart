import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
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

  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  late AnimationController controller;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadWeather("Bogura");

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
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

  List<Color> getGradient(String weather) {
    weather = weather.toLowerCase();

    if (weather.contains("rain")) {
      return [const Color(0xFF1B1742), const Color(0xFF2C1F6E)];
    }
    if (weather.contains("snow")) {
      return [Colors.blueGrey.shade700, Colors.blueGrey.shade300];
    }
    if (weather.contains("clear")) {
      return [Colors.orange.shade400, Colors.deepOrange];
    }
    if (weather.contains("storm")) {
      return [Colors.black, Colors.deepPurple.shade900];
    }
    return [const Color(0xFF1B1742), const Color(0xFF4B1D74)];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || weatherData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final current = weatherData!['list'][0];
    final temp = current['main']['temp'];
    final desc = current['weather'][0]['main'];
    final list = weatherData!['list'];

    return Scaffold(
      backgroundColor: const Color(0xFF1B1742),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: getGradient(desc),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            /// ✅ Rain
            if (desc.toLowerCase().contains("rain"))
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: RainPainter(controller.value),
                    );
                  },
                ),
              ),

            /// ✅ Snow
            if (desc.toLowerCase().contains("snow"))
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: SnowPainter(controller.value),
                    );
                  },
                ),
              ),

            /// ✅ Lightning
            if (desc.toLowerCase().contains("storm"))
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return Opacity(
                      opacity: sin(controller.value * pi * 8) > 0.95 ? 0.8 : 0,
                      child: Container(color: Colors.white),
                    );
                  },
                ),
              ),

            SafeArea(
              child: Column(
                children: [
                  /// ✅ Top Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          weatherData!['city']['name'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.search, color: Colors.white),
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

                  /// ✅ Temperature
                  Text("${temp.round()}°",
                      style: const TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w200,
                          color: Colors.white)),

                  Text(desc, style: const TextStyle(color: Colors.white70)),

                  Text(
                    DateFormat('h:mm a').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white60),
                  ),

                  const SizedBox(height: 40),

                  /// ✅ Hourly
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
                              gradient: active
                                  ? const LinearGradient(colors: [
                                      Color(0xFF7C3AED),
                                      Color(0xFF9333EA)
                                    ])
                                  : null,
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
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSearchDialog(BuildContext context) {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1742),
        title: const Text("Search City", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter city name",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              loadWeather(textController.text.trim());
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }
}

class RainPainter extends CustomPainter {
  final double value;
  RainPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24;

    for (int i = 0; i < 60; i++) {
      final x = Random().nextDouble() * size.width;
      final y =
          (Random().nextDouble() * size.height + value * 500) % size.height;

      canvas.drawLine(Offset(x, y), Offset(x, y + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowPainter extends CustomPainter {
  final double value;
  SnowPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white70;

    for (int i = 0; i < 40; i++) {
      final x = Random().nextDouble() * size.width;
      final y =
          (Random().nextDouble() * size.height + value * 200) % size.height;

      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
