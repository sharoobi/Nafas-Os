import 'package:flutter/material.dart';
import 'package:nafas_os/core/design/app_palette.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          caption,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
        ),
      ],
    );
  }
}
