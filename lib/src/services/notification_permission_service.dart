import 'dart:io';

import 'package:flutter/services.dart';

enum NotificationAuthorization { notDetermined, authorized, denied }

class NotificationPermissionService {
  const NotificationPermissionService();

  bool get isRequiredForSystemPlayer => Platform.isAndroid;

  static const _channel = MethodChannel('com.alpwarestudio.frekio/platform');

  Future<NotificationAuthorization> status() async {
    // iOS Now Playing/Control Center is part of the active audio session and
    // does not use the user-notification permission.
    if (!isRequiredForSystemPlayer) return NotificationAuthorization.authorized;
    try {
      final value = await _channel.invokeMethod<String>('notificationStatus');
      return _decode(value);
    } on MissingPluginException {
      return NotificationAuthorization.authorized;
    }
  }

  Future<NotificationAuthorization> request() async {
    if (!isRequiredForSystemPlayer) return NotificationAuthorization.authorized;
    try {
      final value = await _channel.invokeMethod<String>(
        'requestNotificationPermission',
      );
      return _decode(value);
    } on MissingPluginException {
      return NotificationAuthorization.authorized;
    }
  }

  Future<void> openSettings() async {
    if (!isRequiredForSystemPlayer) return;
    try {
      await _channel.invokeMethod<void>('openNotificationSettings');
    } on MissingPluginException {
      // Desktop and widget tests do not provide the mobile platform channel.
    }
  }

  NotificationAuthorization _decode(String? value) => switch (value) {
    'authorized' => NotificationAuthorization.authorized,
    'denied' => NotificationAuthorization.denied,
    _ => NotificationAuthorization.notDetermined,
  };
}
