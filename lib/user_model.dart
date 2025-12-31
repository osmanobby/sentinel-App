import 'dart:math';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'parent' or 'child'
  final String? childCode;
  final List<String> children;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.childCode,
    this.children = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      role: data['role'],
      childCode: data['childCode'],
      children: List<String>.from(data['children'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'childCode': childCode,
      'children': children,
    };
  }

  static String generateChildCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
