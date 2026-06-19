import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/metric_chip.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/core/widgets/section_heading.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/insights_digest.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'التحليلات',
      subtitle:
          'لوحة دورية تشرح ما يحدث، ما الذي يتكرر، وما التجربة التالية التي تستحق التنفيذ.',
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => FrostedCard(
          child: Text('تعذر بناء لوحة التحليلات.\n$error'),
        ),
        data: (NafasDashboardState state) {
          final InsightsDigest digest = state.insightsDigest;
          final List<InsightWindowSummary> windows = <InsightWindowSummary>[
            digest.today,
            digest.week,
            digest.month,
          ];
          final InsightWindowSummary selected = windows[_index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List<Widget>.generate(windows.length, (int index) {
                  return ChoiceChip(
                    label: Text(windows[index].label),
                    selected: _index == index,
                    onSelected: (_) => setState(() => _index = index),
                  );
                }),
              ),
              const SizedBox(height: 18),
              FrostedCard(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    MetricChip(
                      label: 'السجائر',
                      value: '${selected.smokeCount}',
                      tint: AppPalette.amber,
                    ),
                    MetricChip(
                      label: 'الموجات',
                      value: '${selected.cravingCount}',
                      tint: AppPalette.primary,
                    ),
                    MetricChip(
                      label: 'النجاة',
                      value: '${selected.resistedCount}',
                      tint: AppPalette.emerald,
                    ),
                    MetricChip(
                      label: 'نجاح التدخل',
                      value: '${(selected.rescueWinRate * 100).round()}%',
                      tint: AppPalette.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'ما الذي يفعله القرين الآن؟',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.companionBrief.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        MetricChip(
                          label: 'التدخل الأنسب',
                          value: _interventionLabel(
                            state.riskAssessment.recommendedIntervention,
                          ),
                          tint: AppPalette.primary,
                        ),
                        MetricChip(
                          label: 'التركيز الحالي',
                          value: state.companionBrief.focusLabel,
                          tint: AppPalette.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeading(
                title: 'قراءة الفترة',
                caption:
                    'بدل رسم واحد مبهم، يعرض نفس ما يهم فعلاً: من أين تأتي الموجات وما الذي ينجح معها.',
              ),
              const SizedBox(height: 14),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _InsightRow(label: 'المحفز الغالب', value: selected.topTrigger),
                    const Divider(color: AppPalette.stroke, height: 28),
                    _InsightRow(
                      label: 'متوسط الشدة',
                      value: selected.averageCravingIntensity == 0
                          ? 'لا توجد بيانات'
                          : '${selected.averageCravingIntensity.toStringAsFixed(1)}/10',
                    ),
                    const Divider(color: AppPalette.stroke, height: 28),
                    _InsightRow(
                      label: 'أول سيجارة',
                      value: selected.firstSmokeDelayMinutes == null
                          ? 'لا توجد بيانات'
                          : _delayLabel(selected.firstSmokeDelayMinutes!),
                    ),
                    const Divider(color: AppPalette.stroke, height: 28),
                    _InsightRow(
                      label: 'جلسات الإنقاذ',
                      value: '${selected.rescueCount}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeading(
                title: 'فرضيات القرين',
                caption:
                    'هذه ليست أحكامًا نهائية. إنها فرضيات تتحرك من الملاحظة إلى التأكيد عبر الاستخدام الفعلي.',
              ),
              const SizedBox(height: 14),
              ...digest.hypotheses.map(
                (BehaviorHypothesis hypothesis) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                hypothesis.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            _StatusBadge(status: hypothesis.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hypothesis.detail,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPalette.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'تجربة اليوم',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _experimentPrompt(selected),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _delayLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes د';
    }
    final int hours = minutes ~/ 60;
    final int remain = minutes % 60;
    return remain == 0 ? '$hours س' : '$hours س $remain د';
  }

  String _interventionLabel(InterventionType type) {
    return switch (type) {
      InterventionType.breathing => 'تنفس موجه',
      InterventionType.ghostCigarette => 'سيجارة شبح',
      InterventionType.guardedAudio => 'حراسة صوتية',
      InterventionType.walk => 'مشي قصير',
      InterventionType.water => 'ماء وتهدئة',
      InterventionType.microCbt => 'إعادة تسمية المحفز',
      InterventionType.driveShield => 'درع القيادة',
      InterventionType.notificationOnly => 'تنبيه سريع',
    };
  }

  String _experimentPrompt(InsightWindowSummary selected) {
    if (selected.topTrigger.contains('القهوة') ||
        selected.topTrigger.contains('الأكل')) {
      return 'جرّب اليوم استبدال أول طقس بعد القهوة أو الأكل بتنفس موجه أو سيجارة شبح، ثم راقب هل تأخرت أول سيجارة.';
    }
    if (selected.topTrigger.contains('الضغط')) {
      return 'اليوم لا تنتظر حتى تتضخم الموجة. سمّ الضغط فور ظهوره وابدأ إنقاذًا قصيرًا قبل أن يتحول إلى عادة.';
    }
    if (selected.topTrigger.contains('القيادة')) {
      return 'فعّل درع القيادة مبكرًا قبل الوقفة أو قبل أول دقيقة انتظار، ثم راقب أثر ذلك على الرغبة.';
    }
    return 'اختر مهمة نجاة واحدة وكررها في نفس السياق مرتين اليوم. الهدف ليس الكمال، بل إعادة تعريف هذا السياق في دماغك.';
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color tint = switch (status) {
      'مؤكدة' => AppPalette.emerald,
      'مرجحة' => AppPalette.primary,
      'تحت الملاحظة' => AppPalette.amber,
      _ => AppPalette.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: tint),
      ),
    );
  }
}
