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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    _GlowingPulseRing(
                      score: state.riskAssessment.score,
                      level: state.riskAssessment.level,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _riskLabel(state.riskAssessment.level),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: switch (state.riskAssessment.level) {
                              RiskLevel.low => AppPalette.emerald,
                              RiskLevel.moderate => AppPalette.secondary,
                              RiskLevel.high => AppPalette.amber,
                              RiskLevel.critical => AppPalette.danger,
                            },
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        state.riskAssessment.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.textSecondary,
                              height: 1.45,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
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
                    const SizedBox(height: 22),
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

class _GlowingPulseRing extends StatefulWidget {
  const _GlowingPulseRing({
    required this.score,
    required this.level,
  });

  final double score;
  final RiskLevel level;

  @override
  State<_GlowingPulseRing> createState() => _GlowingPulseRingState();
}

class _GlowingPulseRingState extends State<_GlowingPulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final Duration duration = _durationFor(widget.level);
    _pulseController = AnimationController(
      vsync: this,
      duration: duration,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _GlowingPulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _pulseController.duration = _durationFor(widget.level);
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  Duration _durationFor(RiskLevel level) {
    return switch (level) {
      RiskLevel.low => const Duration(seconds: 3),
      RiskLevel.moderate => const Duration(seconds: 2),
      RiskLevel.high => const Duration(milliseconds: 1200),
      RiskLevel.critical => const Duration(milliseconds: 800),
    };
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color tintColor = switch (widget.level) {
      RiskLevel.low => AppPalette.emerald,
      RiskLevel.moderate => AppPalette.secondary,
      RiskLevel.high => AppPalette.amber,
      RiskLevel.critical => AppPalette.danger,
    };

    final int percent = (widget.score * 100).round();

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (BuildContext context, Widget? child) {
        final double glowSize = 130.0 + (_pulseController.value * 28.0);
        final double opacity = 0.06 + ((1.0 - _pulseController.value) * 0.14);

        return SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: tintColor.withValues(alpha: opacity),
                      blurRadius: 32,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: widget.score,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  color: tintColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.surface.withValues(alpha: 0.88),
                  border: Border.all(
                    color: tintColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'مستوى الخطر',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppPalette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

