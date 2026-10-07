/// Cross-platform abstraction of audio/storage permission status.
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// Abstract contract for checking and requesting device permissions.
abstract class PermissionService {
  /// Checks whether audio/storage permissions are currently granted.
  Future<AppPermissionStatus> checkAudioPermission();

  /// Requests the appropriate audio/storage permissions from the user.
  Future<AppPermissionStatus> requestAudioPermission();

  /// Opens the device settings page for the app if permission was permanently denied.
  Future<bool> openAppSettings();
}
