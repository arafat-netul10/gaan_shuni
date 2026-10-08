import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../domain/services/permission_service.dart';

/// Concrete implementation of [PermissionService] using `permission_handler`.
class AppPermissionService implements PermissionService {
  @override
  Future<AppPermissionStatus> checkAudioPermission() async {
    if (kIsWeb) return AppPermissionStatus.granted;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return AppPermissionStatus.granted;
    }

    if (Platform.isIOS) {
      final status = await ph.Permission.mediaLibrary.status;
      return _mapStatus(status);
    }

    if (Platform.isAndroid) {
      // Android 13+ (API 33+) uses Permission.audio
      final audioStatus = await ph.Permission.audio.status;
      if (audioStatus.isGranted) return AppPermissionStatus.granted;

      // Fallback for Android 12 and below: Permission.storage
      final storageStatus = await ph.Permission.storage.status;
      if (storageStatus.isGranted) return AppPermissionStatus.granted;

      if (audioStatus.isPermanentlyDenied && storageStatus.isPermanentlyDenied) {
        return AppPermissionStatus.permanentlyDenied;
      }

      if (audioStatus.isRestricted || storageStatus.isRestricted) {
        return AppPermissionStatus.restricted;
      }

      return AppPermissionStatus.denied;
    }

    return AppPermissionStatus.granted;
  }

  @override
  Future<AppPermissionStatus> requestAudioPermission() async {
    if (kIsWeb) return AppPermissionStatus.granted;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return AppPermissionStatus.granted;
    }

    if (Platform.isIOS) {
      final status = await ph.Permission.mediaLibrary.request();
      return _mapStatus(status);
    }

    if (Platform.isAndroid) {
      // Request audio first (for Android 13+)
      final audioStatus = await ph.Permission.audio.request();
      if (audioStatus.isGranted) return AppPermissionStatus.granted;

      // Fallback request storage for older Android versions
      final storageStatus = await ph.Permission.storage.request();
      if (storageStatus.isGranted) return AppPermissionStatus.granted;

      if (audioStatus.isPermanentlyDenied && storageStatus.isPermanentlyDenied) {
        return AppPermissionStatus.permanentlyDenied;
      }

      if (audioStatus.isRestricted || storageStatus.isRestricted) {
        return AppPermissionStatus.restricted;
      }

      return AppPermissionStatus.denied;
    }

    return AppPermissionStatus.granted;
  }

  @override
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }

  AppPermissionStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return AppPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    } else if (status.isRestricted) {
      return AppPermissionStatus.restricted;
    } else {
      return AppPermissionStatus.denied;
    }
  }
}
