import 'package:flutter/material.dart';

class AppInfo {
  final String name;
  final IconData icon;
  bool isBlocked;

  AppInfo({required this.name, required this.icon, this.isBlocked = false});

  // fromMap and toMap for firestore
  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      isBlocked: map['isBlocked'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon.codePoint,
      'isBlocked': isBlocked,
    };
  }
}
