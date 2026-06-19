import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/services/platform_context_bridge_service.dart';

final contextSamplingServiceProvider = Provider<ContextSamplingService>((
  Ref ref,
) {
  return ContextSamplingService(ref.read(platformContextBridgeServiceProvider));
});

class ContextSamplingService {
  ContextSamplingService(this._platformBridgeService);

  final PlatformContextBridgeService _platformBridgeService;
  Position? _cachedPosition;
  DateTime? _cachedPositionAt;

  Future<ContextSnapshot> capture() async {
    final DateTime now = DateTime.now();
    final Position? position = await _resolvePosition(now);

    Map<String, dynamic> envelope = <String, dynamic>{};

    try {
      envelope = await _platformBridgeService.getContextEnvelope();
    } catch (_) {
      envelope = <String, dynamic>{};
    }

    final double speedKph = max(0, (position?.speed ?? 0) * 3.6);
    final bool coffeeWindow =
        (now.hour >= 7 && now.hour <= 10) || (now.hour >= 15 && now.hour <= 19);
    final String nativeActivity =
        (envelope['lastActivity'] as String?)?.trim().toLowerCase() ??
        'unknown';
    final double activityConfidence =
        (envelope['activityConfidence'] as num?)?.toDouble() ?? 0;
    final double vehicleContextScore =
        (envelope['vehicleContextScore'] as num?)?.toDouble() ?? 0;
    final bool usageAccessGranted =
        (envelope['usageAccessGranted'] as bool?) ?? false;
    final String dominantAppPackage =
        (envelope['dominantAppPackage'] as String?) ?? '';
    final int dominantAppMinutes =
        (envelope['dominantAppMinutes'] as int?) ?? 0;
    final int socialMediaMinutes =
        (envelope['socialMediaMinutes'] as int?) ?? 0;
    final int shortVideoMinutes =
        (envelope['shortVideoMinutes'] as int?) ?? 0;
    final int messagingMinutes =
        (envelope['messagingMinutes'] as int?) ?? 0;
    final int appSwitchesLast30m =
        (envelope['appSwitchesLast30m'] as int?) ?? 0;
    final double digitalDriftScore =
        (envelope['digitalDriftScore'] as num?)?.toDouble() ?? 0;
    final bool driveCandidate =
        vehicleContextScore >= 0.55 ||
        speedKph >= 18 ||
        ((envelope['bluetoothAudioConnected'] as bool?) ?? false) ||
        ((envelope['musicActive'] as bool?) ?? false);

    return ContextSnapshot(
      id: 0,
      capturedAt: now,
      locationClusterId: _buildLocationCluster(position),
      latitude: position?.latitude,
      longitude: position?.longitude,
      speedKph: speedKph,
      activityContext: _deriveActivity(
        speedKph: speedKph,
        driveCandidate: driveCandidate,
        nativeActivity: nativeActivity,
        activityConfidence: activityConfidence,
      ),
      bluetoothEnabled: (envelope['bluetoothEnabled'] as bool?) ?? false,
      bluetoothBondedCount: (envelope['bondedCount'] as int?) ?? 0,
      bluetoothAudioConnected:
          (envelope['bluetoothAudioConnected'] as bool?) ?? false,
      a2dpConnected: (envelope['a2dpConnected'] as bool?) ?? false,
      headsetProfileConnected: (envelope['headsetConnected'] as bool?) ?? false,
      carAudioRouteActive: (envelope['carAudioRouteActive'] as bool?) ?? false,
      wiredAudioRouteActive:
          (envelope['wiredAudioRouteActive'] as bool?) ?? false,
      audioRouteKind: (envelope['audioRouteKind'] as String?) ?? 'unknown',
      vehicleContextScore: vehicleContextScore,
      musicActive: (envelope['musicActive'] as bool?) ?? false,
      screenInteractive: (envelope['interactive'] as bool?) ?? true,
      powerSaveMode: (envelope['powerSaveMode'] as bool?) ?? false,
      charging: (envelope['charging'] as bool?) ?? false,
      coffeeWindow: coffeeWindow,
      driveCandidate: driveCandidate,
      activityConfidence: activityConfidence,
      activitySource: activityConfidence >= 0.55
          ? 'native_transition'
          : 'heuristic',
      usageAccessGranted: usageAccessGranted,
      dominantAppPackage: dominantAppPackage,
      dominantAppMinutes: dominantAppMinutes,
      shortVideoMinutes: shortVideoMinutes,
      socialMediaMinutes: socialMediaMinutes,
      messagingMinutes: messagingMinutes,
      appSwitchesLast30m: appSwitchesLast30m,
      digitalDriftScore: digitalDriftScore,
    );
  }

  Future<Position?> _resolvePosition(DateTime now) async {
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled ||
          (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always)) {
        return _cachedPosition;
      }

      final DateTime? cachedAt = _cachedPositionAt;
      if (_cachedPosition != null &&
          cachedAt != null &&
          now.difference(cachedAt) < const Duration(minutes: 3)) {
        return _cachedPosition;
      }

      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _cachedPosition = lastKnown;
        _cachedPositionAt = now;
      }

      if (_cachedPosition != null &&
          cachedAt != null &&
          now.difference(cachedAt) < const Duration(minutes: 8)) {
        return _cachedPosition;
      }

      final Position fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 3),
        ),
      );
      _cachedPosition = fresh;
      _cachedPositionAt = now;
      return fresh;
    } catch (_) {
      return _cachedPosition;
    }
  }

  ActivityContext _deriveActivity({
    required double speedKph,
    required bool driveCandidate,
    required String nativeActivity,
    required double activityConfidence,
  }) {
    if (activityConfidence >= 0.55) {
      switch (nativeActivity) {
        case 'driving':
          return ActivityContext.driving;
        case 'walking':
          return ActivityContext.walking;
        case 'still':
          return ActivityContext.still;
      }
    }
    if (driveCandidate) {
      return ActivityContext.driving;
    }
    if (speedKph >= 2) {
      return ActivityContext.walking;
    }
    return ActivityContext.still;
  }

  String? _buildLocationCluster(Position? position) {
    if (position == null) {
      return null;
    }
    final double lat = (position.latitude * 100).round() / 100;
    final double lon = (position.longitude * 100).round() / 100;
    return '$lat:$lon';
  }
}
