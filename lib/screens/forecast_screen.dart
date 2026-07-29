import 'package:flutter/material.dart';
import 'location_screen.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Forecast Report"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          buildCard("Friday", "17°"),
          buildCard("Saturday", "19°"),
          buildCard("Sunday", "16°"),
          buildCard("Monday", "16°"),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationScreen()),
              );
            },
            child: const Text("Pick Location"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildCard(String day, String temp) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(color: Colors.white)),
          Text(temp, style: const TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}
