import 'package:cloud_firestore/cloud_firestore.dart';

class AppUsage {
  final String appName;
  final Duration usage;
  final int iconCodePoint;

  const AppUsage({required this.appName, required this.usage, required this.iconCodePoint});

  AppUsage copyWith({
    String? appName,
    Duration? usage,
    int? iconCodePoint,
  }) {
    return AppUsage(
      appName: appName ?? this.appName,
      usage: usage ?? this.usage,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      appName: map['appName'],
      usage: Duration(minutes: map['usage']),
      iconCodePoint: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'usage': usage.inMinutes,
      'icon': iconCodePoint,
    };
  }
}

class ScreenTimeData {
  final DateTime date;
  final Duration totalScreenTime;
  final Duration dailyLimit;
  final List<AppUsage> appUsage;

  ScreenTimeData({
    required this.date,
    required this.totalScreenTime,
    required this.dailyLimit,
    required this.appUsage,
  });

  ScreenTimeData copyWith({
    DateTime? date,
    Duration? totalScreenTime,
    Duration? dailyLimit,
    List<AppUsage>? appUsage,
  }) {
    return ScreenTimeData(
      date: date ?? this.date,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      appUsage: appUsage ?? this.appUsage,
    );
  }

  factory ScreenTimeData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ScreenTimeData(
      date: (data['date'] as Timestamp).toDate(),
      totalScreenTime: Duration(minutes: data['totalScreenTime']),
      dailyLimit: Duration(minutes: data['dailyLimit']),
      appUsage: (data['appUsage'] as List)
          .map((usage) => AppUsage.fromMap(usage))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'totalScreenTime': totalScreenTime.inMinutes,
      'dailyLimit': dailyLimit.inMinutes,
      'appUsage': appUsage.map((usage) => usage.toMap()).toList(),
    };
  }
}
