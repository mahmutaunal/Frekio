class Station {
  const Station({
    required this.uuid,
    required this.name,
    required this.streamUrl,
    required this.homepage,
    required this.favicon,
    required this.tags,
    required this.countryCode,
    required this.state,
    required this.language,
    required this.codec,
    required this.bitrate,
    required this.votes,
    required this.clickCount,
  });

  final String uuid;
  final String name;
  final String streamUrl;
  final String homepage;
  final String favicon;
  final List<String> tags;
  final String countryCode;
  final String state;
  final String language;
  final String codec;
  final int bitrate;
  final int votes;
  final int clickCount;

  String get subtitle {
    final parts = <String>[
      if (state.trim().isNotEmpty) state.trim(),
      if (tags.isNotEmpty) tags.take(2).join(' · '),
      if (bitrate > 0) '$bitrate kbps',
    ];
    return parts.join(' • ');
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    final rawTags = (json['tags'] ?? '').toString();
    return Station(
      uuid: (json['stationuuid'] ?? '').toString(),
      name: _clean((json['name'] ?? '').toString()),
      streamUrl: (json['url_resolved'] ?? json['url'] ?? '').toString(),
      homepage: (json['homepage'] ?? '').toString(),
      favicon: (json['favicon'] ?? '').toString(),
      tags: rawTags
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .take(8)
          .toList(growable: false),
      countryCode: (json['countrycode'] ?? '').toString().toUpperCase(),
      state: _clean((json['state'] ?? '').toString()),
      language: _clean((json['language'] ?? '').toString()),
      codec: (json['codec'] ?? '').toString(),
      bitrate: _asInt(json['bitrate']),
      votes: _asInt(json['votes']),
      clickCount: _asInt(json['clickcount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'stationuuid': uuid,
    'name': name,
    'url_resolved': streamUrl,
    'homepage': homepage,
    'favicon': favicon,
    'tags': tags.join(','),
    'countrycode': countryCode,
    'state': state,
    'language': language,
    'codec': codec,
    'bitrate': bitrate,
    'votes': votes,
    'clickcount': clickCount,
  };

  static int _asInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static String _clean(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
