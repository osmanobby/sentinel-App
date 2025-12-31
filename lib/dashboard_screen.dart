import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/child_dashboard_screen.dart';
import 'package:myapp/parent_dashboard_screen.dart';
import 'package:myapp/user_model.dart';
import 'package:myapp/user_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _userFuture = _userService.getUser(_uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('Not logged in'));
    }

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          if (user.role == 'parent') {
            return const ParentDashboardScreen();
          } else if (user.role == 'child') {
            return const ChildDashboardScreen();
          } else {
            return const Center(child: Text('Unknown role'));
          }
        } else {
          return const Center(child: Text('User not found'));
        }
      },
    );
  }
}
