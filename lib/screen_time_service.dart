
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screen_time_model.dart';

class ScreenTimeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'screen_time';

  // Get the document reference for a specific child's daily usage
  DocumentReference getScreenTimeDocument(String childId) {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _db
        .collection(_collection)
        .doc(childId)
        .collection('daily_usage')
        .doc(dateStr);
  }

  // Get a stream of screen time data for a specific child
  Stream<ScreenTimeData> getScreenTimeStream(String childId) {
    return getScreenTimeDocument(childId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return ScreenTimeData.fromFirestore(snapshot);
      } else {
        // Return default data if no record exists for the day
        return ScreenTimeData(
          date: DateTime.now(),
          totalScreenTime: Duration.zero,
          dailyLimit: const Duration(hours: 2), // Default limit
          appUsage: [],
        );
      }
    });
  }

  // Set a new daily screen time limit for a child
  Future<void> setDailyLimit(String childId, Duration limit) async {
    await getScreenTimeDocument(childId)
        .set({'dailyLimit': limit.inMinutes}, SetOptions(merge: true));
  }

  // Update the screen time usage for a specific app
  Future<void> updateAppUsage(
      String childId, String appName, Duration usage, int iconCodePoint) async {
    final docRef = getScreenTimeDocument(childId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final today = DateTime.now();

      if (!snapshot.exists) {
        // Create a new document for the day if it doesn't exist
        final newDay = ScreenTimeData(
          date: today,
          totalScreenTime: usage,
          dailyLimit: const Duration(hours: 2), // Default limit
          appUsage: [
            AppUsage(appName: appName, usage: usage, iconCodePoint: iconCodePoint)
          ],
        );
        transaction.set(docRef, newDay.toFirestore());
      } else {
        final data = ScreenTimeData.fromFirestore(snapshot);

        // Use copyWith to create an updated version of the data
        final updatedData = data.copyWith(
          totalScreenTime: data.totalScreenTime + usage,
          appUsage: _updateAppUsageList(data.appUsage, appName, usage, iconCodePoint),
        );

        transaction.update(docRef, updatedData.toFirestore());
      }
    });
  }

  List<AppUsage> _updateAppUsageList(List<AppUsage> currentUsage,
      String appName, Duration usage, int iconCodePoint) {
    final List<AppUsage> updatedList = List.from(currentUsage);
    final int appIndex = updatedList.indexWhere((app) => app.appName == appName);

    if (appIndex != -1) {
      // If the app is already in the list, update its usage
      final existingApp = updatedList[appIndex];
      updatedList[appIndex] =
          existingApp.copyWith(usage: existingApp.usage + usage);
    } else {
      // If the app is not in the list, add it
      updatedList.add(
          AppUsage(appName: appName, usage: usage, iconCodePoint: iconCodePoint));
    }

    return updatedList;
  }
}
