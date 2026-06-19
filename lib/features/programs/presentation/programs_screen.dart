import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/core/widgets/section_heading.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/companion_mission.dart';
import 'package:nafas_os/shared/models/mission_memory.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'البرامج',
      subtitle:
          'برامج قصيرة ومكررة تبني سلوكًا بديلًا، لا مجرد تدخل لحظي واحد.',
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => FrostedCard(
          child: Text('تعذر تحميل البرامج.\n$error'),
        ),
        data: (NafasDashboardState state) {
          final List<_ProgramPlan> foundationPrograms = <_ProgramPlan>[
            _ProgramPlan(
              title: 'برنامج ما بعد الضغط',
              subtitle:
                  'يفك اقتران إشعارات العمل والتوتر مع السيجارة عبر إعادة تسمية المحفز ثم تهدئته.',
              icon: Icons.work_history_rounded,
              tint: AppPalette.amber,
              interventionType: InterventionType.microCbt,
              interactionMode: MissionInteractionMode.tapSequence,
              steps: const <String>[
                'سم المحفز فورًا بدل أن تذوب داخله.',
                'أوقف الحلقة بـ 45 ثانية وعي أو تنفس.',
                'سجل النتيجة حتى يتعلم المحرك ما الذي نجح.',
              ],
            ),
            _ProgramPlan(
              title: 'برنامج القيادة والانتظار',
              subtitle:
                  'يبني طقسًا بديلًا عندما تكون السيارة أو الوقفة القصيرة هي المحفز.',
              icon: Icons.directions_car_filled_rounded,
              tint: AppPalette.secondary,
              interventionType: InterventionType.driveShield,
              interactionMode: MissionInteractionMode.holdShield,
              steps: const <String>[
                'فعّل درع القيادة قبل الحركة أو أثناء الانتظار.',
                'استبدل السيجارة الأولى بمهمة حركية قصيرة.',
                'كرر النجاة في نفس السياق حتى يضعف الرابط القديم.',
              ],
            ),
            _ProgramPlan(
              title: 'برنامج ريلز ثم نجاة',
              subtitle:
                  'يكسر نافذة التصفح الطويل التي تسبق الرغبة ويحولها إلى مقاطعة واعية.',
              icon: Icons.smart_display_rounded,
              tint: AppPalette.primary,
              interventionType: InterventionType.walk,
              interactionMode: MissionInteractionMode.tapSequence,
              steps: const <String>[
                'راقب طول الجلسة بدل لوم نفسك على التطبيق.',
                'حوّل آخر دقيقة من التصفح إلى توقف مقصود.',
                'اختبر هل انخفضت الرغبة أم انتقلت إلى سياق آخر.',
              ],
            ),
            _ProgramPlan(
              title: 'برنامج بعد الأكل والقهوة',
              subtitle:
                  'يعيد بناء الطقس التقليدي بعد الوجبة أو القهوة دون دخان.',
              icon: Icons.local_cafe_rounded,
              tint: AppPalette.emerald,
              interventionType: InterventionType.ghostCigarette,
              interactionMode: MissionInteractionMode.breathCycle,
              steps: const <String>[
                'ابدأ طقسًا بديلًا بدل السيجارة التلقائية.',
                'اربط السحب بالتنفس لا بالدخان.',
                'اجمع مرات النجاة في هذا السياق حتى يصبح مألوفًا.',
              ],
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _RecommendedProgramHero(
                title: _recommendedProgramTitle(
                  state.riskAssessment.recommendedIntervention,
                ),
                summary: state.riskAssessment.summary,
                onStart: () async {
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                  .startRescueFlow(
                    interventionType:
                        state.riskAssessment.recommendedIntervention,
                  );
                },
              ),
              const SizedBox(height: 22),
              const SectionHeading(
                title: 'برامج اليوم',
                caption:
                    'هذه البرامج مبنية على السياق الحالي فعلًا، لا على خطة عامة ثابتة.',
              ),
              const SizedBox(height: 12),
              ...state.missions.map(
                (CompanionMission mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _LiveMissionProgramCard(
                    mission: mission,
                    onStart: () async {
                      await ref
                          .read(nafasEngineControllerProvider.notifier)
                      .startRescueFlow(
                        interventionType: mission.interventionType,
                        missionId: mission.id,
                      );
                    },
                  ),
                ),
              ),
              if (state.missionMemories.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                const SectionHeading(
                  title: 'ذاكرة النجاة',
                  caption:
                      'المهمات التي بدأت تتحول من تدخلات عابرة إلى عادات مقاومة قابلة للتكرار.',
                ),
                const SizedBox(height: 12),
                ...state.missionMemories.take(4).map(
                  (MissionMemory memory) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _MissionMemoryCard(memory: memory),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const SectionHeading(
                title: 'مكتبة السلاسل السلوكية',
                caption:
                    'برامج مؤسسة على أكثر السيناريوهات تكرارًا، وتتحول لاحقًا إلى عادات نجاة مستقرة.',
              ),
              const SizedBox(height: 12),
              ...foundationPrograms.map(
                (_ProgramPlan plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ProgramCard(
                    plan: plan,
                    onStart: () async {
                      await ref
                          .read(nafasEngineControllerProvider.notifier)
                      .startRescueFlow(
                        interventionType: plan.interventionType,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _recommendedProgramTitle(InterventionType type) {
    return switch (type) {
      InterventionType.driveShield => 'برنامج القيادة والانتظار',
      InterventionType.ghostCigarette => 'برنامج بعد الأكل والقهوة',
      InterventionType.microCbt => 'برنامج ما بعد الضغط',
      InterventionType.walk => 'برنامج ريلز ثم نجاة',
      InterventionType.breathing => 'برنامج موجة التنفس',
      InterventionType.guardedAudio => 'برنامج الحراسة الصوتية',
      InterventionType.water => 'برنامج كسر الجفاف والتوتر',
      InterventionType.notificationOnly => 'برنامج المقاطعة السريعة',
    };
  }
}

class _ProgramPlan {
  const _ProgramPlan({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.interventionType,
    required this.interactionMode,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final InterventionType interventionType;
  final MissionInteractionMode interactionMode;
  final List<String> steps;
}

class _RecommendedProgramHero extends StatelessWidget {
  const _RecommendedProgramHero({
    required this.title,
    required this.summary,
    required this.onStart,
  });

  final String title;
  final String summary;
  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'البرنامج المقترح الآن',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onStart,
            child: const Text('ابدأ الآن'),
          ),
        ],
      ),
    );
  }
}

class _LiveMissionProgramCard extends StatelessWidget {
  const _LiveMissionProgramCard({
    required this.mission,
    required this.onStart,
  });

  final CompanionMission mission;
  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mission.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mission.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ModePill(mode: mission.interactionMode),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: mission.completionRatio,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'تقدم اليوم ${mission.progress}/${mission.target}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPalette.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            mission.rewardLine,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('ابدأ المهمة الحية'),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.plan,
    required this.onStart,
  });

  final _ProgramPlan plan;
  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: plan.tint.withValues(alpha: 0.16),
                child: Icon(plan.icon, color: plan.tint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      plan.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ModePill(mode: plan.interactionMode),
            ],
          ),
          const SizedBox(height: 14),
          ...plan.steps.map(
            (String step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                      color: AppPalette.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('ابدأ هذا البرنامج'),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.mode});

  final MissionInteractionMode mode;

  @override
  Widget build(BuildContext context) {
    final (String label, IconData icon, Color color) = switch (mode) {
      MissionInteractionMode.tapSequence => (
        'نقرات',
        Icons.touch_app_rounded,
        AppPalette.primary,
      ),
      MissionInteractionMode.holdShield => (
        'تثبيت',
        Icons.pan_tool_alt_rounded,
        AppPalette.secondary,
      ),
      MissionInteractionMode.breathCycle => (
        'تنفس',
        Icons.air_rounded,
        AppPalette.emerald,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionMemoryCard extends StatelessWidget {
  const _MissionMemoryCard({required this.memory});

  final MissionMemory memory;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _missionTitle(memory.missionId),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppPalette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'زخم ${(memory.momentumScore * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _metric(context, 'بدأت', '${memory.startedCount}'),
              _metric(context, 'نجحت', '${memory.successCount}'),
              _metric(context, 'الحالية', '${memory.currentStreak}'),
              _metric(context, 'الأفضل', '${memory.bestStreak}'),
              _metric(
                context,
                'النجاح',
                '${(memory.successRate * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'آخر نتيجة: ${_lastOutcome(memory.lastOutcome)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppPalette.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }

  String _missionTitle(String id) {
    return switch (id) {
      'reels_interrupt' => 'اكسر نافذة الريلز',
      'drive_shield' => 'درع القيادة',
      'stand_and_shift' => 'حرّك جسدك قبل القرار',
      'stress_reframe' => 'سمِّ الضغط قبل أن يقودك',
      'default_wave' => 'مهمة نجاة الدقيقتين',
      _ => id.replaceAll('_', ' '),
    };
  }

  String _lastOutcome(String value) {
    return switch (value) {
      'success' => 'نجاة ناجحة',
      'failure' => 'تعثر يحتاج إعادة بناء',
      'started' => 'بدأت المهمة',
      _ => 'تحت التعلم',
    };
  }
}
