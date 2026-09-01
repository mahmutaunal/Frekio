import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../domain/station.dart';
import '../../l10n/strings.dart';
import '../design/frekio_design.dart';
import '../widgets/station_list.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return RefreshIndicator.adaptive(
      onRefresh: () => state.refreshPopular(force: true),
      edgeOffset: 12,
      child: CustomScrollView(
        key: const PageStorageKey('discover-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              title: s.appName,
              subtitle: s.discoverSubtitle,
              trailing: const _BrandMark(),
            ),
          ),
          if (state.recent.isNotEmpty) ...[
            SliverToBoxAdapter(child: _SectionHeader(title: s.recentlyPlayed)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 132,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.recent.take(8).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 11),
                  itemBuilder: (context, index) => _RecentStationCard(
                    station: state.recent[index],
                    state: state,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
          ],
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: s.popularTurkey,
              trailing: state.popular.isEmpty
                  ? null
                  : '${state.popular.length} ${s.stationCount}',
            ),
          ),
          if (state.loading && state.popular.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _LoadingState(),
            )
          else if (state.errorMessage != null && state.popular.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(state: state),
            )
          else
            StationSliverList(stations: state.popular, state: state),
          const SliverToBoxAdapter(child: SizedBox(height: 196)),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/logo.png',
          width: 58,
          height: 58,
          cacheWidth: 174,
        ),
      ),
      Positioned(
        right: -3,
        bottom: -3,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF36D980),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF36D980).withValues(alpha: 0.48),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 15, 20, 11),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.52),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              trailing!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    ),
  );
}

class _RecentStationCard extends StatelessWidget {
  const _RecentStationCard({required this.station, required this.state});

  final Station station;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final active = state.currentStation?.uuid == station.uuid;
    return SizedBox(
      width: 246,
      child: LiquidPressable(
        onTap: () => state.play(station),
        child: ContentSurface(
          selected: active,
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              StationArtwork(station: station, size: 66),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF36D980),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            station.subtitle.isEmpty
                                ? S.of(context).liveRadio
                                : station.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => Center(
    child: GlassSurface(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      child: const CircularProgressIndicator.adaptive(),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ContentSurface(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 42),
              const SizedBox(height: 14),
              Text(
                s.playbackProblem,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => state.refreshPopular(force: true),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(s.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
