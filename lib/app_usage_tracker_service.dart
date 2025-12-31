import 'dart:async';
import 'dart:math';

import 'package:myapp/screen_time_model.dart';
import 'package:myapp/screen_time_service.dart';

class AppUsageTrackerService {
  final ScreenTimeService _screenTimeService;
  Timer? _timer;

  AppUsageTrackerService({required ScreenTimeService screenTimeService})
      : _screenTimeService = screenTimeService;

  static const List<AppUsage> _sampleApps = [
    AppUsage(appName: 'YouTube', usage: Duration.zero, iconCodePoint: 0xe037),
    AppUsage(appName: 'TikTok', usage: Duration.zero, iconCodePoint: 0xe60d),
    AppUsage(appName: 'Chrome', usage: Duration.zero, iconCodePoint: 0xe17a),
    AppUsage(appName: 'Messages', usage: Duration.zero, iconCodePoint: 0xe3e0),
    AppUsage(appName: 'Game Zone', usage: Duration.zero, iconCodePoint: 0xe338),
  ];

  void startTracking(String childId) {
    stopTracking();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateUsage(childId);
    });
  }

  void stopTracking() {
    _timer?.cancel();
  }

  Future<void> _updateUsage(String childId) async {
    try {
      final randomApp = _sampleApps[Random().nextInt(_sampleApps.length)];
      await _screenTimeService.updateAppUsage(
        childId,
        randomApp.appName,
        const Duration(minutes: 1),
        randomApp.iconCodePoint,
      );
    } catch (e) {
      print('Error updating app usage: $e');
    }
  }
}
