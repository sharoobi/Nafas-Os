import 'package:nafas_os/shared/models/app_enums.dart';

class ContextSnapshot {
  const ContextSnapshot({
    required this.id,
    required this.capturedAt,
    required this.locationClusterId,
    required this.latitude,
    required this.longitude,
    required this.speedKph,
    required this.activityContext,
    required this.bluetoothEnabled,
    required this.bluetoothBondedCount,
    required this.bluetoothAudioConnected,
    required this.a2dpConnected,
    required this.headsetProfileConnected,
    required this.carAudioRouteActive,
    required this.wiredAudioRouteActive,
    required this.audioRouteKind,
    required this.vehicleContextScore,
    required this.musicActive,
    required this.screenInteractive,
    required this.powerSaveMode,
    required this.charging,
    required this.coffeeWindow,
    required this.driveCandidate,
    required this.activityConfidence,
    required this.activitySource,
    required this.usageAccessGranted,
    required this.dominantAppPackage,
    required this.dominantAppMinutes,
    required this.shortVideoMinutes,
    required this.socialMediaMinutes,
    required this.messagingMinutes,
    required this.appSwitchesLast30m,
    required this.digitalDriftScore,
  });

  final int id;
  final DateTime capturedAt;
  final String? locationClusterId;
  final double? latitude;
  final double? longitude;
  final double speedKph;
  final ActivityContext activityContext;
  final bool bluetoothEnabled;
  final int bluetoothBondedCount;
  final bool bluetoothAudioConnected;
  final bool a2dpConnected;
  final bool headsetProfileConnected;
  final bool carAudioRouteActive;
  final bool wiredAudioRouteActive;
  final String audioRouteKind;
  final double vehicleContextScore;
  final bool musicActive;
  final bool screenInteractive;
  final bool powerSaveMode;
  final bool charging;
  final bool coffeeWindow;
  final bool driveCandidate;
  final double activityConfidence;
  final String activitySource;
  final bool usageAccessGranted;
  final String dominantAppPackage;
  final int dominantAppMinutes;
  final int shortVideoMinutes;
  final int socialMediaMinutes;
  final int messagingMinutes;
  final int appSwitchesLast30m;
  final double digitalDriftScore;
}
