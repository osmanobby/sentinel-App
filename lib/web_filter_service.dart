import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/web_filter_model.dart';

class WebFilterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'web_filters';

  Future<WebFilterSettings> getWebFilterSettings(String childId) async {
    final doc = await _db.collection(_collection).doc(childId).get();
    if (doc.exists) {
      return WebFilterSettings.fromMap(doc.data()!);
    } else {
      // Return default settings if none are found
      return WebFilterSettings();
    }
  }

  Future<void> updateWebFilterSettings(String childId, WebFilterSettings settings) {
    return _db.collection(_collection).doc(childId).set(settings.toMap());
  }
}
