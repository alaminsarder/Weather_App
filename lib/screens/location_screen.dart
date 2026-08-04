import 'package:flutter/material.dart';
import '../main.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cities = const [
      {'name': 'Montreal, Canada', 'temp': '8°'},
      {'name': 'Tokyo, Japan', 'temp': '12°'},
      {'name': 'Toronto, Canada', 'temp': '20°'},
      {'name': 'Vancouver, Canada', 'temp': '14°'},
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBgTop, kBgMid, kBgBottom],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.08),
          elevation: 0,
          iconTheme: const IconThemeData(color: kTextPrimary),
          title: const Text(
            "Pick Location",
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cities.length,
          itemBuilder: (context, i) {
            final c = cities[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => Navigator.pop(context, c['name']!.split(',')[0]),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kAccent.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: kAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            c['name']!,
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        c['temp']!,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
