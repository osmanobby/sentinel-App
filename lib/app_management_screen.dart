import 'package:flutter/material.dart';
import 'package:myapp/app_blocking_service.dart';
import 'package:myapp/app_model.dart';

class AppManagementScreen extends StatelessWidget {
  final String childId;
  final AppBlockingService _appBlockingService = AppBlockingService();

  AppManagementScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Apps')),
      body: StreamBuilder<List<AppInfo>>(
        stream: _appBlockingService.getApps(childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No apps found.'));
          }

          final apps = snapshot.data!;

          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return ListTile(
                leading: Icon(app.icon, size: 40),
                title: Text(app.name, style: Theme.of(context).textTheme.titleLarge),
                trailing: Switch(
                  value: app.isBlocked,
                  onChanged: (isBlocked) {
                    _appBlockingService.toggleAppBlock(
                      childId: childId,
                      appName: app.name,
                      isBlocked: isBlocked,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
