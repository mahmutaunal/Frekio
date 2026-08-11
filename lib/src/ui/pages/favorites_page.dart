import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/strings.dart';
import '../design/frekio_design.dart';
import '../widgets/station_list.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CustomScrollView(
      key: const PageStorageKey('favorites-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            title: s.favorites,
            subtitle: s.favoritesSubtitle,
            trailing: state.favorites.isEmpty
                ? null
                : _CountBadge(count: state.favorites.length),
          ),
        ),
        if (state.favorites.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: const _EmptyFavorites(),
          )
        else ...[
          StationSliverList(stations: state.favorites, state: state),
          const SliverToBoxAdapter(child: SizedBox(height: 196)),
        ],
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => GlassSurface(
    clear: true,
    blur: 16,
    borderRadius: BorderRadius.circular(22),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Text(
      '$count',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: FrekioPalette.violetLight,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 170),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ContentSurface(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [FrekioPalette.pink, FrekioPalette.violet],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: FrekioPalette.pink.withValues(alpha: 0.24),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.noFavorites,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 11),
                Text(
                  s.favoritesHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
