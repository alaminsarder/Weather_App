import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Pick Location"),
      ),
      body: ListView(
        children: const [
          buildCity("Montreal, Canada", "8°"),
          buildCity("Tokyo, Japan", "12°"),
          buildCity("Toronto, Canada", "20°"),
          buildCity("Vancouver, Canada", "14°"),
        ],
      ),
    );
  }

  static Widget buildCity(String city, String temp) {
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
          Text(city, style: const TextStyle(color: Colors.white)),
          Text(temp, style: const TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}
