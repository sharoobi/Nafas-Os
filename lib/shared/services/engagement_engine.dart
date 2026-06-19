import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/companion_brief.dart';
import 'package:nafas_os/shared/models/companion_mission.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/models/craving_event.dart';
import 'package:nafas_os/shared/models/dashboard_summary.dart';
import 'package:nafas_os/shared/models/insights_digest.dart';
import 'package:nafas_os/shared/models/intervention_event.dart';
import 'package:nafas_os/shared/models/mission_memory.dart';
import 'package:nafas_os/shared/models/risk_assessment.dart';
import 'package:nafas_os/shared/models/smoke_event.dart';
import 'package:nafas_os/shared/models/user_profile.dart';

final engagementEngineProvider = Provider<EngagementEngine>((Ref ref) {
  return const EngagementEngine();
});

class EngagementEngine {
  const EngagementEngine();

  CompanionBrief buildCompanionBrief({
    required UserProfile profile,
    required DashboardSummary summary,
    required RiskAssessment assessment,
    required ContextSnapshot? latestContext,
  }) {
    final CompanionMode mode = switch (assessment.level) {
      RiskLevel.low when summary.resistedToday >= 2 => CompanionMode.winning,
      RiskLevel.low => CompanionMode.steady,
      RiskLevel.moderate when summary.digitalDriftScore >= 0.58 =>
        CompanionMode.drifting,
      RiskLevel.moderate => CompanionMode.pressured,
      RiskLevel.high => CompanionMode.combustible,
      RiskLevel.critical => CompanionMode.cravingWave,
    };

    final String placeLine = switch (summary.placeIdentityLabel) {
      'home_like' => 'المكان يشبه البيت',
      'work_like' => 'المكان يشبه الدوام',
      'recurring_place' => 'هذا مكان متكرر عندك',
      'new_place' => 'هذا مكان جديد نسبيًا',
      _ => 'المكان ما زال تحت الملاحظة',
    };

    final String focusLabel =
        summary.shortVideoMinutes >= 10
            ? 'نافذة ريلز'
            : summary.stationaryMinutes >= 20
            ? 'ثبات طويل'
            : summary.messagingMinutes >= 8
            ? 'ضغط مراسلات'
            : 'قراءة السياق';

    final String body = switch (profile.supportTone) {
      SupportTone.calm =>
        'هذه ليست لحظة حكم على نفسك. هي فقط نافذة قرار. $placeLine، ومعه ${_digitalLine(summary)}. خفف الاندفاع قبل أن يتحول إلى فعل.',
      SupportTone.challenger =>
        'القرين يرى النافذة قبل السيجارة: $placeLine، ${_digitalLine(summary)}. اكسرها الآن بدل أن تعيد نفس الحلقة.',
      SupportTone.balanced =>
        '$placeLine، ${_digitalLine(summary)}. لو أخذت دقيقة واعية الآن فغالبًا ستضعف الموجة بدل أن تقوى.',
    };

    final String title = switch (mode) {
      CompanionMode.steady => 'أنت مستقر نسبيًا',
      CompanionMode.drifting => 'أنت تنزلق رقميًا',
      CompanionMode.pressured => 'هناك ضغط يتشكل',
      CompanionMode.combustible => 'أنت قريب من نافذة اشتعال',
      CompanionMode.cravingWave => 'الموجة هنا الآن',
      CompanionMode.recovering => 'أنت في تعافٍ بعد سقطة',
      CompanionMode.winning => 'أنت تبني نمط نجاة',
    };

    final String vibeLine = switch (mode) {
      CompanionMode.steady => 'احتفظ بالهدوء ولا تعطِ العادة فرصة مجانية.',
      CompanionMode.drifting => 'الانجراف الرقمي وحده لا يعني سيجارة، لكنه يفتح الباب.',
      CompanionMode.pressured => 'الضغط يحتاج مقاطعة قصيرة قبل أن يطلب سيجارة.',
      CompanionMode.combustible => 'هذه لحظة تحتاج طقسًا بديلًا لا نية مجردة.',
      CompanionMode.cravingWave => 'لا تفاوض الموجة. ادخل المهمة الآن.',
      CompanionMode.recovering => 'المهم الآن وقف النزيف السلوكي لا جلد الذات.',
      CompanionMode.winning => 'كل نجاة متكررة تعيد تعريف هذا السياق في دماغك.',
    };

    return CompanionBrief(
      mode: mode,
      title: title,
      body: body,
      focusLabel: focusLabel,
      vibeLine: vibeLine,
    );
  }

  List<CompanionMission> buildMissions({
    required UserProfile profile,
    required DashboardSummary summary,
    required RiskAssessment assessment,
    required ContextSnapshot? latestContext,
    required List<MissionMemory> missionMemories,
  }) {
    final List<CompanionMission> missions = <CompanionMission>[];
    final Map<String, MissionMemory> memoryById = <String, MissionMemory>{
      for (final MissionMemory memory in missionMemories) memory.missionId: memory,
    };

    if (summary.shortVideoMinutes >= 10 || summary.digitalDriftScore >= 0.58) {
      final MissionMemory? memory = memoryById['reels_interrupt'];
      missions.add(
        CompanionMission(
          id: 'reels_interrupt',
          title: 'اكسر نافذة الريلز',
          subtitle:
              'حوّل آخر دقيقة من التصفح إلى مهمة قصيرة بدل الانتقال التلقائي إلى التدخين.',
          rewardLine: 'إذا كسرت الريلز قبل السيجارة فأنت تكسر أهم تسلسل لا التطبيق فقط.',
          progress: _missionProgress(memory, fallback: summary.resistedToday, target: 3),
          target: 3,
          interventionType: InterventionType.walk,
          interactionMode: MissionInteractionMode.tapSequence,
        ),
      );
    }

    if ((latestContext?.driveCandidate ?? false) ||
        (latestContext?.carAudioRouteActive ?? false)) {
      final MissionMemory? memory = memoryById['drive_shield'];
      missions.add(
        CompanionMission(
          id: 'drive_shield',
          title: 'درع القيادة',
          subtitle:
              'ثبّت نفسك خلال أول دقيقتين من القيادة أو الانتظار بدل استدعاء السيجارة.',
          rewardLine: 'القيادة تصبح أقل خطرًا حين تربطها بتنفس أو مهمة حسية بدل السيجارة.',
          progress: _missionProgress(
            memory,
            fallback: summary.successfulInterventionsToday,
            target: 2,
          ),
          target: 2,
          interventionType: InterventionType.driveShield,
          interactionMode: MissionInteractionMode.holdShield,
        ),
      );
    }

    if (summary.stationaryMinutes >= 18 || profile.boredomSensitivity >= 0.7) {
      final MissionMemory? memory = memoryById['stand_and_shift'];
      missions.add(
        CompanionMission(
          id: 'stand_and_shift',
          title: 'حرك جسدك قبل القرار',
          subtitle:
              'الثبات الطويل عندك يرفع الخطر. اقطع السكون بمهمة دقيقة واحدة.',
          rewardLine: 'كل مقاطعة جسدية قصيرة تقلل الارتباط بين الوقفة والسيجارة.',
          progress: _missionProgress(
            memory,
            fallback: summary.manualCheckInsToday,
            target: 3,
          ),
          target: 3,
          interventionType: InterventionType.breathing,
          interactionMode: MissionInteractionMode.breathCycle,
        ),
      );
    }

    if (summary.latestTriggerTag == 'stress' ||
        profile.workStressSensitivity >= 0.7) {
      final MissionMemory? memory = memoryById['stress_reframe'];
      missions.add(
        CompanionMission(
          id: 'stress_reframe',
          title: 'سمِّ الضغط قبل أن يقودك',
          subtitle:
              'خذ 45 ثانية لإعادة تسمية المحفز بدل إعطائه شكل سيجارة.',
          rewardLine: 'حين تسمي المحفز تفقد العادة جزءًا من سلطتها الفورية.',
          progress: _missionProgress(
            memory,
            fallback: summary.successfulInterventionsToday,
            target: 4,
          ),
          target: 4,
          interventionType: InterventionType.microCbt,
          interactionMode: MissionInteractionMode.tapSequence,
        ),
      );
    }

    if (missions.isEmpty) {
      final MissionMemory? memory = memoryById['default_wave'];
      missions.add(
        CompanionMission(
          id: 'default_wave',
          title: 'مهمة نجاة الدقيقتين',
          subtitle:
              'خذ دقيقتين واعيتين الآن لتعليم دماغك أن الراحة لا تعني سيجارة.',
          rewardLine: 'النجاة القصيرة المتكررة أهم من الوعود الكبيرة غير المستقرة.',
          progress: _missionProgress(memory, fallback: summary.resistedToday, target: 2),
          target: 2,
          interventionType: profile.preferredRescue,
          interactionMode: MissionInteractionMode.tapSequence,
        ),
      );
    }

    missions.sort((CompanionMission a, CompanionMission b) {
      final MissionMemory? aMemory = memoryById[a.id];
      final MissionMemory? bMemory = memoryById[b.id];
      final double aScore = aMemory?.momentumScore ?? 0.0;
      final double bScore = bMemory?.momentumScore ?? 0.0;
      return bScore.compareTo(aScore);
    });

    return missions.take(3).toList();
  }

  int _missionProgress(
    MissionMemory? memory, {
    required int fallback,
    required int target,
  }) {
    if (memory == null) {
      return fallback.clamp(0, target);
    }
    return memory.currentStreak.clamp(0, target);
  }

  InsightsDigest buildInsightsDigest({
    required List<SmokeEvent> smokeEvents,
    required List<CravingEvent> cravingEvents,
    required List<InterventionEvent> interventionEvents,
    required List<ContextSnapshot> contextSnapshots,
    required DashboardSummary summary,
  }) {
    final DateTime now = DateTime.now();
    final InsightWindowSummary today = _windowSummary(
      label: 'اليوم',
      smokeEvents: smokeEvents.where((SmokeEvent event) {
        return event.occurredAt.isAfter(DateTime(now.year, now.month, now.day));
      }).toList(),
      cravingEvents: cravingEvents.where((CravingEvent event) {
        return event.occurredAt.isAfter(DateTime(now.year, now.month, now.day));
      }).toList(),
      interventionEvents: interventionEvents.where((InterventionEvent event) {
        return event.occurredAt.isAfter(DateTime(now.year, now.month, now.day));
      }).toList(),
    );
    final InsightWindowSummary week = _windowSummary(
      label: '7 أيام',
      smokeEvents: smokeEvents.where(
        (SmokeEvent event) =>
            event.occurredAt.isAfter(now.subtract(const Duration(days: 7))),
      ).toList(),
      cravingEvents: cravingEvents.where(
        (CravingEvent event) =>
            event.occurredAt.isAfter(now.subtract(const Duration(days: 7))),
      ).toList(),
      interventionEvents: interventionEvents.where(
        (InterventionEvent event) =>
            event.occurredAt.isAfter(now.subtract(const Duration(days: 7))),
      ).toList(),
    );
    final InsightWindowSummary month = _windowSummary(
      label: '30 يومًا',
      smokeEvents: smokeEvents,
      cravingEvents: cravingEvents,
      interventionEvents: interventionEvents,
    );

    final List<BehaviorHypothesis> hypotheses = <BehaviorHypothesis>[
      _buildStressHypothesis(cravingEvents),
      _buildMealHypothesis(cravingEvents),
      _buildDigitalHypothesis(summary),
      _buildPlaceHypothesis(contextSnapshots, summary),
    ];

    return InsightsDigest(
      today: today,
      week: week,
      month: month,
      hypotheses: hypotheses,
    );
  }

  InsightWindowSummary _windowSummary({
    required String label,
    required List<SmokeEvent> smokeEvents,
    required List<CravingEvent> cravingEvents,
    required List<InterventionEvent> interventionEvents,
  }) {
    final int smokeCount = smokeEvents.fold<int>(
      0,
      (int total, SmokeEvent event) => total + event.cigarettesCount,
    );
    final int rescueCount = interventionEvents.length;
    final int rescueWins = interventionEvents.where((InterventionEvent event) {
      return event.successful;
    }).length;
    final int resistedCount = cravingEvents.where((CravingEvent event) {
      return event.resolvedWithoutSmoking;
    }).length;
    final double avgIntensity =
        cravingEvents.isEmpty
            ? 0
            : cravingEvents.fold<double>(
                  0,
                  (double total, CravingEvent event) =>
                      total + event.intensity.toDouble(),
                ) /
                cravingEvents.length;
    final Map<String, int> triggerCounts = <String, int>{};
    for (final CravingEvent event in cravingEvents) {
      final String key = event.triggerTag;
      if (key == 'ambient' || key == 'rescue_success' || key == 'unspecified') {
        continue;
      }
      triggerCounts.update(key, (int value) => value + 1, ifAbsent: () => 1);
    }
    final String topTrigger =
        triggerCounts.entries.isEmpty
            ? 'لا يوجد محفز مهيمن بعد'
            : _triggerLabel(
              triggerCounts.entries.reduce(
                (MapEntry<String, int> a, MapEntry<String, int> b) =>
                    a.value >= b.value ? a : b,
              ).key,
            );

    final int? firstSmokeDelayMinutes =
        smokeEvents.isEmpty
            ? null
            : smokeEvents
                .map((SmokeEvent event) => event.occurredAt)
                .reduce(
                  (DateTime a, DateTime b) => a.isBefore(b) ? a : b,
                )
                .difference(
                  DateTime(
                    smokeEvents.first.occurredAt.year,
                    smokeEvents.first.occurredAt.month,
                    smokeEvents.first.occurredAt.day,
                  ),
                )
                .inMinutes;

    return InsightWindowSummary(
      label: label,
      smokeCount: smokeCount,
      cravingCount: cravingEvents.length,
      rescueCount: rescueCount,
      rescueWinRate: rescueCount == 0 ? 0 : rescueWins / rescueCount,
      resistedCount: resistedCount,
      averageCravingIntensity: avgIntensity,
      topTrigger: topTrigger,
      firstSmokeDelayMinutes: firstSmokeDelayMinutes,
    );
  }

  BehaviorHypothesis _buildStressHypothesis(List<CravingEvent> cravings) {
    final int count = cravings.where((CravingEvent event) {
      return event.triggerTag == 'stress';
    }).length;
    if (count >= 4) {
      return const BehaviorHypothesis(
        title: 'الضغط يسبق الموجة',
        detail: 'تكررت إشارات الضغط أكثر من مرة وأصبحت فرضية قوية تحتاج طقس نجاة ثابت.',
        status: 'مؤكدة',
      );
    }
    if (count >= 2) {
      return const BehaviorHypothesis(
        title: 'الضغط تحت الملاحظة',
        detail: 'ظهر الضغط أكثر من مرة لكنه ما زال يحتاج مزيدًا من الأيام للتثبيت.',
        status: 'مرجحة',
      );
    }
    return const BehaviorHypothesis(
      title: 'الضغط ليس المحفز الأول بعد',
      detail: 'حتى الآن لا يظهر الضغط وحده كأقوى سائق ثابت للرغبة.',
      status: 'ضعيفة',
    );
  }

  BehaviorHypothesis _buildMealHypothesis(List<CravingEvent> cravings) {
    final int count = cravings.where((CravingEvent event) {
      return event.triggerTag == 'coffee' || event.triggerTag == 'after_meal';
    }).length;
    if (count >= 3) {
      return const BehaviorHypothesis(
        title: 'القهوة وما بعد الأكل نافذة حساسة',
        detail: 'الطقس بعد الأكل أو القهوة يرتبط بالرغبة بشكل متكرر. برنامج الطقس البديل مناسب هنا.',
        status: 'مؤكدة',
      );
    }
    return const BehaviorHypothesis(
      title: 'طقس ما بعد الأكل تحت الاختبار',
      detail: 'لا توجد أدلة كافية بعد، لكن هذا السياق يستحق المراقبة.',
      status: 'تحت الملاحظة',
    );
  }

  BehaviorHypothesis _buildDigitalHypothesis(DashboardSummary summary) {
    if (summary.shortVideoMinutes >= 12 && summary.appSwitchesLast30m >= 6) {
      return const BehaviorHypothesis(
        title: 'الانجراف الرقمي يرفع الخطر',
        detail: 'جلسة فيديو قصير طويلة مع تنقل سريع بين التطبيقات تبدو نافذة قرار خطرة.',
        status: 'مرجحة',
      );
    }
    if (summary.digitalDriftScore >= 0.62) {
      return const BehaviorHypothesis(
        title: 'السياق الرقمي ساخن',
        detail: 'ليس التطبيق وحده، بل السكون معه، ما يجعل الرغبة أقرب.',
        status: 'تحت الملاحظة',
      );
    }
    return const BehaviorHypothesis(
      title: 'السياق الرقمي هادئ نسبيًا',
      detail: 'لا توجد إشارات قوية حاليًا أن استخدام الجوال هو السائق الأول للرغبة.',
      status: 'ضعيفة',
    );
  }

  BehaviorHypothesis _buildPlaceHypothesis(
    List<ContextSnapshot> snapshots,
    DashboardSummary summary,
  ) {
    final int recurringCount = snapshots.where((ContextSnapshot snapshot) {
      return snapshot.locationClusterId != null &&
          snapshot.locationClusterId!.isNotEmpty;
    }).length;
    if (summary.placeIdentityLabel == 'work_like' && recurringCount >= 8) {
      return const BehaviorHypothesis(
        title: 'مكان العمل يحمل أثرًا سلوكيًا',
        detail: 'المكان يتكرر كثيرًا ويبدو أنه جزء من نافذة القرار اليومية.',
        status: 'مرجحة',
      );
    }
    if (summary.placeIdentityLabel == 'home_like' && recurringCount >= 8) {
      return const BehaviorHypothesis(
        title: 'البيت ليس محايدًا',
        detail: 'هناك مكان منزلي متكرر يجب إعادة تعريفه بسلوك نجاة جديد.',
        status: 'مرجحة',
      );
    }
    return const BehaviorHypothesis(
      title: 'المكان ما زال تحت التعلم',
      detail: 'القرين يجمع الآن هوية الأماكن قبل أن يحكم عليها كمحفزات.',
      status: 'تحت الملاحظة',
    );
  }

  String _digitalLine(DashboardSummary summary) {
    final List<String> cues = <String>[];
    if (summary.shortVideoMinutes >= 10) {
      cues.add('هناك جلسة ريلز طويلة');
    }
    if (summary.appSwitchesLast30m >= 6) {
      cues.add('والتنقل بين التطبيقات متوتر');
    }
    if (summary.stationaryMinutes >= 18) {
      cues.add('والجسد ثابت منذ فترة');
    }
    if (cues.isEmpty) {
      return 'السياق الرقمي هادئ نسبيًا';
    }
    return cues.join(' ');
  }

  String _triggerLabel(String raw) {
    return switch (raw) {
      'coffee' => 'القهوة',
      'stress' => 'الضغط',
      'after_meal' => 'ما بعد الأكل',
      'driving' => 'القيادة',
      'social' => 'السياق الاجتماعي',
      'boredom' => 'الملل',
      'wake_up' => 'بعد الاستيقاظ',
      _ => raw.replaceAll('_', ' '),
    };
  }
}
