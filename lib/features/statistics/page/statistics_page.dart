import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';
import '../models/client_count_model.dart';

class StatisticsPage extends StatefulWidget {
  final StatisticsCubit statisticsCubit;

  const StatisticsPage({super.key, required this.statisticsCubit});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    selectedRange = DateTimeRange(start: monthAgo, end: now);
    _loadClientCount();
    _loadPopularServices();
  }

  void _loadClientCount() {
    if (selectedRange != null) {
      widget.statisticsCubit.loadClientCount(
        startDate: selectedRange!.start.toIso8601String().split('T')[0],
        endDate: selectedRange!.end.toIso8601String().split('T')[0],
      );
    }
  }

  void _loadPopularServices() {
    widget.statisticsCubit.loadPopularServices();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      _loadClientCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.statisticsCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedRange == null
                          ? "اختر الفترة"
                          : "من ${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} "
                          "إلى ${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}",
                      style: TextStyle(
                        fontFamily: "Tajawal",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF9B59B6)],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range),
                      label: const Text("تغيير الفترة"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                BlocBuilder<StatisticsCubit, StatisticsState>(
                  builder: (context, state) {
                    if (state is StatisticsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    ClientCountModel? clientCount;
                    Map<String, double> popularServices = {};

                    if (state is ClientCountLoaded) {
                      clientCount = state.clientCount;
                    } else if (state is PopularServicesLoaded) {
                      popularServices = {
                        for (var s in state.popularServices) s.name: s.bookingCount.toDouble()
                      };
                    } else if (state is StatisticsLoaded) {
                      clientCount = state.clientCount;
                      popularServices = {
                        for (var s in state.popularServices) s.name: s.bookingCount.toDouble()
                      };
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Count Card
                        if (clientCount != null)
                          GradientCard(
                            title: "عدد العملاء الجدد",
                            value: "${clientCount.count}",
                            icon: Icons.person_add_alt_1,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF9B59B6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ).animate().fadeIn(duration: 600.ms).slide(begin: const Offset(0, 0.2)),

                        const SizedBox(height: 30),

                        // Donut Chart Title
                        if (popularServices.isNotEmpty)
                    Text(
                    "الخدمات الأكثر طلباً",
                    style: TextStyle(
                    fontFamily: "Tajawal",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()..shader = LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF9B59B6)],
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    shadows: [
                    Shadow(color: Colors.black.withOpacity(0.2), offset: Offset(2, 2), blurRadius: 4),
                    ],
                    ),
                    ).animate().fadeIn(duration: 700.ms).slide(begin: Offset(0, 0.1)),

                        const SizedBox(height: 12),

                        if (popularServices.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Animate(
                                  effects: [
                                    FadeEffect(duration: 700.ms),
                                    ScaleEffect(duration: 700.ms)
                                  ],
                                  child: SizedBox(
                                    height: 220,
                                    child: DonutChartWithPercentage(popularServices: popularServices),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              Expanded(
                                flex: 1,
                                child: LegendBox(popularServices: popularServices),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradientCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const GradientCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: 300.ms,
        transform: Matrix4.identity()..scale(_hovered ? 1.05 : 1.0),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(4, 4), blurRadius: 10),
            BoxShadow(color: Colors.white.withOpacity(0.4), offset: const Offset(-4, -4), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 32, color: Colors.white),
            const SizedBox(height: 12),
            Text(widget.title, style: const TextStyle(fontFamily: "Tajawal", fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 6),
            Text(widget.value, style: const TextStyle(fontFamily: "Tajawal", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class DonutChartWithPercentage extends StatefulWidget {
  final Map<String, double> popularServices;
  static const colors = [
    Color(0xFF6A11CB),
    Color(0xFF8E44AD),
    Color(0xFF9B59B6),
    Color(0xFFBB8FCE),
    Color(0xFFD7BDE2),
    Color(0xFFE8DAEF),
  ];

  const DonutChartWithPercentage({super.key, required this.popularServices});

  @override
  State<DonutChartWithPercentage> createState() => _DonutChartWithPercentageState();
}

class _DonutChartWithPercentageState extends State<DonutChartWithPercentage> {
  int? _tappedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.popularServices.isEmpty) return const SizedBox(height: 200);

    final sortedServices = widget.popularServices.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topService = sortedServices.first.key;
    final total = widget.popularServices.values.reduce((a, b) => a + b);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 60,
            sectionsSpace: 2,
            sections: widget.popularServices.entries.map((entry) {
              final idx = widget.popularServices.keys.toList().indexOf(entry.key);
              final percent = (entry.value / total * 100).toStringAsFixed(0);
              final isTapped = _tappedIndex == idx;
              return PieChartSectionData(
                value: entry.value,
                color: DonutChartWithPercentage.colors[idx % DonutChartWithPercentage.colors.length],
                radius: isTapped ? 90 : 80,
                title: "$percent%",
                titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              );
            }).toList(),
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (response != null && response.touchedSection != null) {
                  setState(() => _tappedIndex = response.touchedSection!.touchedSectionIndex);
                } else {
                  setState(() => _tappedIndex = null);
                }
              },
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "الأكثر طلبًا",
              style: TextStyle(fontFamily: "Tajawal", fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              topService,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: "Tajawal", fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 700.ms).scaleXY(begin: 0.8, end: 1.0, alignment: Alignment.center);
  }
}

String formatDateRange(DateTimeRange? range) {
  if (range == null) return "اختر الفترة";
  return "من ${range.start.day}/${range.start.month}/${range.start.year}\nإلى ${range.end.day}/${range.end.month}/${range.end.year}";
}

class LegendBox extends StatefulWidget {
  final Map<String, double> popularServices;
  const LegendBox({super.key, required this.popularServices});

  @override
  State<LegendBox> createState() => _LegendBoxState();
}

class _LegendBoxState extends State<LegendBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final sortedServices = widget.popularServices.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topService = sortedServices.first.key;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: 400.ms,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered ? Colors.purple[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "تفاصيل الخدمات",
              style: TextStyle(fontFamily: "Tajawal", fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sortedServices.map((entry) {
              final idx = widget.popularServices.keys.toList().indexOf(entry.key);
              final color = DonutChartWithPercentage.colors[idx % DonutChartWithPercentage.colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(width: 18, height: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("${entry.key} (${entry.value.toInt()})",
                          style: TextStyle(
                              fontFamily: "Tajawal",
                              fontSize: 14,
                              fontWeight: _hovered ? FontWeight.bold : FontWeight.normal)),
                    ),
                    if (entry.key == topService) const Icon(Icons.star, color: Colors.amber, size: 18),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
