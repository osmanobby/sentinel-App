import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screen_time_model.dart';
import 'package:myapp/screen_time_service.dart';

class ScreenTimeScreen extends StatefulWidget {
  final String childId;

  const ScreenTimeScreen({super.key, required this.childId});

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: StreamBuilder<ScreenTimeData>(
        stream: _screenTimeService.getScreenTimeStream(widget.childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final screenTimeData = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildHeader(context, screenTimeData),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _buildLimitSetter(context, screenTimeData.dailyLimit),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 16, 8),
                  child: Text(
                    'App Usage Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              _buildAppUsageSliverList(context, screenTimeData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ScreenTimeData data) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final used = data.totalScreenTime.inMinutes;
    final limit = data.dailyLimit.inMinutes;
    final usedPercentage = limit > 0 ? (used / limit * 100) : 0;

    return SliverAppBar(
      expandedHeight: 350.0,
      pinned: true,
      backgroundColor: colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Screen Time',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                Color.lerp(colorScheme.primary, colorScheme.secondary, 0.5)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_touchedIndex != -1)
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 15,
                            )
                        ],
                      ),
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                _touchedIndex = pieTouchResponse
                                        ?.touchedSection?.touchedSectionIndex ??
                                    -1;
                              });
                            },
                          ),
                          sections: [
                            PieChartSectionData(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                              value: used.toDouble(),
                              title: '',
                              radius: _touchedIndex == 0 ? 40 : 35,
                            ),
                            PieChartSectionData(
                              color: colorScheme.onPrimary.withOpacity(0.3),
                              value: (limit - used).clamp(0, limit).toDouble(),
                              title: '',
                              radius: _touchedIndex == 1 ? 40 : 35,
                            ),
                          ],
                          sectionsSpace: 3,
                          centerSpaceRadius: 80,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${usedPercentage.toStringAsFixed(0)}%',
                          style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Used',
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.8)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAppUsageSliverList(BuildContext context, ScreenTimeData data) {
    if (data.appUsage.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No app usage data available.')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final app = data.appUsage[index];
          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;
          final percentage = data.totalScreenTime.inMinutes > 0
              ? (app.usage.inMinutes / data.totalScreenTime.inMinutes)
              : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: _buildGlassMorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      IconData(app.iconCodePoint, fontFamily: 'MaterialIcons'),
                      size: 32,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.appName,
                              style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.secondary),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('${app.usage.inMinutes} min',
                        style:
                            textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: data.appUsage.length,
      ),
    );
  }

  Widget _buildLimitSetter(BuildContext context, Duration currentLimit) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return _buildGlassMorphicCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            Text('Daily Limit',
                style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.surface.withOpacity(0.8),
                      foregroundColor: colorScheme.onSurface,
                    ),
                    onPressed: () =>
                        _updateLimit(currentLimit - const Duration(minutes: 15)),
                    icon: const Icon(Icons.remove),
                    label: const Text('15m')),
                Text(
                  '${currentLimit.inHours}h ${currentLimit.inMinutes.remainder(60)}m',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.surface.withOpacity(0.8),
                      foregroundColor: colorScheme.onSurface,
                    ),
                    onPressed: () =>
                        _updateLimit(currentLimit + const Duration(minutes: 15)),
                    icon: const Icon(Icons.add),
                    label: const Text('15m')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateLimit(Duration newLimit) {
    if (newLimit >= Duration.zero) {
      _screenTimeService.setDailyLimit(widget.childId, newLimit);
    }
  }
}
