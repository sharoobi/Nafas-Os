import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'الخط الزمني',
      subtitle:
          'كل رغبة وكل إنقاذ وكل تعثر يجب أن يتحول إلى معرفة قابلة للاستخدام.',
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            FrostedCard(child: Text('تعذر تحميل الخط الزمني.\n$error')),
        data: (NafasDashboardState state) {
          if (state.timeline.isEmpty) {
            return const FrostedCard(
              child: Text(
                'لا توجد أحداث بعد. سجّل رغبة أو تدخينًا أو عرضًا صحيًا ليبدأ الخط الزمني بالتشكل.',
              ),
            );
          }

          return Column(
            children: state.timeline
                .map(
                  (TimelineCardData item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TimelineEvent(
                      time: item.timeLabel,
                      title: item.title,
                      description: item.description,
                      tint: _tintFromName(item.tintName),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Color _tintFromName(String value) {
    switch (value) {
      case 'emerald':
        return AppPalette.emerald;
      case 'amber':
        return AppPalette.amber;
      case 'danger':
        return AppPalette.danger;
      case 'secondary':
        return AppPalette.secondary;
      default:
        return AppPalette.primary;
    }
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.time,
    required this.title,
    required this.description,
    required this.tint,
  });

  final String time;
  final String title;
  final String description;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              ),
              Container(width: 2, height: 72, color: AppPalette.stroke),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  time,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppPalette.textMuted),
                ),
                const SizedBox(height: 6),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
