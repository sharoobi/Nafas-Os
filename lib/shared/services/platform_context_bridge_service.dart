import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final platformContextBridgeServiceProvider =
    Provider<PlatformContextBridgeService>((Ref ref) {
      return const PlatformContextBridgeService();
    });

class PlatformContextBridgeService {
  const PlatformContextBridgeService();

  static const MethodChannel _channel = MethodChannel(
    'com.nafas.sharoobi/native_context',
  );

  Future<Map<String, dynamic>> getPlatformCapabilities() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getPlatformCapabilities');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getRuntimeStatus() async {
    final Map<String, dynamic> capabilities = await getPlatformCapabilities();
    final Map<String, dynamic> envelope = await getContextEnvelope();
    return <String, dynamic>{...capabilities, ...envelope};
  }

  Future<Map<String, dynamic>> getBluetoothSnapshot() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getBluetoothSnapshot');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getDeviceState() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getDeviceState');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getContextEnvelope() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getContextEnvelope');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getUsageDigest() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getUsageDigest');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> startGuardedAudioMode({
    int durationSeconds = 600,
  }) async {
    final Map<Object?, Object?>? response = await _channel.invokeMapMethod<
      Object?,
      Object?
    >(
      'startGuardedAudioMode',
      <String, Object?>{'durationSeconds': durationSeconds},
    );
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> stopGuardedAudioMode() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('stopGuardedAudioMode');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getGuardedAudioStatus() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getGuardedAudioStatus');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> schedulePersistentFollowUp({
    required String title,
    required String body,
    required int triggerAtMillis,
  }) async {
    final Map<Object?, Object?>? response = await _channel.invokeMapMethod<
      Object?,
      Object?
    >('schedulePersistentFollowUp', <String, Object?>{
      'title': title,
      'body': body,
      'triggerAtMillis': triggerAtMillis,
    });
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> cancelPersistentFollowUp() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('cancelPersistentFollowUp');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getPersistentFollowUpStatus() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getPersistentFollowUpStatus');
    return _toStringDynamicMap(response);
  }

  Future<Map<String, dynamic>> getBootResilienceStatus() async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getBootResilienceStatus');
    return _toStringDynamicMap(response);
  }

  Future<bool> openBatteryOptimizationSettings() async {
    return await _channel.invokeMethod<bool>('openBatteryOptimizationSettings') ??
        false;
  }

  Future<bool> openExactAlarmSettings() async {
    return await _channel.invokeMethod<bool>('openExactAlarmSettings') ?? false;
  }

  Future<bool> openUsageAccessSettings() async {
    return await _channel.invokeMethod<bool>('openUsageAccessSettings') ?? false;
  }

  Future<String?> exportTextToDownloads({
    required String fileName,
    required String content,
    String mimeType = 'text/plain',
  }) async {
    return await _channel.invokeMethod<String>('exportTextToDownloads', <String, Object?>{
      'fileName': fileName,
      'content': content,
      'mimeType': mimeType,
    });
  }

  Map<String, dynamic> _toStringDynamicMap(Map<Object?, Object?>? source) {
    final Map<String, dynamic> result = <String, dynamic>{};
    if (source == null) {
      return result;
    }
    for (final MapEntry<Object?, Object?> entry in source.entries) {
      final Object? key = entry.key;
      if (key is String) {
        result[key] = entry.value;
      }
    }
    return result;
  }
}
