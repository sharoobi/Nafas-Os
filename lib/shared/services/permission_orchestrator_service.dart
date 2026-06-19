import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/models/permission_matrix.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionOrchestratorServiceProvider =
    Provider<PermissionOrchestratorService>((Ref ref) {
      return const PermissionOrchestratorService();
    });

class PermissionOrchestratorService {
  const PermissionOrchestratorService();

  Future<PermissionMatrix> snapshot() async {
    return PermissionMatrix(
      notifications: await Permission.notification.isGranted,
      location:
          await Permission.location.isGranted ||
          await Permission.locationWhenInUse.isGranted,
      activityRecognition: await Permission.activityRecognition.isGranted,
      bluetooth: await _bluetoothGranted(),
      microphone: await Permission.microphone.isGranted,
      camera: await Permission.camera.isGranted,
    );
  }

  Future<PermissionMatrix> requestAllRelevantPermissions() async {
    await Permission.notification.request();
    await Permission.locationWhenInUse.request();
    await Permission.activityRecognition.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.microphone.request();
    await Permission.camera.request();

    return snapshot();
  }

  Future<PermissionMatrix> requestMicrophonePermission() async {
    await Permission.microphone.request();
    return snapshot();
  }

  Future<bool> _bluetoothGranted() async {
    final bool connect = await Permission.bluetoothConnect.isGranted;
    final bool scan = await Permission.bluetoothScan.isGranted;
    final bool legacy = await Permission.bluetooth.isGranted;
    return connect || scan || legacy;
  }
}
