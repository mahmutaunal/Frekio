package com.alpwarestudio.frekio;

import android.Manifest;
import android.app.NotificationManager;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import com.ryanheise.audioservice.AudioServiceActivity;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public final class MainActivity extends AudioServiceActivity {
  private static final String CHANNEL = "com.alpwarestudio.frekio/widget";
  private static final String PLATFORM_CHANNEL = "com.alpwarestudio.frekio/platform";
  private static final int NOTIFICATION_PERMISSION_REQUEST = 2401;
  private static final String PERMISSION_PREFERENCES = "frekio_permissions";
  private static final String NOTIFICATION_REQUESTED = "notification_requested";
  private MethodChannel.Result pendingNotificationResult;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler((call, result) -> {
          if (!"update".equals(call.method)) {
            result.notImplemented();
            return;
          }
          final String stationName = call.argument("stationName");
          final String detail = call.argument("detail");
          final String artworkUrl = call.argument("artworkUrl");
          final Boolean playing = call.argument("isPlaying");
          final SharedPreferences preferences =
              getSharedPreferences(FrekioWidgetProvider.WIDGET_PREFERENCES, Context.MODE_PRIVATE);
          preferences.edit()
              .putString("stationName", stationName == null ? "Frekio" : stationName)
              .putString("detail", detail == null ? "" : detail)
              .putString("artworkUrl", artworkUrl == null ? "" : artworkUrl)
              .putBoolean("isPlaying", Boolean.TRUE.equals(playing))
              .apply();

          final Intent update = new Intent(this, FrekioWidgetProvider.class);
          update.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
          final AppWidgetManager manager = AppWidgetManager.getInstance(this);
          update.putExtra(
              AppWidgetManager.EXTRA_APPWIDGET_IDS,
              manager.getAppWidgetIds(new ComponentName(this, FrekioWidgetProvider.class)));
          sendBroadcast(update);
          result.success(null);
        });

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PLATFORM_CHANNEL)
        .setMethodCallHandler((call, result) -> {
          switch (call.method) {
            case "notificationStatus":
              result.success(notificationStatus());
              break;
            case "requestNotificationPermission":
              requestNotificationPermission(result);
              break;
            case "openNotificationSettings":
              openNotificationSettings();
              result.success(null);
              break;
            default:
              result.notImplemented();
          }
        });
  }

  private String notificationStatus() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
          == PackageManager.PERMISSION_GRANTED) {
        return "authorized";
      }
      final boolean requested = getSharedPreferences(PERMISSION_PREFERENCES, MODE_PRIVATE)
          .getBoolean(NOTIFICATION_REQUESTED, false);
      return requested ? "denied" : "notDetermined";
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      final NotificationManager manager = getSystemService(NotificationManager.class);
      return manager != null && manager.areNotificationsEnabled() ? "authorized" : "denied";
    }
    return "authorized";
  }

  private void requestNotificationPermission(MethodChannel.Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
      result.success(notificationStatus());
      return;
    }
    if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
        == PackageManager.PERMISSION_GRANTED) {
      result.success("authorized");
      return;
    }
    if (pendingNotificationResult != null) {
      result.error("REQUEST_IN_PROGRESS", "A notification permission request is active.", null);
      return;
    }
    pendingNotificationResult = result;
    getSharedPreferences(PERMISSION_PREFERENCES, MODE_PRIVATE)
        .edit()
        .putBoolean(NOTIFICATION_REQUESTED, true)
        .apply();
    requestPermissions(
        new String[] {Manifest.permission.POST_NOTIFICATIONS},
        NOTIFICATION_PERMISSION_REQUEST);
  }

  private void openNotificationSettings() {
    final Intent intent = new Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
        .putExtra(Settings.EXTRA_APP_PACKAGE, getPackageName());
    if (intent.resolveActivity(getPackageManager()) == null) {
      intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
          .setData(Uri.parse("package:" + getPackageName()));
    }
    startActivity(intent);
  }

  @Override
  public void onRequestPermissionsResult(
      int requestCode,
      @NonNull String[] permissions,
      @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    if (requestCode != NOTIFICATION_PERMISSION_REQUEST || pendingNotificationResult == null) {
      return;
    }
    final MethodChannel.Result result = pendingNotificationResult;
    pendingNotificationResult = null;
    result.success(
        grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED
            ? "authorized"
            : "denied");
  }
}
