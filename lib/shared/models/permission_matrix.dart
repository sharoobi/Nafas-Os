class PermissionMatrix {
  const PermissionMatrix({
    required this.notifications,
    required this.location,
    required this.activityRecognition,
    required this.bluetooth,
    required this.microphone,
    required this.camera,
  });

  final bool notifications;
  final bool location;
  final bool activityRecognition;
  final bool bluetooth;
  final bool microphone;
  final bool camera;
}
