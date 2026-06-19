import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/metric_chip.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/core/widgets/section_heading.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/companion_mission.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenPrograms,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPrograms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'أنا الآن',
      subtitle: 'شاشة القرين: حالة اللحظة، المهمة التالية، وما الذي يقرأه Nafas عنك.',
      action: IconButton.filledTonal(
        onPressed: onOpenSettings,
        icon: const Icon(Icons.settings_outlined),
      ),
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (Object error, StackTrace stackTrace) => FrostedCard(
              child: Text('تعذر تحميل اللوحة.\n$error'),
            ),
        data: (NafasDashboardState state) {
          final int percent = (state.riskAssessment.score * 100).round();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _riskLabel(state.riskAssessment.level),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.riskAssessment.summary,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppPalette.textSecondary,
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        SizedBox(
                          width: 112,
                          height: 112,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 112,
                                height: 112,
                                child: CircularProgressIndicator(
                                  value: percent / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.06,
                                  ),
                                  color: AppPalette.primary,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    '$percent%',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  Text(
                                    'الخطر',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppPalette.textMuted,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        MetricChip(
                          label: 'منذ آخر سيجارة',
                          value: _formatMinutes(state.summary.minutesSinceLastSmoke),
                        ),
                        MetricChip(
                          label: 'النافذة التالية',
                          value: state.summary.nextRiskWindowLabel,
                          tint: AppPalette.secondary,
                        ),
                        MetricChip(
                          label: 'أفضل تدخل',
                          value: _interventionLabel(
                            state.riskAssessment.recommendedIntervention,
                          ),
                          tint: AppPalette.emerald,
                        ),
                        MetricChip(
                          label: 'الانجراف الرقمي',
                          value:
                              '${(state.summary.digitalDriftScore * 100).round()}%',
                          tint: AppPalette.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: onOpenPrograms,
                            icon: const Icon(Icons.auto_stories_rounded),
                            label: const Text('البرامج'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                () => ref
                                    .read(nafasEngineControllerProvider.notifier)
                        .startRescueFlow(),
                            icon: const Icon(Icons.flash_on_rounded),
                            label: const Text('الإنقاذ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      state.companionBrief.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.companionBrief.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        MetricChip(
                          label: 'تركيز القرين',
                          value: state.companionBrief.focusLabel,
                          tint: AppPalette.primary,
                        ),
                        MetricChip(
                          label: 'المكان',
                          value: _placeLabel(state.summary.placeIdentityLabel),
                          tint: AppPalette.secondary,
                        ),
                        MetricChip(
                          label: 'الثبات',
                          value:
                              state.summary.stationaryMinutes == 0
                                  ? 'متحرك'
                                  : '${state.summary.stationaryMinutes} د',
                          tint: AppPalette.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.companionBrief.vibeLine,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeading(
                title: 'مهمات القرين',
                caption: 'مهمات قصيرة وممتعة مبنية على السياق الحالي بدل نصائح عامة ثابتة.',
              ),
              const SizedBox(height: 14),
              ...state.missions.map(
                (CompanionMission mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MissionCard(
                    mission: mission,
                    onStart:
                        () => ref
                            .read(nafasEngineControllerProvider.notifier)
                .startRescueFlow(
                  interventionType: mission.interventionType,
                  missionId: mission.id,
                ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeading(
                title: 'فهم سريع',
                caption: 'Nafas يربط بين التطبيق الغالب، السكون، والمكان بدل عدّاد واحد مسطح.',
              ),
              const SizedBox(height: 14),
              FrostedCard(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    MetricChip(
                      label: 'التطبيق الغالب',
                      value: _packageLabel(state.summary.dominantAppPackage),
                      tint: AppPalette.secondary,
                    ),
                    MetricChip(
                      label: 'فيديو قصير',
                      value: '${state.summary.shortVideoMinutes} د',
                      tint: AppPalette.primary,
                    ),
                    MetricChip(
                      label: 'مراسلات',
                      value: '${state.summary.messagingMinutes} د',
                      tint: AppPalette.emerald,
                    ),
                    MetricChip(
                      label: 'تبديل التطبيقات',
                      value: '${state.summary.appSwitchesLast30m}',
                      tint: AppPalette.amber,
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

  String _riskLabel(RiskLevel level) {
    return switch (level) {
      RiskLevel.low => 'آمن نسبيًا',
      RiskLevel.moderate => 'نافذة تتشكل',
      RiskLevel.high => 'قابل للاشتعال',
      RiskLevel.critical => 'موجة حرجة',
    };
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

  String _formatMinutes(int? minutes) {
    if (minutes == null) {
      return 'لا توجد بيانات';
    }
    if (minutes < 60) {
      return '$minutes د';
    }
    final int hours = minutes ~/ 60;
    final int remain = minutes % 60;
    return remain == 0 ? '$hours س' : '$hours س $remain د';
  }

  String _placeLabel(String raw) {
    return switch (raw) {
      'home_like' => 'يشبه البيت',
      'work_like' => 'يشبه الدوام',
      'recurring_place' => 'مكان متكرر',
      'new_place' => 'مكان جديد',
      'under_observation' => 'تحت الملاحظة',
      'transient' => 'عابر',
      _ => 'غير مصنف',
    };
  }

  String _packageLabel(String packageName) {
    return switch (packageName) {
      'com.instagram.android' => 'إنستاغرام',
      'com.zhiliaoapp.musically' => 'تيك توك',
      'com.google.android.youtube' => 'يوتيوب',
      'com.whatsapp' => 'واتساب',
      'com.whatsapp.w4b' => 'واتساب بزنس',
      'org.telegram.messenger' => 'تيليغرام',
      '' => 'غير واضح',
      _ => packageName,
    };
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onStart});

  final CompanionMission mission;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(mission.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            mission.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: mission.completionRatio,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'التقدم ${mission.progress}/${mission.target}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
          ),
          const SizedBox(height: 10),
          Text(
            mission.rewardLine,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('ابدأ المهمة'),
          ),
        ],
      ),
    );
  }
}
