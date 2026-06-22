import 'dart:math' as math;
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
              const SizedBox(height: 16),
              _RiskHeatMapGrid(topTrigger: selected.topTrigger),
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

class _RiskHeatMapGrid extends StatefulWidget {
  const _RiskHeatMapGrid({required this.topTrigger});

  final String topTrigger;

  @override
  State<_RiskHeatMapGrid> createState() => _RiskHeatMapGridState();
}

class _RiskHeatMapGridState extends State<_RiskHeatMapGrid> {
  int? _selectedDay;
  int? _selectedSlot;

  double _getRisk(int day, int slot) {
    double base = 0.12 + (math.sin(day * 1.6 + slot * 0.9).abs() * 0.35);
    final String trigger = widget.topTrigger;
    if (trigger.contains('القهوة') || trigger.contains('الأكل')) {
      if (slot == 0) base += 0.42;
      if (slot == 1) base += 0.25;
    } else if (trigger.contains('الضغط')) {
      if (day >= 1 && day <= 5 && slot == 1) base += 0.48;
      if (day >= 1 && day <= 5 && slot == 2) base += 0.3;
    } else if (trigger.contains('القيادة')) {
      if (slot == 2) base += 0.45;
      if (day == 0 || day == 6) base += 0.2;
    } else if (trigger.contains('ريلز') || trigger.contains('التصفح')) {
      if (slot == 3) base += 0.52;
    }
    return base.clamp(0.05, 0.98);
  }

  Color _getCellColor(double risk) {
    if (risk < 0.3) {
      return Colors.white.withValues(alpha: 0.05);
    } else if (risk < 0.55) {
      return AppPalette.secondary.withValues(alpha: 0.4);
    } else if (risk < 0.78) {
      return AppPalette.amber.withValues(alpha: 0.72);
    } else {
      return AppPalette.danger.withValues(alpha: 0.86);
    }
  }

  List<BoxShadow>? _getCellShadow(double risk, Color color) {
    if (risk >= 0.78) {
      return [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 8,
          spreadRadius: 1,
        )
      ];
    } else if (risk >= 0.55) {
      return [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 5,
        )
      ];
    }
    return null;
  }

  String _getSlotName(int slot) {
    return switch (slot) {
      0 => 'صباحًا (6:00 - 12:00)',
      1 => 'ظهرًا (12:00 - 18:00)',
      2 => 'مساءً (18:00 - 00:00)',
      _ => 'ليلاً (00:00 - 6:00)',
    };
  }

  String _getDayName(int day) {
    final List<String> days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    return days[day];
  }

  @override
  Widget build(BuildContext context) {
    final List<String> daysAbbr = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    final List<String> slotsAbbr = ['صباح', 'ظهر', 'مساء', 'ليل'];

    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.grid_on_rounded, color: AppPalette.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'خريطة مخاطر الرغبة السلوكية',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'توزيع جغرافي وسياقي لاحتمالية حدوث الموجات على مدار الأسبوع.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPalette.textSecondary,
                ),
          ),
          const SizedBox(height: 18),
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                children: [
                  const SizedBox(width: 45, height: 26),
                  ...List.generate(7, (day) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 6),
                        width: 32,
                        alignment: Alignment.center,
                        child: Text(
                          daysAbbr[day],
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppPalette.textMuted,
                                fontSize: 9.5,
                              ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              ...List.generate(4, (slot) {
                return TableRow(
                  children: [
                    Container(
                      height: 32,
                      width: 45,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        slotsAbbr[slot],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppPalette.textMuted,
                              fontSize: 9.5,
                            ),
                      ),
                    ),
                    ...List.generate(7, (day) {
                      final double risk = _getRisk(day, slot);
                      final Color cellColor = _getCellColor(risk);
                      final bool isSelected = _selectedDay == day && _selectedSlot == slot;

                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                              _selectedSlot = slot;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.all(3),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.05),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              boxShadow: _getCellShadow(risk, cellColor),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text('منخفض', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppPalette.textMuted, fontSize: 9)),
              const SizedBox(width: 4),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppPalette.secondary.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppPalette.amber.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppPalette.danger.withValues(alpha: 0.86), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text('مرتفع جداً', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppPalette.textMuted, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppPalette.stroke),
            ),
            child: _selectedDay == null
                ? Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppPalette.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'انقر على أي مربع بالخريطة لعرض تفاصيل التوقيت.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppPalette.textMuted,
                            ),
                      ),
                    ],
                  )
                : Builder(
                    builder: (context) {
                      final double risk = _getRisk(_selectedDay!, _selectedSlot!);
                      final String dayName = _getDayName(_selectedDay!);
                      final String slotName = _getSlotName(_selectedSlot!);
                      final String levelStr = risk >= 0.78
                          ? 'خطر حرج (Critical)'
                          : risk >= 0.55
                              ? 'خطر مرتفع (High)'
                              : risk >= 0.3
                                  ? 'خطر معتدل (Moderate)'
                                  : 'آمن نسبياً (Low)';
                      final Color levelColor = _getCellColor(risk);

                      String contextStr = 'احتمالية منخفضة للموجات في هذا التوقيت.';
                      if (risk >= 0.78) {
                        contextStr = 'سياق خطر جداً مرتبط بـ (${widget.topTrigger})، يوصى ببدء مهمة حراسة أو تثبيت الدرع مبكراً.';
                      } else if (risk >= 0.55) {
                        contextStr = 'نافذة توتر مرجحة. الأفضل البقاء منتبهاً واستخدم كسر التصفح.';
                      } else if (risk >= 0.3) {
                        contextStr = 'سياق اعتيادي معتدل. انتبه للقرارات التلقائية.';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$dayName - $slotName',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${(risk * 100).round()}% - $levelStr',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: levelColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            contextStr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppPalette.textSecondary,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
