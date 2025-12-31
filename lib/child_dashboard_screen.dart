import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app_blocking_service.dart';
import 'package:myapp/app_usage_tracker_service.dart';
import 'package:myapp/screen_time_service.dart';
import 'package:myapp/user_model.dart';
import 'package:myapp/user_service.dart';
import 'package:myapp/web_filter_service.dart';
import 'package:myapp/widgets/blocked_apps_card.dart';
import 'package:myapp/widgets/child_code_card.dart';
import 'package:myapp/widgets/screen_time_card.dart';
import 'package:myapp/widgets/web_filter_card.dart';

class ChildDashboardScreen extends StatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  final UserService _userService = UserService();
  final AppBlockingService _appBlockingService = AppBlockingService();
  final WebFilterService _webFilterService = WebFilterService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  late final AppUsageTrackerService _appUsageTrackerService;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _appUsageTrackerService = AppUsageTrackerService(screenTimeService: _screenTimeService);
    if (_uid != null) {
      _userFuture = _userService.getUser(_uid);
      _appUsageTrackerService.startTracking(_uid);
    }
  }

  @override
  void dispose() {
    _appUsageTrackerService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<UserModel?>(
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
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text('Welcome, ${user.email}'),
                      centerTitle: false,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (user.childCode != null)
                          ChildCodeCard(childCode: user.childCode!),
                        const SizedBox(height: 24),
                        ScreenTimeCard(
                          childId: user.uid,
                          screenTimeService: _screenTimeService,
                        ),
                        const SizedBox(height: 16),
                        BlockedAppsCard(
                          childId: user.uid,
                          appBlockingService: _appBlockingService,
                        ),
                        const SizedBox(height: 16),
                        WebFilterCard(
                          childId: user.uid,
                          webFilterService: _webFilterService,
                        ),
                      ]),
                    ),
                  )
                ],
              );
            } else {
              return const Center(child: Text('User not found'));
            }
          },
        ),
      ),
    );
  }
}
   