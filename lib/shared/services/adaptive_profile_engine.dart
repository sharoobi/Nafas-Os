import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/models/craving_event.dart';
import 'package:nafas_os/shared/models/intervention_event.dart';
import 'package:nafas_os/shared/models/smoke_event.dart';
import 'package:nafas_os/shared/models/user_profile.dart';

final adaptiveProfileEngineProvider = Provider<AdaptiveProfileEngine>((Ref ref) {
  return const AdaptiveProfileEngine();
});

class AdaptiveProfileEngine {
  const AdaptiveProfileEngine();

  UserProfile adapt({
    required UserProfile profile,
    required List<SmokeEvent> smokeEvents,
    required List<CravingEvent> cravingEvents,
    required List<InterventionEvent> interventionEvents,
    required List<ContextSnapshot> contextSnapshots,
  }) {
    final int evidenceCount =
        smokeEvents.length +
        cravingEvents.length +
        interventionEvents.length +
        contextSnapshots.length;
    if (evidenceCount < 12) {
      return profile.copyWith(
        adaptationConfidence: (evidenceCount / 24).clamp(0.0, 0.45),
      );
    }

    final int stressSignals = cravingEvents
        .where((CravingEvent event) => event.triggerTag == 'stress')
        .length;
    final int boredomSignals = cravingEvents
        .where((CravingEvent event) => event.triggerTag == 'boredom')
        .length;
    final int driveSignals = cravingEvents
        .where((CravingEvent event) => event.triggerTag == 'driving')
        .length;

    final int shortVideoHeavyContexts = contextSnapshots
        .where((ContextSnapshot snapshot) => snapshot.shortVideoMinutes >= 10)
        .length;
    final int digitalDriftHeavyContexts = contextSnapshots
        .where((ContextSnapshot snapshot) => snapshot.digitalDriftScore >= 0.62)
        .length;
    final int stillContexts = contextSnapshots
        .where(
          (ContextSnapshot snapshot) =>
              snapshot.activityContext.name == 'still' &&
              snapshot.speedKph < 1.5,
        )
        .length;
    final int driveContexts = contextSnapshots
        .where(
          (ContextSnapshot snapshot) =>
              snapshot.driveCandidate || snapshot.carAudioRouteActive,
        )
        .length;

    final double reelsBias = _normalizedBias(
      numerator: shortVideoHeavyContexts + digitalDriftHeavyContexts,
      denominator: contextSnapshots.length * 2,
      maxBias: 0.24,
    );
    final double stressBias = _normalizedBias(
      numerator: stressSignals,
      denominator: cravingEvents.length,
      maxBias: 0.22,
    );
    final double boredomBias = _normalizedBias(
      numerator: boredomSignals + stillContexts,
      denominator: cravingEvents.length + contextSnapshots.length,
      maxBias: 0.20,
    );
    final double driveBias = _normalizedBias(
      numerator: driveSignals + driveContexts,
      denominator: cravingEvents.length + contextSnapshots.length,
      maxBias: 0.24,
    );
    final double confidence = (evidenceCount / 80).clamp(0.0, 1.0);

    return profile.copyWith(
      adaptiveReelsBias: reelsBias,
      adaptiveStressBias: stressBias,
      adaptiveBoredomBias: boredomBias,
      adaptiveDriveBias: driveBias,
      adaptationConfidence: confidence,
      lastAdaptedAt: DateTime.now(),
    );
  }

  double _normalizedBias({
    required int numerator,
    required int denominator,
    required double maxBias,
  }) {
    if (denominator <= 0) {
      return 0.0;
    }
    return ((numerator / denominator) * maxBias).clamp(0.0, maxBias);
  }
}
