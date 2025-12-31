import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) {
    final userToCreate = UserModel(
      uid: user.uid,
      email: user.email,
      role: user.role,
      childCode: user.role == 'child' ? UserModel.generateChildCode() : null,
    );
    return _db.collection('users').doc(user.uid).set(userToCreate.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<bool> linkChild({required String parentUid, required String childCode}) async {
    final query = await _db.collection('users').where('childCode', isEqualTo: childCode).get();

    if (query.docs.isNotEmpty) {
      final childDoc = query.docs.first;
      await _db.collection('users').doc(parentUid).update({
        'children': FieldValue.arrayUnion([childDoc.id]),
      });
      // Optional: Remove childCode after linking
      await childDoc.reference.update({'childCode': null});
      return true;
    }
    return false;
  }
}
