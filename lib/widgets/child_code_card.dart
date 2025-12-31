import 'package:flutter/material.dart';
import 'package:myapp/widgets/glass_morphic_card.dart';

class ChildCodeCard extends StatelessWidget {
  final String childCode;

  const ChildCodeCard({super.key, required this.childCode});

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
              'Your Linking Code',
              style: textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Give this code to your parent to link your accounts:',
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                childCode,
                style: textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
