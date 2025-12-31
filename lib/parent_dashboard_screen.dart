import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/add_child_screen.dart';
import 'package:myapp/app_management_screen.dart';
import 'package:myapp/screen_time_screen.dart';
import 'package:myapp/user_model.dart';
import 'package:myapp/user_service.dart';
import 'package:myapp/web_filter_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final UserService _userService = UserService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (_uid != null) {
      setState(() {
        _userFuture = _userService.getUser(_uid);
      });
    }
  }

  Future<void> _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddChildScreen()),
    );

    if (result == true) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Children',
              style: textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading children.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.children.isEmpty) {
                    return const Center(child: Text('No children linked yet.'));
                  }

                  final children = snapshot.data!.children;

                  return ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<UserModel?>(
                        future: _userService.getUser(children[index]),
                        builder: (context, childSnapshot) {
                          if (childSnapshot.connectionState == ConnectionState.waiting) {
                            return const Card(child: ListTile(title: Text('Loading child...')));
                          }
                          if (childSnapshot.hasData) {
                            final childUser = childSnapshot.data!;
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          child: Text(childUser.email.substring(0, 1).toUpperCase()),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            childUser.email,
                                            style: textTheme.titleLarge!.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8.0, // gap between adjacent chips
                                      runSpacing: 4.0, // gap between lines
                                      alignment: WrapAlignment.end,
                                      children: <Widget>[
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.apps),
                                          label: const Text('Manage Apps'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AppManagementScreen(childId: childUser.uid),
                                              ),
                                            );
                                          },
                                        ),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.language),
                                          label: const Text('Web Filtering'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => WebFilterScreen(childId: childUser.uid),
                                              ),
                                            );
                                          },
                                        ),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.timer),
                                          label: const Text('Screen Time'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ScreenTimeScreen(childId: childUser.uid),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const Card(child: ListTile(title: Text('Child not found')));
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh,
        tooltip: 'Add a Child',
        child: const Icon(Icons.add),
      ),
    );
  }
}
