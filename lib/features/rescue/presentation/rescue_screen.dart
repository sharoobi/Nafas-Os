import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/core/widgets/section_heading.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class RescueScreen extends ConsumerStatefulWidget {
  const RescueScreen({super.key});

  @override
  ConsumerState<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends ConsumerState<RescueScreen> {
  Timer? _heartbeat;

  @override
  void initState() {
    super.initState();
    _heartbeat = Timer.periodic(const Duration(seconds: 20), (_) {
      ref.read(nafasEngineControllerProvider.notifier).refreshDashboard();
    });
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'وضع الإنقاذ',
      subtitle: 'حوّل الـ 45 ثانية القادمة من اندفاع تلقائي إلى تدخل موجّه.',
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            FrostedCard(child: Text('تعذر تحميل وضع الإنقاذ.\n$error')),
        data: (NafasDashboardState state) {
          final InterventionType activeIntervention =
              state.activeRescueIntervention ??
              state.riskAssessment.recommendedIntervention;
          final _RescueMission mission = _missionFor(activeIntervention);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeroCard(context, state, activeIntervention),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(nafasEngineControllerProvider.notifier)
                    .startRescueFlow(interventionType: activeIntervention);
                      },
                      icon: const Icon(Icons.flash_on_rounded),
                      label: Text(
                        'ابدأ ${_interventionLabel(activeIntervention)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _handleAudioGuardAction(context, ref, state),
                      icon: Icon(
                        state.guardedAudioSession.active
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                      ),
                      label: Text(
                        state.guardedAudioSession.active
                            ? 'أوقف الحراسة الصوتية'
                            : 'ابدأ الحراسة الصوتية',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!state.labSettings.guardedAudioEnabled ||
                  !state.permissions.microphone) ...<Widget>[
                _AudioGuardSetupCard(
                  microphoneGranted: state.permissions.microphone,
                  audioGuardEnabled: state.labSettings.guardedAudioEnabled,
                  onOpenSetup: () =>
                      _showAudioGuardSetupSheet(context, ref, state),
                ),
                const SizedBox(height: 16),
              ],
              if (state.guardedAudioSession.active) ...<Widget>[
                _buildAudioVerdictCard(context, state),
                const SizedBox(height: 16),
              ],
              if (state.activeRescueIntervention != null) ...<Widget>[
                _buildActiveMissionCard(context, state, mission),
                const SizedBox(height: 24),
              ],
              const SectionHeading(
                title: 'مهام الإنقاذ',
                caption:
                    'كل مهمة قصيرة وحسية وواضحة حتى تكسر الحلقة قبل أن تتحول إلى سيجارة.',
              ),
              const SizedBox(height: 14),
              _RescueInteractiveMissionCard(
                title: state.missions.isEmpty
                    ? 'نشاط النجاة السريع'
                    : state.missions.first.title,
                subtitle: state.missions.isEmpty
                    ? 'نشاط قصير يكسر الاندفاع قبل أن يصبح قرارًا.'
                    : state.missions.first.subtitle,
                target: _challengeTarget(activeIntervention),
                interactionMode: state.missions.isEmpty
                    ? MissionInteractionMode.tapSequence
                    : state.missions.first.interactionMode,
                onCompleted: () async {
                  if (state.activeRescueIntervention == null) {
                    await ref
                        .read(nafasEngineControllerProvider.notifier)
                .startRescueFlow(interventionType: activeIntervention);
                  }
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                      .completeActiveRescue(successful: true);
                },
              ),
              const SizedBox(height: 16),
              _buildMissionCard(context, mission),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _DurationChip(
                    label: '45 ث',
                    selected: state.labSettings.rescueDurationSeconds == 45,
                    onTap: () => ref
                        .read(nafasEngineControllerProvider.notifier)
                        .saveLabSettings(rescueDurationSeconds: 45),
                  ),
                  _DurationChip(
                    label: '60 ث',
                    selected: state.labSettings.rescueDurationSeconds == 60,
                    onTap: () => ref
                        .read(nafasEngineControllerProvider.notifier)
                        .saveLabSettings(rescueDurationSeconds: 60),
                  ),
                  _DurationChip(
                    label: '90 ث',
                    selected: state.labSettings.rescueDurationSeconds == 90,
                    onTap: () => ref
                        .read(nafasEngineControllerProvider.notifier)
                        .saveLabSettings(rescueDurationSeconds: 90),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'النص الموجّه',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _scriptFor(activeIntervention),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _RescueRecipeCard(
                title: 'سيجارة شبح',
                subtitle:
                    'طقس بديل: صوت رمزي + هبتكس + أربع سحبات هواء بدل السيجارة.',
                icon: Icons.auto_awesome_rounded,
                tint: AppPalette.primary,
                selected: activeIntervention == InterventionType.ghostCigarette,
                onTap: () async {
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                      .startRescueFlow(
                        interventionType: InterventionType.ghostCigarette,
                      );
                },
              ),
              const SizedBox(height: 12),
              _RescueRecipeCard(
                title: 'درع القيادة',
                subtitle:
                    'أزرار ضخمة وتدخل مختصر عندما يكون الخطر مرتبطًا بالقيادة.',
                icon: Icons.directions_car_filled_rounded,
                tint: AppPalette.secondary,
                selected: activeIntervention == InterventionType.driveShield,
                onTap: () async {
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                      .startRescueFlow(
                        interventionType: InterventionType.driveShield,
                      );
                },
              ),
              const SizedBox(height: 12),
              _RescueRecipeCard(
                title: 'إعادة تسمية المحفز',
                subtitle:
                    'سمِّ ما يحدث: قهوة، ضغط، ملل، أو عادة. التسمية تُضعف الشدة.',
                icon: Icons.psychology_alt_rounded,
                tint: AppPalette.emerald,
                selected: activeIntervention == InterventionType.microCbt,
                onTap: () async {
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                      .startRescueFlow(
                        interventionType: InterventionType.microCbt,
                      );
                },
              ),
              const SizedBox(height: 12),
              _RescueRecipeCard(
                title: 'تنفس موجّه',
                subtitle:
                    'تدخل أهدأ عندما تكون الأعراض أو التوتر بحاجة إلى هبوط أسرع.',
                icon: Icons.air_rounded,
                tint: AppPalette.amber,
                selected: activeIntervention == InterventionType.breathing,
                onTap: () async {
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                      .startRescueFlow(
                        interventionType: InterventionType.breathing,
                      );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    NafasDashboardState state,
    InterventionType activeIntervention,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF16353A), Color(0xFF0A1B22)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 184,
            height: 184,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppPalette.rescueGlow,
            ),
            child: Container(
              margin: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.surface.withValues(alpha: 0.72),
                border: Border.all(
                  color: AppPalette.primary.withValues(alpha: 0.28),
                  width: 1.3,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${state.labSettings.rescueDurationSeconds}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Text(
                    'ثانية',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _headlineFor(activeIntervention),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            state.riskAssessment.summary,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _AudioMetricChip(
                label: 'مستوى الخطر',
                value: state.riskAssessment.level.name,
              ),
              _AudioMetricChip(
                label: 'أفضل تدخل',
                value: _interventionLabel(
                  state.riskAssessment.recommendedIntervention,
                ),
              ),
              _AudioMetricChip(
                label: 'التبريد',
                value: '${state.labSettings.notificationCooldownMinutes} د',
              ),
            ],
          ),
          if (state.guardedAudioSession.active) ...<Widget>[
            const SizedBox(height: 16),
            _CountdownBanner(
              endsAt: state.guardedAudioSession.endsAt,
              fallbackSeconds: state.guardedAudioSession.remainingSeconds,
              label: 'الحراسة الصوتية نشطة',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _AudioMetricChip(
                  label: 'متوسط الإشارة',
                  value: '${state.guardedAudioSession.averageAmplitude}',
                ),
                _AudioMetricChip(
                  label: 'الذروة',
                  value: '${state.guardedAudioSession.peakAmplitude}',
                ),
                _AudioMetricChip(
                  label: 'شرارات قداحة',
                  value: '${state.guardedAudioSession.lighterLikeSpikes}',
                ),
                _AudioMetricChip(
                  label: 'نوبات سعال',
                  value: '${state.guardedAudioSession.coughLikeBursts}',
                ),
                _AudioMetricChip(
                  label: 'دورات تنفس ثابت',
                  value: '${state.guardedAudioSession.steadyBreathCycles}',
                ),
                _AudioMetricChip(
                  label: 'اندفاعات قلق',
                  value: '${state.guardedAudioSession.restlessnessBursts}',
                ),
                _AudioMetricChip(
                  label: 'خطر صوتي',
                  value: '${state.guardedAudioSession.audioRiskScore}%',
                ),
              ],
            ),
          ] else if (state.activeRescueIntervention != null &&
              state.activeRescueStartedAt != null) ...<Widget>[
            const SizedBox(height: 16),
            _CountdownBanner(
              endsAt: state.activeRescueStartedAt!.add(
                Duration(seconds: state.labSettings.rescueDurationSeconds),
              ),
              fallbackSeconds: state.labSettings.rescueDurationSeconds,
              label: 'جلسة الإنقاذ الحالية',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveMissionCard(
    BuildContext context,
    NafasDashboardState state,
    _RescueMission mission,
  ) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('المهمة النشطة', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'التدخل الحالي: ${_interventionLabel(state.activeRescueIntervention!)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (state.activeRescueStartedAt != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'بدأت عند ${_timeLabel(state.activeRescueStartedAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          ...mission.steps.map(
            (String step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: AppPalette.emerald,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(step)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(nafasEngineControllerProvider.notifier)
                        .completeActiveRescue(successful: true);
                  },
                  child: const Text('نجحت'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(nafasEngineControllerProvider.notifier)
                        .moveToNextRescueApproach();
                  },
                  child: const Text('بدّل الخطة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioVerdictCard(
    BuildContext context,
    NafasDashboardState state,
  ) {
    final String verdict = state.guardedAudioSession.classificationLabel;
    final double confidence = state.guardedAudioSession.classificationConfidence;
    final String action = state.guardedAudioSession.recommendedAction;
    final latestSample = state.recentGuardedAudioSamples.isEmpty
        ? null
        : state.recentGuardedAudioSamples.first;
    final List<String> labelOptions = <String>[
      'lighter_like_pattern',
      'restless_window',
      'steady_breathing',
      'cough_stress',
      'high_arousal_audio',
      'ambient_or_unclear',
    ];

    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.hearing_rounded, color: AppPalette.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'حكم الحراسة الصوتية',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(confidence * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _audioVerdictTitle(verdict),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _audioVerdictBody(verdict),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'الاقتراح الآن: ${_audioActionLabel(action)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (latestSample != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              'وسم آخر جلسة محفوظة',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              latestSample.confirmedLabel == null
                  ? 'هذه الجلسة محفوظة الآن كعينة تدريب حقيقية. وسّمها من هنا ليصبح البناء القادم للنموذج أقرب لسلوكك الحقيقي.'
                  : 'الوسم الحالي: ${_audioVerdictTitle(latestSample.confirmedLabel!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: labelOptions.map((String label) {
                final bool selected = latestSample.confirmedLabel == label;
                return FilterChip(
                  selected: selected,
                  label: Text(_audioVerdictTitle(label)),
                  onSelected: (_) async {
                    await ref
                        .read(nafasEngineControllerProvider.notifier)
                        .labelGuardedAudioSample(
                          id: latestSample.id,
                          confirmedLabel: label,
                        );
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, _RescueMission mission) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(mission.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            mission.goal,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          ...mission.steps.map(
            (String step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppPalette.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(step)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              mission.rewardLine,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _headlineFor(InterventionType intervention) {
    return switch (intervention) {
      InterventionType.breathing => 'تنفس. ثبّت الجسد. أجّل القرار.',
      InterventionType.ghostCigarette => 'خذ الطقس بدون السم',
      InterventionType.guardedAudio => 'افتح جلسة حراسة قصيرة وراقب الإشارة',
      InterventionType.walk => 'اكسر الحلقة بالحركة الآن',
      InterventionType.water => 'استبدل الإشارة بالماء والتهدئة',
      InterventionType.microCbt => 'سمِّ المحفز قبل أن يتحول إلى فعل',
      InterventionType.driveShield => 'ابقَ مع الطريق لا مع السيجارة',
      InterventionType.notificationOnly => 'نفّذ مقاطعة قصيرة الآن',
    };
  }

  String _audioVerdictTitle(String value) {
    return switch (value) {
      'lighter_like_pattern' => 'إشارة قدّاحة أو طقس إشعال',
      'restless_window' => 'نافذة قلق أو تململ',
      'steady_breathing' => 'تنفس ثابت ومسيطر عليه',
      'cough_stress' => 'سعال أو ضغط تنفسي',
      'high_arousal_audio' => 'استثارة صوتية مرتفعة',
      'warming_up' => 'الجلسة ما زالت تجمع إشارات',
      _ => 'إشارة محيطة غير حاسمة',
    };
  }

  String _audioVerdictBody(String value) {
    return switch (value) {
      'lighter_like_pattern' =>
        'الصوت الحالي يشبه بداية طقس التدخين أكثر من كونه ضجيجًا عابرًا. الأفضل قطع السلسلة الآن قبل القرار.',
      'restless_window' =>
        'هناك تململ وتغيرات سريعة ترجّح نافذة رغبة أو توتر. ركّز على مهمة قصيرة بدل ترك اللحظة تتمدد.',
      'steady_breathing' =>
        'النمط الحالي أقرب إلى تنفس منظم. هذا وقت جيد لتثبيت الجلسة وتحويلها إلى نجاة ناجحة.',
      'cough_stress' =>
        'الصوت يحمل ضغطًا تنفسيًا أو سعالًا. هنا نفضّل تهدئة الجسد لا أي تدخل صاخب.',
      'high_arousal_audio' =>
        'الاستثارة مرتفعة لكن السبب ليس محسومًا بعد. الأفضل تدخل سريع منخفض الاحتكاك.',
      'warming_up' =>
        'المنظومة ما زالت تبني عينة كافية قبل الحكم. استمر دقيقة إضافية إذا أردت Verdict أدق.',
      _ =>
        'الإشارات الحالية غير كافية للحكم على طقس تدخين واضح. نعتمد أكثر على السياق والسلوك العام.',
    };
  }

  String _audioActionLabel(String value) {
    return switch (value) {
      'ghost_cigarette' => 'سيجارة شبح',
      'micro_cbt' => 'إعادة تسمية المحفز',
      'breathing' => 'تنفس موجّه',
      'walk' => 'حركة قصيرة',
      'water' => 'شرب ماء',
      _ => 'راقب الدقيقة التالية',
    };
  }

  String _scriptFor(InterventionType intervention) {
    return switch (intervention) {
      InterventionType.breathing =>
        'اسحب 4 ثوانٍ، احبس 4، ازفر 6. كرر أربع دورات قبل أي قرار.',
      InterventionType.ghostCigarette =>
        'خذ أربع سحبات هواء بطيئة. احتفظ بالطقس. أزل السم.',
      InterventionType.guardedAudio =>
        'ابدأ جلسة صريحة قصيرة. راقب النفس والسعال والشرارات بدون حكم.',
      InterventionType.walk =>
        'تحرك فورًا. عشرون خطوة سريعة تكفي لكسر أول حلقة.',
      InterventionType.water =>
        'اشرب الماء ببطء ثم ضع الكوب. استبدل الإشارة بدل الجدل معها.',
      InterventionType.microCbt =>
        'سمِّ المحفز الآن: قهوة، ضغط، ملل، أو عادة. التسمية تقلل سطوته.',
      InterventionType.driveShield =>
        'حافظ على اليدين على المقود، والتنفس في الصدر لا في سيجارة. ركز على ثلاث زفرات طويلة.',
      InterventionType.notificationOnly =>
        'لا تؤجل أكثر. افتح تدخلاً قصيرًا الآن قبل أن تتحول الإشارة إلى تجاهل.',
    };
  }

  String _interventionLabel(InterventionType type) {
    return switch (type) {
      InterventionType.breathing => 'تنفس موجّه',
      InterventionType.ghostCigarette => 'سيجارة شبح',
      InterventionType.guardedAudio => 'حراسة صوتية',
      InterventionType.walk => 'مشي قصير',
      InterventionType.water => 'ماء وتهدئة',
      InterventionType.microCbt => 'إعادة تسمية المحفز',
      InterventionType.driveShield => 'درع القيادة',
      InterventionType.notificationOnly => 'تدخل سريع',
    };
  }

  int _challengeTarget(InterventionType type) {
    return switch (type) {
      InterventionType.ghostCigarette => 4,
      InterventionType.breathing => 4,
      InterventionType.driveShield => 5,
      InterventionType.walk => 7,
      InterventionType.guardedAudio => 6,
      InterventionType.microCbt => 6,
      InterventionType.water => 5,
      InterventionType.notificationOnly => 5,
    };
  }

  _RescueMission _missionFor(InterventionType type) {
    return switch (type) {
      InterventionType.breathing => const _RescueMission(
        title: 'مهمة هبوط النفس',
        goal: 'أعد ضبط الجسد أولًا حتى لا يقودك الاندفاع.',
        steps: <String>[
          'خذ شهيقًا بطيئًا لأربع ثوانٍ.',
          'احبس النفس أربع ثوانٍ بدون شد.',
          'أخرج الزفير لست ثوانٍ أطول من الشهيق.',
        ],
        rewardLine: 'إذا أكملت أربع دورات فأنت كسرت أصعب 30 ثانية في الموجة.',
      ),
      InterventionType.ghostCigarette => const _RescueMission(
        title: 'مهمة الطقس البديل',
        goal: 'احتفظ بطقس السيجارة واسحب منه السم.',
        steps: <String>[
          'أمسك البديل أو الجوال كما لو أنك تمسك السيجارة.',
          'خذ أربع سحبات هواء بطيئة ومتساوية.',
          'دع الزفير أطول من الشهيق في كل مرة.',
        ],
        rewardLine: 'أخذت الطقس، لكنك منعت السيجارة من تثبيت الحلقة.',
      ),
      InterventionType.guardedAudio => const _RescueMission(
        title: 'مهمة المراقبة الصريحة',
        goal: 'راقب الإشارة بدل أن تنفعل معها.',
        steps: <String>[
          'ابدأ جلسة حراسة صوتية قصيرة.',
          'دع التطبيق يلتقط الذروة والسعال واندفاع الإشارة.',
          'عند هبوط الخطر، اختم الجلسة وسجّل النتيجة.',
        ],
        rewardLine: 'كل جلسة مراقبة ناجحة ترفع فهم النظام لبصمتك الشخصية.',
      ),
      InterventionType.walk => const _RescueMission(
        title: 'مهمة كسر الحلقة بالحركة',
        goal: 'انقل الجسد من وضعية التدخين إلى وضعية حركة.',
        steps: <String>[
          'قف فورًا وابدأ المشي.',
          'خذ 20 خطوة سريعة أو دورتين في المكان.',
          'بعد الحركة، قيّم الرغبة من جديد قبل أي قرار.',
        ],
        rewardLine: 'الحركة القصيرة تمنع التحول التلقائي من المحفز إلى الفعل.',
      ),
      InterventionType.water => const _RescueMission(
        title: 'مهمة الاستبدال بالماء',
        goal: 'قدّم للجسد إشارة بديلة سريعة وواضحة.',
        steps: <String>[
          'اشرب الماء ببطء لا بسرعة.',
          'دع الكوب يلمس اليد ويأخذ مكان الطقس للحظات.',
          'بعد الشرب خذ زفيرًا طويلًا قبل أي قرار.',
        ],
        rewardLine: 'الإشارة البديلة الواضحة تضعف اقتران اليد والسيجارة.',
      ),
      InterventionType.microCbt => const _RescueMission(
        title: 'مهمة تسمية المحفز',
        goal: 'حوّل الرغبة من أمر غامض إلى شيء مرئي ومحدد.',
        steps: <String>[
          'قل بصوت داخلي: هذا ضغط أو قهوة أو ملل.',
          'اسأل: هل أحتاج سيجارة أم انتقالًا من التوتر؟',
          'اختر خطوة صغيرة بديلة لمدة 60 ثانية.',
        ],
        rewardLine: 'حين يُسمّى المحفز، يفقد جزءًا من قوته الفورية.',
      ),
      InterventionType.driveShield => const _RescueMission(
        title: 'مهمة حماية القيادة',
        goal: 'مرّر النافذة الخطرة أثناء القيادة بدون تشتيت.',
        steps: <String>[
          'أبقِ اليدين على المقود.',
          'خذ ثلاث زفرات طويلة متتالية.',
          'أجّل أي قرار حتى تتوقف السيارة أو تهبط الموجة.',
        ],
        rewardLine: 'نجاح هذه المهمة يقطع أحد أخطر السياقات المتكررة لديك.',
      ),
      InterventionType.notificationOnly => const _RescueMission(
        title: 'مهمة المقاطعة السريعة',
        goal: 'اكسر الاندفاع قبل أن يكتمل تلقائيًا.',
        steps: <String>[
          'توقف عن الحركة الحالية لثانيتين.',
          'انظر إلى الشاشة وخذ نفسًا واحدًا واعيًا.',
          'اختر تدخلًا أقوى إذا بقي الخطر مرتفعًا.',
        ],
        rewardLine: 'حتى المقاطعة القصيرة قد تمنع السيجارة التلقائية.',
      ),
    };
  }

  String _timeLabel(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _handleAudioGuardAction(
    BuildContext context,
    WidgetRef ref,
    NafasDashboardState state,
  ) async {
    if (state.guardedAudioSession.active) {
      await ref
          .read(nafasEngineControllerProvider.notifier)
          .stopGuardedAudioMode();
      return;
    }
    if (!state.labSettings.guardedAudioEnabled ||
        !state.permissions.microphone) {
      await _showAudioGuardSetupSheet(context, ref, state);
      return;
    }
    await ref
        .read(nafasEngineControllerProvider.notifier)
        .startGuardedAudioMode();
  }

  Future<void> _showAudioGuardSetupSheet(
    BuildContext pageContext,
    WidgetRef ref,
    NafasDashboardState state,
  ) async {
    await showModalBottomSheet<void>(
      context: pageContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: FrostedCard(
            borderRadius: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'إعداد الحراسة الصوتية',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'الحراسة الصوتية جلسة صريحة قصيرة تستخدم الميكروفون فقط عندما تبدأها بنفسك. لهذا يجب أن تكون واضحة ومباشرة من شاشة الإنقاذ.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                _SetupStepTile(
                  index: 1,
                  title: 'امنح إذن الميكروفون',
                  subtitle: state.permissions.microphone
                      ? 'إذن الميكروفون مفعّل بالفعل.'
                      : 'مطلوب لجلسات الاستماع القصيرة الصريحة.',
                  completed: state.permissions.microphone,
                  actionLabel: state.permissions.microphone
                      ? 'مفعّل'
                      : 'فعّل الميكروفون',
                  onPressed: state.permissions.microphone
                      ? null
                      : () async {
                          await ref
                              .read(nafasEngineControllerProvider.notifier)
                              .requestMicrophonePermission();
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          if (!pageContext.mounted) {
                            return;
                          }
                          await _showAudioGuardSetupSheet(
                            pageContext,
                            ref,
                            ref
                                .read(nafasEngineControllerProvider)
                                .requireValue,
                          );
                        },
                ),
                const SizedBox(height: 12),
                _SetupStepTile(
                  index: 2,
                  title: 'فعّل الوصفة داخل نفس',
                  subtitle: state.labSettings.guardedAudioEnabled
                      ? 'الحراسة الصوتية أصبحت جزءًا من دورة الإنقاذ.'
                      : 'هذا يجعل الزر مباشرًا من وضع الإنقاذ بدون الرجوع إلى المختبر.',
                  completed: state.labSettings.guardedAudioEnabled,
                  actionLabel: state.labSettings.guardedAudioEnabled
                      ? 'مفعّل'
                      : 'فعّل الوصفة',
                  onPressed: state.labSettings.guardedAudioEnabled
                      ? null
                      : () async {
                          await ref
                              .read(nafasEngineControllerProvider.notifier)
                              .saveLabSettings(guardedAudioEnabled: true);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                ),
                const SizedBox(height: 12),
                _SetupStepTile(
                  index: 3,
                  title: 'افتح إعدادات النظام عند الحاجة',
                  subtitle:
                      'إذا منع Android نافذة الإذن، افتح الإعدادات وفعّل الميكروفون يدويًا.',
                  completed: false,
                  actionLabel: 'فتح الإعدادات',
                  onPressed: () => openAppSettings(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        state.permissions.microphone &&
                            state.labSettings.guardedAudioEnabled
                        ? () async {
                            Navigator.of(sheetContext).pop();
                            await ref
                                .read(nafasEngineControllerProvider.notifier)
                                .startGuardedAudioMode();
                          }
                        : null,
                    icon: const Icon(Icons.mic_rounded),
                    label: const Text('ابدأ الحراسة الصوتية'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountdownBanner extends StatefulWidget {
  const _CountdownBanner({
    required this.endsAt,
    required this.fallbackSeconds,
    required this.label,
  });

  final DateTime? endsAt;
  final int fallbackSeconds;
  final String label;

  @override
  State<_CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends State<_CountdownBanner> {
  Timer? _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _remaining = _computeRemaining();
      });
    });
  }

  @override
  void didUpdateWidget(covariant _CountdownBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _remaining = _computeRemaining();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.label}: ${_remaining.clamp(0, 3600)} ث متبقية',
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: AppPalette.emerald),
    );
  }

  int _computeRemaining() {
    final DateTime? endsAt = widget.endsAt;
    if (endsAt == null) {
      return widget.fallbackSeconds;
    }
    return endsAt.difference(DateTime.now()).inSeconds;
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _AudioGuardSetupCard extends StatelessWidget {
  const _AudioGuardSetupCard({
    required this.microphoneGranted,
    required this.audioGuardEnabled,
    required this.onOpenSetup,
  });

  final bool microphoneGranted;
  final bool audioGuardEnabled;
  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context) {
    final int completedSteps =
        (microphoneGranted ? 1 : 0) + (audioGuardEnabled ? 1 : 0);
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'الحراسة الصوتية تحتاج إعدادًا صغيرًا',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'اكتمل $completedSteps من أصل خطوتين. بعد اكتمالهما يصبح زر الحراسة الصوتية مباشرًا من شاشة الإنقاذ.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onOpenSetup,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('إكمال الإعداد'),
          ),
        ],
      ),
    );
  }
}

class _SetupStepTile extends StatelessWidget {
  const _SetupStepTile({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.actionLabel,
    required this.onPressed,
  });

  final int index;
  final String title;
  final String subtitle;
  final bool completed;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? AppPalette.emerald.withValues(alpha: 0.2)
                  : AppPalette.primary.withValues(alpha: 0.16),
            ),
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppPalette.emerald,
                  )
                : Text('$index', style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _AudioMetricChip extends StatelessWidget {
  const _AudioMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppPalette.textMuted),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _RescueRecipeCard extends StatelessWidget {
  const _RescueRecipeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: FrostedCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: selected ? 0.24 : 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppPalette.emerald,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RescuePulseChallengeCard extends StatefulWidget {
  const _RescuePulseChallengeCard({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.onCompleted,
  });

  final String title;
  final String subtitle;
  final int target;
  final Future<void> Function() onCompleted;

  @override
  State<_RescuePulseChallengeCard> createState() =>
      _RescuePulseChallengeCardState();
}

class _RescuePulseChallengeCardState extends State<_RescuePulseChallengeCard> {
  int _progress = 0;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final bool complete = _progress >= widget.target;
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('النشاط التفاعلي', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                if (complete || _submitting) {
                  return;
                }
                setState(() {
                  _progress += 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      complete
                          ? AppPalette.emerald.withValues(alpha: 0.34)
                          : AppPalette.primary.withValues(alpha: 0.28),
                      AppPalette.surface,
                    ],
                  ),
                  border: Border.all(
                    color: complete ? AppPalette.emerald : AppPalette.primary,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '$_progress/${widget.target}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complete ? 'اكتملت' : 'المس هنا',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_progress / widget.target).clamp(0.0, 1.0),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              complete ? AppPalette.emerald : AppPalette.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: !complete || _submitting
                ? null
                : () async {
                    setState(() {
                      _submitting = true;
                    });
                    await widget.onCompleted();
                    if (!context.mounted) {
                      return;
                    }
                    setState(() {
                      _submitting = false;
                      _progress = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم احتساب النشاط كنجاة ناجحة.'),
                      ),
                    );
                  },
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('اعتماد النشاط'),
          ),
        ],
      ),
    );
  }
}

class _RescueInteractiveMissionCard extends StatefulWidget {
  const _RescueInteractiveMissionCard({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.interactionMode,
    required this.onCompleted,
  });

  final String title;
  final String subtitle;
  final int target;
  final MissionInteractionMode interactionMode;
  final Future<void> Function() onCompleted;

  @override
  State<_RescueInteractiveMissionCard> createState() =>
      _RescueInteractiveMissionCardState();
}

class _RescueInteractiveMissionCardState
    extends State<_RescueInteractiveMissionCard> {
  int _progress = 0;
  int _breathPhase = 0;
  bool _submitting = false;
  Timer? _holdTimer;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool complete = _progress >= widget.target;
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'النشاط التفاعلي',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            _modeHint(widget.interactionMode),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
          ),
          const SizedBox(height: 16),
          Center(
            child: switch (widget.interactionMode) {
              MissionInteractionMode.tapSequence => GestureDetector(
                onTap: () {
                  if (complete || _submitting) {
                    return;
                  }
                  setState(() {
                    _progress += 1;
                  });
                },
                child: _buildCore(context, complete),
              ),
              MissionInteractionMode.holdShield => GestureDetector(
                onLongPressStart: (_) => _startHolding(),
                onLongPressEnd: (_) => _stopHolding(),
                onLongPressCancel: _stopHolding,
                child: _buildCore(context, complete),
              ),
              MissionInteractionMode.breathCycle => GestureDetector(
                onTap: () {
                  if (complete || _submitting) {
                    return;
                  }
                  setState(() {
                    _breathPhase = (_breathPhase + 1) % 3;
                    if (_breathPhase == 0) {
                      _progress += 1;
                    }
                  });
                },
                child: _buildCore(context, complete),
              ),
            },
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_progress / widget.target).clamp(0.0, 1.0),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              complete ? AppPalette.emerald : _accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: !complete || _submitting
                ? null
                : () async {
                    setState(() {
                      _submitting = true;
                    });
                    await widget.onCompleted();
                    if (!context.mounted) {
                      return;
                    }
                    setState(() {
                      _submitting = false;
                      _progress = 0;
                      _breathPhase = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم احتساب النشاط كنجاة ناجحة.'),
                      ),
                    );
                  },
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('اعتماد النشاط'),
          ),
        ],
      ),
    );
  }

  Widget _buildCore(BuildContext context, bool complete) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            complete
                ? AppPalette.emerald.withValues(alpha: 0.34)
                : _accentColor.withValues(alpha: 0.28),
            AppPalette.surface,
          ],
        ),
        border: Border.all(
          color: complete ? AppPalette.emerald : _accentColor,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$_progress/${widget.target}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            complete ? 'اكتملت' : _phaseLabel,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppPalette.textSecondary),
          ),
        ],
      ),
    );
  }

  Color get _accentColor => switch (widget.interactionMode) {
    MissionInteractionMode.tapSequence => AppPalette.primary,
    MissionInteractionMode.holdShield => AppPalette.secondary,
    MissionInteractionMode.breathCycle => AppPalette.emerald,
  };

  String get _phaseLabel => switch (widget.interactionMode) {
    MissionInteractionMode.tapSequence => 'أنقر',
    MissionInteractionMode.holdShield => 'اثبت',
    MissionInteractionMode.breathCycle => switch (_breathPhase) {
      0 => 'اسحب',
      1 => 'احبس',
      _ => 'ازفر',
    },
  };

  String _modeHint(MissionInteractionMode mode) {
    return switch (mode) {
      MissionInteractionMode.tapSequence =>
        'نقرات سريعة لكسر الاندفاع وتحويله إلى فعل واعٍ قصير.',
      MissionInteractionMode.holdShield =>
        'ثبت إصبعك على الدائرة حتى يهدأ الجسم بدل أن يهرب إلى السيجارة.',
      MissionInteractionMode.breathCycle =>
        'كل ثلاث نقرات تعني دورة تنفس كاملة: اسحب، احبس، ازفر.',
    };
  }

  void _startHolding() {
    if (_submitting || _progress >= widget.target) {
      return;
    }
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 220), (_) {
      if (!mounted || _progress >= widget.target) {
        _stopHolding();
        return;
      }
      setState(() {
        _progress += 1;
      });
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }
}

class _RescueMission {
  const _RescueMission({
    required this.title,
    required this.goal,
    required this.steps,
    required this.rewardLine,
  });

  final String title;
  final String goal;
  final List<String> steps;
  final String rewardLine;
}
