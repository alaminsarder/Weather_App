import 'package:flutter/material.dart';
import '../main.dart';

class HourlyChip extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  final bool isActive;

  const HourlyChip({
    super.key,
    required this.time,
    required this.temp,
    this.icon = Icons.wb_cloudy_rounded,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? kAccent.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? kAccent : const Color(0xFF6B7280),
            ),
          ),
          Icon(
            icon,
            size: 20,
            color: isActive ? kAccent : const Color(0xFF6B7280),
          ),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
