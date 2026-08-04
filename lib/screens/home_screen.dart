import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../main.dart';
import '../services/weather_service.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService weatherService = WeatherService();

  dynamic weatherData;
  bool isLoading = true;
  int selectedIndex = 0;
  DateTime? refreshedAt;

  @override
  void initState() {
    super.initState();
    loadWeather("Bogura,BD");
  }

  Future<void> loadWeather(String city) async {
    setState(() => isLoading = true);
    final data = await weatherService.fetchWeather(city);
    setState(() {
      weatherData = data;
      isLoading = false;
      refreshedAt = DateTime.now();
      selectedIndex = 0;
    });
  }

  Future<void> loadLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    setState(() => isLoading = true);
    Position position = await Geolocator.getCurrentPosition();
    final data = await weatherService.fetchByLocation(
        position.latitude, position.longitude);
    setState(() {
      weatherData = data;
      isLoading = false;
      refreshedAt = DateTime.now();
      selectedIndex = 0;
    });
  }

  IconData _iconFor(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  String _bearing(int deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22) / 45).floor() % 8];
  }

  String _countryName(String code) {
    const map = {
      'BD': 'Bangladesh',
      'IN': 'India',
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'JP': 'Japan',
      'CN': 'China',
      'PK': 'Pakistan',
      'LK': 'Sri Lanka',
      'NP': 'Nepal',
      'MM': 'Myanmar',
      'TH': 'Thailand',
      'MY': 'Malaysia',
      'SG': 'Singapore',
      'ID': 'Indonesia',
      'PH': 'Philippines',
      'VN': 'Vietnam',
      'KR': 'South Korea',
      'AE': 'UAE',
      'SA': 'Saudi Arabia',
      'TR': 'Turkey',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'RU': 'Russia',
      'BR': 'Brazil',
    };
    return map[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
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
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const _InitialLoader();

    if (weatherData == null || weatherData['list'] == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 52,
                color: kTextMuted,
              ),
              const SizedBox(height: 12),
              const Text(
                'Could not load weather data',
                style: TextStyle(fontSize: 14, color: kTextSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => loadWeather("Bogura,BD"),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    color: kAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List list = weatherData['list'];
    if (list.isEmpty) {
      return const Center(
        child: Text("No forecast data", style: TextStyle(color: kTextPrimary)),
      );
    }

    final current = list[selectedIndex];
    final temp = current['main']['temp'];
    final feels = current['main']['feels_like'];
    final humidity = current['main']['humidity'];
    final pressure = current['main']['pressure'];
    final tempMax = current['main']['temp_max'];
    final tempMin = current['main']['temp_min'];
    final desc = current['weather'][0]['description'];
    final main = current['weather'][0]['main'];
    final clouds = current['clouds']['all'];
    final windSpeed = (current['wind']['speed'] as num).toDouble();
    final windDeg = current['wind']['deg'] ?? 0;
    final cityName = weatherData['city']['name'];
    final country = _countryName(weatherData['city']['country']);
    final sunrise = DateTime.fromMillisecondsSinceEpoch(
        (weatherData['city']['sunrise'] as int) * 1000);
    final sunset = DateTime.fromMillisecondsSinceEpoch(
        (weatherData['city']['sunset'] as int) * 1000);

    final totalDays = (list.length / 8).floor();

    final chartData = list
        .take(12)
        .map<double>((e) => (e['main']['temp'] as num).toDouble())
        .toList();
    final chartLabels = list
        .take(12)
        .map<String>((e) =>
            DateFormat('ha').format(DateTime.parse(e['dt_txt'])).toLowerCase())
        .toList();

    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'WeatherNow',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              _iconBtn(
                icon: Icons.search_rounded,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                  if (result != null && result is String) {
                    loadWeather(result);
                  }
                },
              ),
              const SizedBox(width: 6),
              _iconBtn(
                icon: Icons.my_location_rounded,
                onTap: loadLocation,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: kAccent,
            backgroundColor: kBgMid,
            onRefresh: () => loadWeather("$cityName,BD"),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (refreshedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Updated ${DateFormat('h:mm a').format(refreshedAt!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _CurrentCard(
                    temp: temp,
                    feels: feels,
                    tempMax: tempMax,
                    tempMin: tempMin,
                    desc: desc,
                    main: main,
                    cityName: cityName,
                    country: country,
                    humidity: humidity,
                    pressure: pressure,
                    clouds: clouds,
                    windSpeed: windSpeed,
                    windDeg: windDeg,
                    bearing: _bearing(windDeg),
                    icon: _iconFor(main),
                  ),
                  const SizedBox(height: 12),
                  _HourlyStrip(
                    list: list,
                    selectedIndex: selectedIndex,
                    onSelect: (i) => setState(() => selectedIndex = i),
                    iconFor: _iconFor,
                  ),
                  const SizedBox(height: 12),
                  _TemperatureChart(
                    values: chartData,
                    labels: chartLabels,
                  ),
                  const SizedBox(height: 12),
                  _DetailCards(
                    sunrise: sunrise,
                    sunset: sunset,
                    windSpeed: windSpeed,
                    windDeg: windDeg,
                    bearing: _bearing(windDeg),
                    clouds: clouds,
                    humidity: humidity,
                    pressure: pressure,
                  ),
                  const SizedBox(height: 12),
                  _DailyForecast(
                    list: list,
                    totalDays: totalDays,
                    iconFor: _iconFor,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 16, color: kTextSecondary),
      ),
    );
  }
}

// ─────────── Initial Loader ───────────
class _InitialLoader extends StatelessWidget {
  const _InitialLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kAccent.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Loading…',
            style: TextStyle(fontSize: 13, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────── Current Card (NEW COLOR: #2B5675) ───────────
class _CurrentCard extends StatelessWidget {
  final num temp;
  final num feels;
  final num tempMax;
  final num tempMin;
  final String desc;
  final String main;
  final String cityName;
  final String country;
  final num humidity;
  final num pressure;
  final num clouds;
  final double windSpeed;
  final int windDeg;
  final String bearing;
  final IconData icon;

  const _CurrentCard({
    required this.temp,
    required this.feels,
    required this.tempMax,
    required this.tempMin,
    required this.desc,
    required this.main,
    required this.cityName,
    required this.country,
    required this.humidity,
    required this.pressure,
    required this.clouds,
    required this.windSpeed,
    required this.windDeg,
    required this.bearing,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✨ NEW: #2B5675 with 25% opacity
        color: const Color(0xFF2B5675).withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        // ✨ NEW: White border 15% opacity
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        // ✨ NEW: Black shadow 10% opacity
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Opacity(
              opacity: 0.20,
              child: Icon(icon, size: 130, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' · $country',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('h:mm a').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${temp.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desc[0].toUpperCase() + desc.substring(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Feels ${feels.round()}° · H ${tempMax.round()}° L ${tempMin.round()}°',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _mini('Humidity', '$humidity%')),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _mini('Wind', '${windSpeed.round()} m/s',
                          sub: bearing)),
                  const SizedBox(width: 6),
                  Expanded(child: _mini('Pressure', '$pressure', sub: 'hPa')),
                  const SizedBox(width: 6),
                  Expanded(child: _mini('Clouds', '$clouds%')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value, {String? sub}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white70,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          if (sub != null)
            Text(
              sub,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
        ],
      ),
    );
  }
}

// ─────────── Hourly Strip ───────────
class _HourlyStrip extends StatelessWidget {
  final List list;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final IconData Function(String) iconFor;

  const _HourlyStrip({
    required this.list,
    required this.selectedIndex,
    required this.onSelect,
    required this.iconFor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Hourly',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  'Next 24 h',
                  style: TextStyle(fontSize: 10, color: kTextMuted),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              itemCount: list.length > 8 ? 8 : list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final active = index == selectedIndex;
                final dt = DateTime.parse(item['dt_txt']);
                final main = item['weather'][0]['main'] as String;

                return GestureDetector(
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? kAccent.withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: active
                          ? Border.all(color: kAccent.withOpacity(0.5))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          index == 0 ? 'Now' : DateFormat('h a').format(dt),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: active ? kAccent : kTextSecondary,
                          ),
                        ),
                        Icon(
                          iconFor(main),
                          size: 20,
                          color: active ? kAccent : kTextSecondary,
                        ),
                        Text(
                          '${item['main']['temp'].round()}°',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────── Temperature Chart ───────────
class _TemperatureChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _TemperatureChart({
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature Trend',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  '36 hours',
                  style: TextStyle(fontSize: 10, color: kTextMuted),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _ChartPainter(values: values, labels: labels),
                size: const Size(double.infinity, 140),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _ChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double maxV = values.reduce(math.max);
    final double minV = values.reduce(math.min);
    final double range = (maxV - minV).abs() < 0.001 ? 1 : (maxV - minV);

    const double leftPad = 8;
    const double rightPad = 8;
    const double topPad = 20;
    const double bottomPad = 26;

    final double chartW = size.width - leftPad - rightPad;
    final double chartH = size.height - topPad - bottomPad;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = topPad + (chartH / 3) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (chartW / (values.length - 1)) * i;
      final norm = (values[i] - minV) / range;
      final y = topPad + chartH - (norm * chartH);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, topPad + chartH);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final midX = (prev.dx + curr.dx) / 2;
        fillPath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
      }
    }
    fillPath.lineTo(points.last.dx, topPad + chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kAccent.withOpacity(0.45),
          kAccent.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH));

    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = kAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = kAccent;
    final dotBg = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      if (i % 2 == 0) {
        canvas.drawCircle(points[i], 4, dotBg);
        canvas.drawCircle(points[i], 2.5, dotPaint);

        final tp = TextPainter(
          text: TextSpan(
            text: '${values[i].round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(points[i].dx - tp.width / 2, points[i].dy - 18),
        );
      }
    }

    for (int i = 0; i < labels.length; i++) {
      if (i % 2 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(points[i].dx - tp.width / 2, size.height - bottomPad + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.labels != labels;
}

// ─────────── Detail Cards ───────────
class _DetailCards extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final double windSpeed;
  final int windDeg;
  final String bearing;
  final num clouds;
  final num humidity;
  final num pressure;

  const _DetailCards({
    required this.sunrise,
    required this.sunset,
    required this.windSpeed,
    required this.windDeg,
    required this.bearing,
    required this.clouds,
    required this.humidity,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _card(
          label: 'Sunrise & Sunset',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sunrise',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFFD8A8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(sunrise),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Sunset',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFE8A896),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(sunset),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _SunArc(sunrise: sunrise, sunset: sunset),
            ],
          ),
        ),
        _card(
          label: 'Wind',
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: (windDeg + 180) * math.pi / 180,
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 16,
                        color: kAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${windSpeed.round()} m/s',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      bearing,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _card(
          label: 'Pressure',
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pressure',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const Text(
                  'hPa',
                  style: TextStyle(fontSize: 11, color: kTextMuted),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 4,
                    color: Colors.white.withOpacity(0.15),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor:
                          ((pressure - 950) / 100).clamp(0.0, 1.0).toDouble(),
                      child: Container(color: kAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _card(
          label: 'Atmosphere',
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Clouds', '$clouds%'),
                const SizedBox(height: 4),
                _row('Humidity', '$humidity%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: kTextMuted,
              letterSpacing: 0.8,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: kTextSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────── Sun Arc ───────────
class _SunArc extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;

  const _SunArc({required this.sunrise, required this.sunset});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final pct = ((now - sunrise.millisecondsSinceEpoch) /
            (sunset.millisecondsSinceEpoch - sunrise.millisecondsSinceEpoch))
        .clamp(0.0, 1.0);

    return SizedBox(
      height: 22,
      child: CustomPaint(
        painter: _SunArcPainter(pct: pct),
        size: const Size(double.infinity, 22),
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double pct;
  _SunArcPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, -size.height * 0.4, size.width, size.height);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, paint);

    final t = pct;
    final x = size.width * t;
    final y =
        (1 - 4 * (t - 0.5) * (t - 0.5)) * -size.height * 0.4 + size.height;

    canvas.drawCircle(
      Offset(x, y),
      4,
      Paint()..color = kAccent,
    );
    canvas.drawCircle(
      Offset(x, y),
      7,
      Paint()..color = kAccent.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.pct != pct;
}

// ─────────── Daily Forecast ───────────
class _DailyForecast extends StatelessWidget {
  final List list;
  final int totalDays;
  final IconData Function(String) iconFor;

  const _DailyForecast({
    required this.list,
    required this.totalDays,
    required this.iconFor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text(
              'Daily Forecast',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalDays,
            separatorBuilder: (_, __) => Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white.withOpacity(0.08),
            ),
            itemBuilder: (context, i) {
              final dayData = list[i * 8];
              final dt = DateTime.parse(dayData['dt_txt']);
              final dayName = i == 0 ? 'Today' : DateFormat('EEE').format(dt);
              final maxTemp = dayData['main']['temp_max'];
              final minTemp = dayData['main']['temp_min'];
              final desc = dayData['weather'][0]['description'];
              final main = dayData['weather'][0]['main'] as String;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        dayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    Icon(iconFor(main), size: 20, color: kAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        desc[0].toUpperCase() + desc.substring(1),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${maxTemp.round()}° / ${minTemp.round()}°',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
