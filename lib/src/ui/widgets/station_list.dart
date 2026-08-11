import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../domain/station.dart';
import '../../l10n/strings.dart';
import '../design/frekio_design.dart';

class StationSliverList extends StatelessWidget {
  const StationSliverList({
    super.key,
    required this.stations,
    required this.state,
    this.horizontalPadding = 16,
  });

  final List<Station> stations;
  final AppState state;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    sliver: SliverList.separated(
      itemCount: stations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final station = stations[index];
        final favorite = state.isFavorite(station);
        final active = state.currentStation?.uuid == station.uuid;
        final s = S.of(context);
        return LiquidPressable(
          semanticLabel: '${station.name}, ${active ? s.playing : s.play}',
          onTap: () => state.play(station),
          child: ContentSurface(
            selected: active,
            padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
            child: Row(
              children: [
                StationArtwork(station: station, size: 58),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (active) ...[
                            _LivePulse(playing: state.playbackState.playing),
                            const SizedBox(width: 7),
                          ],
                          Expanded(
                            child: Text(
                              station.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        station.subtitle.isEmpty
                            ? s.liveRadio
                            : station.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: favorite ? s.removeFavorite : s.addFavorite,
                  onPressed: () => state.toggleFavorite(station),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor: favorite
                        ? FrekioPalette.pink.withValues(alpha: 0.14)
                        : Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.34),
                  ),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(favorite),
                      color: favorite
                          ? FrekioPalette.pink
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _LivePulse extends StatelessWidget {
  const _LivePulse({required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: FrekioPalette.violet.withValues(alpha: 0.16),
    ),
    child: Icon(
      playing ? Icons.graphic_eq_rounded : Icons.pause_rounded,
      size: 14,
      color: FrekioPalette.violetLight,
    ),
  );
}

class StationArtwork extends StatelessWidget {
  const StationArtwork({super.key, required this.station, this.size = 52});

  final Station station;
  final double size;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(station.favicon);
    final radius = BorderRadius.circular(size * 0.3);
    return Hero(
      tag: 'station-art-${station.uuid}-$size',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: size,
            height: size,
            child: uri == null || !uri.hasScheme
                ? _fallback(context)
                : Image.network(
                    uri.toString(),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    frameBuilder: (context, child, frame, _) => AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      child: child,
                    ),
                    errorBuilder: (_, _, _) => _fallback(context),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final initial = station.name.trim().isEmpty
        ? 'F'
        : station.name.trim().characters.first.toUpperCase();
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FrekioPalette.violetLight, FrekioPalette.violet],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
