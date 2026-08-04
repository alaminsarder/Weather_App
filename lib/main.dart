import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

// ─── Premium Warm Theme Colors ───
const Color kAccent = Color(0xFFE8B678); // Warm gold
const Color kBgTop = Color(0xFF7E6274); // Muted mauve
const Color kBgMid = Color(0xFF7C4C5C); // Deep rose
const Color kBgBottom = Color(0xFFA44D33); // Burnt orange
const Color kCard = Color(0x33000000); // Translucent dark
const Color kCardSolid = Color(0xFF3D2E38); // Solid card fallback
const Color kBorder = Color(0x33FFFFFF); // Soft white border
const Color kTextPrimary = Color(0xFFFFFFFF); // Pure white
const Color kTextSecondary = Color(0xCCFFFFFF); // 80% white
const Color kTextMuted = Color(0x99FFFFFF); // 60% white

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
