import 'package:flutter/material.dart';
import 'package:myapp/web_filter_model.dart';
import 'package:myapp/web_filter_service.dart';
import 'package:myapp/widgets/glass_morphic_card.dart';

class WebFilterCard extends StatelessWidget {
  final String childId;
  final WebFilterService webFilterService;

  const WebFilterCard(
      {super.key, required this.childId, required this.webFilterService});

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
              'Web Filter Status',
              style: textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<WebFilterSettings>(
              future: webFilterService.getWebFilterSettings(childId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading settings.'));
                }
                final settings = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Adult Content Blocked',
                            style: TextStyle(color: colorScheme.onSurface)),
                        Icon(
                            settings.blockAdultContent
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: settings.blockAdultContent
                                ? Colors.green
                                : Colors.red),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Social Media Blocked',
                            style: TextStyle(color: colorScheme.onSurface)),
                        Icon(
                            settings.blockSocialMedia
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: settings.blockSocialMedia
                                ? Colors.green
                                : Colors.red),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
