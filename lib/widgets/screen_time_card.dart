import 'package:flutter/material.dart';
import 'package:myapp/screen_time_model.dart';
import 'package:myapp/screen_time_service.dart';
import 'package:myapp/widgets/glass_morphic_card.dart';

class ScreenTimeCard extends StatelessWidget {
  final String childId;
  final ScreenTimeService screenTimeService;

  const ScreenTimeCard(
      {super.key, required this.childId, required this.screenTimeService});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassMorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<ScreenTimeData>(
          stream: screenTimeService.getScreenTimeStream(childId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading screen time.'));
            }

            final data = snapshot.data!;
            final usage = data.dailyLimit.inMinutes > 0
                ? data.totalScreenTime.inMinutes / data.dailyLimit.inMinutes
                : 0.0;
            final usageText = '${data.totalScreenTime.inHours}h ${data.totalScreenTime.inMinutes.remainder(60)}m / ${data.dailyLimit.inHours}h ${data.dailyLimit.inMinutes.remainder(60)}m';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screen Time Usage',
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: usage,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      usageText,
                      style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
