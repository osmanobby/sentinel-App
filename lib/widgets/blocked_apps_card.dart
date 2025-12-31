import 'package:flutter/material.dart';
import 'package:myapp/app_blocking_service.dart';
import 'package:myapp/app_model.dart';
import 'package:myapp/widgets/glass_morphic_card.dart';

class BlockedAppsCard extends StatelessWidget {
  final String childId;
  final AppBlockingService appBlockingService;

  const BlockedAppsCard(
      {super.key, required this.childId, required this.appBlockingService});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassMorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blocked Apps',
              style: textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<AppInfo>>(
              stream: appBlockingService.getApps(childId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading apps.'));
                }
                final blockedApps =
                    snapshot.data?.where((app) => app.isBlocked).toList() ?? [];

                if (blockedApps.isEmpty) {
                  return Center(
                      child: Text('No apps are currently blocked.',
                          style: TextStyle(color: colorScheme.onSurface)));
                }

                return SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: blockedApps.length,
                    itemBuilder: (context, index) {
                      return Chip(
                        avatar: Icon(blockedApps[index].icon,
                            color: colorScheme.onSurface),
                        label: Text(blockedApps[index].name,
                            style: TextStyle(color: colorScheme.onSurface)),
                        backgroundColor: colorScheme.surface.withOpacity(0.5),
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: colorScheme.onSurface.withOpacity(0.2))),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
