import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

// ─── Premium Warm Theme Colors ───
const Color kAccent = Color(0xFFE8B678);
const Color kBgTop = Color(0xFF7E6274);
const Color kBgMid = Color(0xFF7C4C5C);
const Color kBgBottom = Color(0xFFA44D33);
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xCCFFFFFF);
const Color kTextMuted = Color(0x99FFFFFF);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBgTop,
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
