import 'package:flutter/widgets.dart';

class S {
  S(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('tr')];

  static S of(BuildContext context) => Localizations.of<S>(context, S)!;

  bool get _tr => locale.languageCode == 'tr';

  String get appName => 'Frekio';
  String get home => _tr ? 'Keşfet' : 'Discover';
  String get favorites => _tr ? 'Favoriler' : 'Favorites';
  String get search => _tr ? 'Ara' : 'Search';
  String get settings => _tr ? 'Ayarlar' : 'Settings';
  String get popularTurkey => _tr ? 'Türkiye’de popüler' : 'Popular in Turkey';
  String get recentlyPlayed => _tr ? 'Son dinlenenler' : 'Recently played';
  String get noFavorites => _tr ? 'Henüz favorin yok.' : 'No favorites yet.';
  String get noRecent =>
      _tr ? 'Henüz bir istasyon dinlemedin.' : 'Nothing played yet.';
  String get retry => _tr ? 'Tekrar dene' : 'Retry';
  String get searchHint =>
      _tr ? 'Radyo istasyonu ara' : 'Search radio stations';
  String get turkeyOnly => _tr ? 'Sadece Türkiye' : 'Turkey only';
  String get language => _tr ? 'Dil' : 'Language';
  String get system => _tr ? 'Sistem' : 'System';
  String get turkish => 'Türkçe';
  String get english => 'English';
  String get appearance => _tr ? 'Görünüm' : 'Appearance';
  String get light => _tr ? 'Açık' : 'Light';
  String get dark => _tr ? 'Koyu' : 'Dark';
  String get about => _tr ? 'Hakkında' : 'About';
  String get privacyText => _tr
      ? 'Reklam, hesap, analiz ve takip yok. Favoriler ve ayarlar cihazında saklanır.'
      : 'No ads, accounts, analytics or tracking. Favorites and settings stay on your device.';
  String get sleepTimer => _tr ? 'Uyku zamanlayıcısı' : 'Sleep timer';
  String get off => _tr ? 'Kapalı' : 'Off';
  String minutes(int n) => _tr ? '$n dakika' : '$n minutes';
  String get playing => _tr ? 'Çalınıyor' : 'Playing';
  String get buffering => _tr ? 'Bağlanıyor…' : 'Connecting…';
  String get stationUnavailable => _tr
      ? 'Bu istasyon şu anda oynatılamıyor.'
      : 'This station cannot be played right now.';
  String get play => _tr ? 'Oynat' : 'Play';
  String get pause => _tr ? 'Duraklat' : 'Pause';
  String get stop => _tr ? 'Durdur' : 'Stop';
  String get addFavorite => _tr ? 'Favorilere ekle' : 'Add favorite';
  String get removeFavorite => _tr ? 'Favorilerden çıkar' : 'Remove favorite';

  String get openPlayer => _tr ? 'Oynatıcıyı aç' : 'Open player';
  String get nowPlaying => _tr ? 'Şimdi çalıyor' : 'Now playing';
  String get playbackProblem => _tr
      ? 'Yayın bağlantısında sorun oluştu.'
      : 'There was a problem with the stream.';
  String get dismiss => _tr ? 'Kapat' : 'Dismiss';
  String get searchEmpty => _tr
      ? 'En az iki harfle bir istasyon ara.'
      : 'Search for a station using at least two letters.';
  String get noSearchResults => _tr
      ? 'Bu aramayla eşleşen istasyon bulunamadı.'
      : 'No stations matched this search.';
  String get favoritesHint => _tr
      ? 'İstasyonların yanındaki kalbe dokunarak buraya ekleyebilirsin.'
      : 'Tap the heart beside a station to keep it here.';
  String get liveRadio => _tr ? 'Canlı radyo' : 'Live radio';
  String get discoverSubtitle => _tr
      ? 'Türkiye’den ve dünyadan canlı yayınlar'
      : 'Live stations from Turkey and around the world';
  String get stationCount => _tr ? 'istasyon' : 'stations';
  String get favorite => _tr ? 'Favori' : 'Favorite';
  String get chooseLanguage => _tr ? 'Uygulama dili' : 'App language';
  String get chooseAppearance => _tr ? 'Renk modu' : 'Color mode';
  String get privateByDesign => _tr ? 'Gizlilik odaklı' : 'Private by design';
  String get openSource => _tr ? 'Açık kaynak' : 'Open source';
  String get localOnly => _tr
      ? 'Favoriler ve tercihler yalnızca bu cihazda saklanır.'
      : 'Favorites and preferences are stored only on this device.';
  String get searchSubtitle => _tr
      ? 'İsme göre binlerce canlı yayını keşfet'
      : 'Discover thousands of live stations by name';
  String get favoritesSubtitle => _tr
      ? 'Sevdiğin yayınlar, tek dokunuş uzağında'
      : 'Your stations, always one tap away';
  String get settingsSubtitle => _tr
      ? 'Deneyimini kişiselleştir ve Frekio hakkında bilgi al'
      : 'Personalize your experience and learn about Frekio';
  String get preferences => _tr ? 'Tercihler' : 'Preferences';
  String get alpwareTagline =>
      _tr ? 'Bağımsız yazılım stüdyosu' : 'Independent software studio';
  String get alpwareDescription => _tr
      ? 'Gizliliğe saygılı, özenle tasarlanmış ve günlük hayatta gerçekten işe yarayan ürünler geliştiriyoruz.'
      : 'We build thoughtful, privacy-respecting products that are genuinely useful every day.';
  String get visitWebsite => _tr ? 'Web sitesini ziyaret et' : 'Visit website';
  String get contactSupport =>
      _tr ? 'Destek ile iletişime geç' : 'Contact support';
  String get privacyPolicy => _tr ? 'Gizlilik politikası' : 'Privacy policy';
  String get supportAndLegal => _tr ? 'Destek ve yasal' : 'Support & legal';
  String get application => _tr ? 'Uygulama' : 'Application';
  String get openSourceLicenses =>
      _tr ? 'Açık kaynak lisansları' : 'Open-source licenses';
  String get version => _tr ? 'Sürüm' : 'Version';
  String get linkUnavailable => _tr
      ? 'Bağlantı şu anda açılamıyor.'
      : 'The link cannot be opened right now.';
}
