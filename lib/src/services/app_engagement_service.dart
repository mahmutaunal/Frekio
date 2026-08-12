import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/preferences_store.dart';

class AppVersionInfo {
  const AppVersionInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  String get display => '$version ($buildNumber)';
}

enum UpdateStatus { available, upToDate, unavailable }

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.status,
    this.availableVersion,
    this.storeUri,
  });

  final UpdateStatus status;
  final String? availableVersion;
  final Uri? storeUri;
}

class AppEngagementService {
  AppEngagementService(this._preferences);

  final PreferencesStore _preferences;
  final InAppReview _review = InAppReview.instance;

  PackageInfo? _packageInfo;
  AppUpdateInfo? _androidUpdate;
  UpdateCheckResult? _lastUpdate;

  Future<AppVersionInfo> versionInfo() async {
    final info = _packageInfo ??= await PackageInfo.fromPlatform();
    return AppVersionInfo(version: info.version, buildNumber: info.buildNumber);
  }

  Future<bool> requestNativeReview() async {
    try {
      if (!await _review.isAvailable()) return false;
      await _review.requestReview();
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> recordMeaningfulPlayback() async {
    final count = await _preferences.incrementMeaningfulPlaybackCount();
    final info = _packageInfo ??= await PackageInfo.fromPlatform();
    final installedAt = _preferences.installedAt;
    final enoughExperience =
        count >= 5 &&
        installedAt != null &&
        DateTime.now().difference(installedAt) >= const Duration(days: 3);
    if (!enoughExperience ||
        _preferences.reviewRequestedVersion == info.version) {
      return;
    }

    // Mark before invoking StoreKit/Play because the operating system may
    // intentionally decide not to display its quota-controlled prompt.
    await _preferences.setReviewRequestedVersion(info.version);
    await requestNativeReview();
  }

  Future<UpdateCheckResult> checkForUpdate() async {
    if (Platform.isAndroid) return _checkAndroidUpdate();
    if (Platform.isIOS) return _checkIosUpdate();
    return const UpdateCheckResult(status: UpdateStatus.unavailable);
  }

  Future<UpdateCheckResult> _checkAndroidUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      _androidUpdate = info;
      final available =
          info.updateAvailability == UpdateAvailability.updateAvailable ||
          info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;
      return _lastUpdate = UpdateCheckResult(
        status: available ? UpdateStatus.available : UpdateStatus.upToDate,
        availableVersion: info.availableVersionCode?.toString(),
      );
    } on PlatformException {
      // Play Core is intentionally unavailable for sideloaded/debug builds.
      return const UpdateCheckResult(status: UpdateStatus.unavailable);
    }
  }

  Future<UpdateCheckResult> _checkIosUpdate() async {
    final info = _packageInfo ??= await PackageInfo.fromPlatform();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final uri = Uri.https('itunes.apple.com', '/lookup', {
        'bundleId': info.packageName,
        'country': 'tr',
      });
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Frekio/${info.version}',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != HttpStatus.ok) {
        return const UpdateCheckResult(status: UpdateStatus.unavailable);
      }
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return const UpdateCheckResult(status: UpdateStatus.unavailable);
      }
      final product = results.first as Map<String, dynamic>;
      final storeVersion = product['version'] as String?;
      final storeUrl = Uri.tryParse(product['trackViewUrl'] as String? ?? '');
      if (storeVersion == null) {
        return const UpdateCheckResult(status: UpdateStatus.unavailable);
      }
      return _lastUpdate = UpdateCheckResult(
        status: isNewerVersion(storeVersion, info.version)
            ? UpdateStatus.available
            : UpdateStatus.upToDate,
        availableVersion: storeVersion,
        storeUri: storeUrl,
      );
    } on Object {
      return const UpdateCheckResult(status: UpdateStatus.unavailable);
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> installAvailableUpdate() async {
    if (Platform.isAndroid) {
      final info = _androidUpdate;
      if (info == null) return false;
      try {
        if (info.flexibleUpdateAllowed) {
          final result = await InAppUpdate.startFlexibleUpdate();
          if (result != AppUpdateResult.success) return false;
          await InAppUpdate.completeFlexibleUpdate();
          return true;
        }
        if (info.immediateUpdateAllowed) {
          return await InAppUpdate.performImmediateUpdate() ==
              AppUpdateResult.success;
        }
      } on PlatformException {
        return false;
      }
      return false;
    }

    final uri = _lastUpdate?.storeUri;
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

bool isNewerVersion(String candidate, String current) {
  List<int> parts(String value) => value
      .split(RegExp(r'[.+-]'))
      .take(4)
      .map((part) => int.tryParse(part) ?? 0)
      .toList(growable: true);

  final left = parts(candidate);
  final right = parts(current);
  final length = left.length > right.length ? left.length : right.length;
  for (var index = 0; index < length; index++) {
    final a = index < left.length ? left[index] : 0;
    final b = index < right.length ? right[index] : 0;
    if (a != b) return a > b;
  }
  return false;
}
