package com.alpwarestudio.frekio;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import com.ryanheise.audioservice.AudioServiceActivity;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public final class MainActivity extends AudioServiceActivity {
  private static final String CHANNEL = "com.alpwarestudio.frekio/widget";

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
  }
}
