import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app_model.dart';

class AppBlockingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // A mock list of apps for demonstration purposes
  final List<AppInfo> _mockApps = [
    AppInfo(name: 'TikTok', icon: Icons.music_note),
    AppInfo(name: 'Instagram', icon: Icons.camera_alt),
    AppInfo(name: 'Snapchat', icon: Icons.camera),
    AppInfo(name: 'YouTube', icon: Icons.play_arrow),
    AppInfo(name: 'Twitter', icon: Icons.chat),
    AppInfo(name: 'Facebook', icon: Icons.facebook),
  ];

  Stream<List<AppInfo>> getApps(String childId) {
    return _db.collection('users').doc(childId).collection('blocked_apps').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // If no apps are in Firestore, initialize with the mock list
        for (var app in _mockApps) {
          _db.collection('users').doc(childId).collection('blocked_apps').doc(app.name).set(app.toMap());
        }
        return _mockApps;
      }

      final apps = snapshot.docs.map((doc) => AppInfo.fromMap(doc.data())).toList();
      // Add any new mock apps that are not in Firestore yet
      for (var mockApp in _mockApps) {
        if (!apps.any((app) => app.name == mockApp.name)) {
           _db.collection('users').doc(childId).collection('blocked_apps').doc(mockApp.name).set(mockApp.toMap());
          apps.add(mockApp);
        }
      }
      return apps;
    });
  }

  Future<void> toggleAppBlock({required String childId, required String appName, required bool isBlocked}) {
    return _db.collection('users').doc(childId).collection('blocked_apps').doc(appName).update({'isBlocked': isBlocked});
  }
}
