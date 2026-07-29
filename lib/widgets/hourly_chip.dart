import 'package:flutter/material.dart';

class HourlyChip extends StatelessWidget {
  final String time;
  final String temp;
  final bool isActive;

  const HourlyChip({
    super.key,
    required this.time,
    required this.temp,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              )
            : null,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 5),
          const Icon(Icons.cloud, color: Colors.white),
          Text(temp, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
