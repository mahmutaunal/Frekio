package com.alpwarestudio.frekio;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.SystemClock;
import android.view.KeyEvent;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public final class FrekioWidgetProvider extends AppWidgetProvider {
  static final String WIDGET_PREFERENCES = "frekio_widget";
  private static final String ACTION_TOGGLE = "com.alpwarestudio.frekio.widget.TOGGLE";
  private static final String ACTION_STOP = "com.alpwarestudio.frekio.widget.STOP";
  private static final String ARTWORK_FILE = "frekio_widget_artwork.png";
  private static final ExecutorService ARTWORK_EXECUTOR = Executors.newSingleThreadExecutor();

  @Override
  public void onUpdate(Context context, AppWidgetManager manager, int[] appWidgetIds) {
    for (int id : appWidgetIds) manager.updateAppWidget(id, views(context));
    loadArtworkIfNeeded(context);
  }

  @Override
  public void onReceive(Context context, Intent intent) {
    super.onReceive(context, intent);
    final String action = intent.getAction();
    if (ACTION_TOGGLE.equals(action)) {
      sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE);
      final SharedPreferences preferences =
          context.getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE);
      preferences.edit().putBoolean("isPlaying", !preferences.getBoolean("isPlaying", false)).apply();
      updateAll(context);
    } else if (ACTION_STOP.equals(action)) {
      sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_STOP);
      context.getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE)
          .edit().putBoolean("isPlaying", false).apply();
      updateAll(context);
    }
  }

  private static RemoteViews views(Context context) {
    final RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.frekio_widget);
    final SharedPreferences preferences =
        context.getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE);
    String station = preferences.getString("stationName", null);
    if (station == null || station.isEmpty()) station = restoredStationName(context);
    if (station == null || station.isEmpty()) station = "Frekio";
    final String detail = preferences.getString("detail", "Internet radio");
    final boolean playing = preferences.getBoolean("isPlaying", false);

    views.setTextViewText(R.id.widget_station, station);
    views.setTextViewText(R.id.widget_detail, detail == null || detail.isEmpty() ? "Internet radio" : detail);
    views.setImageViewResource(
        R.id.widget_toggle, playing ? R.drawable.ic_widget_pause : R.drawable.ic_widget_play);
    views.setContentDescription(R.id.widget_toggle, playing ? "Pause" : "Play");
    views.setOnClickPendingIntent(R.id.widget_toggle, widgetIntent(context, ACTION_TOGGLE, 1));
    views.setOnClickPendingIntent(R.id.widget_stop, widgetIntent(context, ACTION_STOP, 2));

    final String artworkUrl = preferences.getString("artworkUrl", "");
    final String cachedArtworkUrl = preferences.getString("cachedArtworkUrl", "");
    final File artworkFile = new File(context.getCacheDir(), ARTWORK_FILE);
    if (!artworkUrl.isEmpty() && artworkUrl.equals(cachedArtworkUrl) && artworkFile.isFile()) {
      final Bitmap artwork = BitmapFactory.decodeFile(artworkFile.getAbsolutePath());
      if (artwork != null) views.setImageViewBitmap(R.id.widget_artwork, artwork);
    } else {
      views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher);
    }

    final Intent launch = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
    if (launch != null) {
      views.setOnClickPendingIntent(
          R.id.widget_content,
          PendingIntent.getActivity(
              context, 3, launch,
              PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE));
    }
    return views;
  }

  private static PendingIntent widgetIntent(Context context, String action, int requestCode) {
    final Intent intent = new Intent(context, FrekioWidgetProvider.class).setAction(action);
    return PendingIntent.getBroadcast(
        context, requestCode, intent,
        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
  }

  private static void sendMediaButton(Context context, int keyCode) {
    final ComponentName receiver = new ComponentName(
        context, "com.ryanheise.audioservice.MediaButtonReceiver");
    final long now = SystemClock.uptimeMillis();
    for (int action : new int[] {KeyEvent.ACTION_DOWN, KeyEvent.ACTION_UP}) {
      final Intent mediaIntent = new Intent(Intent.ACTION_MEDIA_BUTTON)
          .setComponent(receiver)
          .putExtra(Intent.EXTRA_KEY_EVENT, new KeyEvent(now, now, action, keyCode, 0));
      context.sendBroadcast(mediaIntent);
    }
  }

  private static String restoredStationName(Context context) {
    try {
      final String raw = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
          .getString("flutter.last_station.v1", null);
      if (raw == null) return null;
      final JSONArray stations = new JSONArray(raw);
      if (stations.length() == 0) return null;
      final JSONObject station = stations.getJSONObject(0);
      return station.optString("name", null);
    } catch (Exception ignored) {
      return null;
    }
  }

  private static void updateAll(Context context) {
    final AppWidgetManager manager = AppWidgetManager.getInstance(context);
    final int[] ids = manager.getAppWidgetIds(new ComponentName(context, FrekioWidgetProvider.class));
    for (int id : ids) manager.updateAppWidget(id, views(context));
  }

  private static void loadArtworkIfNeeded(Context context) {
    final Context appContext = context.getApplicationContext();
    final SharedPreferences preferences =
        appContext.getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE);
    final String artworkUrl = preferences.getString("artworkUrl", "");
    final String cachedArtworkUrl = preferences.getString("cachedArtworkUrl", "");
    final File artworkFile = new File(appContext.getCacheDir(), ARTWORK_FILE);

    if (artworkUrl == null || artworkUrl.isEmpty()) {
      if (artworkFile.isFile()) artworkFile.delete();
      preferences.edit().remove("cachedArtworkUrl").apply();
      return;
    }
    if (artworkUrl.equals(cachedArtworkUrl) && artworkFile.isFile()) return;

    ARTWORK_EXECUTOR.execute(() -> {
      HttpURLConnection connection = null;
      try {
        connection = (HttpURLConnection) new URL(artworkUrl).openConnection();
        connection.setConnectTimeout(5000);
        connection.setReadTimeout(7000);
        connection.setInstanceFollowRedirects(true);
        connection.setRequestProperty("User-Agent", "Frekio/1.3");
        connection.connect();
        if (connection.getResponseCode() < 200 || connection.getResponseCode() >= 300) return;

        final Bitmap downloaded = BitmapFactory.decodeStream(connection.getInputStream());
        if (downloaded == null) return;
        final int largestSide = Math.max(downloaded.getWidth(), downloaded.getHeight());
        final float scale = largestSide > 512 ? 512f / largestSide : 1f;
        final Bitmap artwork = scale < 1f
            ? Bitmap.createScaledBitmap(
                downloaded,
                Math.max(1, Math.round(downloaded.getWidth() * scale)),
                Math.max(1, Math.round(downloaded.getHeight() * scale)),
                true)
            : downloaded;
        try (FileOutputStream output = new FileOutputStream(artworkFile)) {
          artwork.compress(Bitmap.CompressFormat.PNG, 92, output);
        }
        preferences.edit().putString("cachedArtworkUrl", artworkUrl).apply();
        updateAll(appContext);
      } catch (Exception ignored) {
        // Artwork is decorative; playback and widget controls must remain available.
      } finally {
        if (connection != null) connection.disconnect();
      }
    });
  }
}
