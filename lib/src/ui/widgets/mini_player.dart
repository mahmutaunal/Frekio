import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/strings.dart';
import '../design/frekio_design.dart';
import 'station_list.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final station = state.currentStation;
    if (station == null) return const SizedBox.shrink();

    final s = S.of(context);
    final playing = state.playbackState.playing;
    final loading = {
      AudioProcessingState.loading,
      AudioProcessingState.buffering,
    }.contains(state.playbackState.processingState);

    return GlassSurface(
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
      child: Semantics(
        button: true,
        label: '${s.openPlayer}: ${station.name}',
        child: Row(
          children: [
            LiquidPressable(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showPlayer(context),
              child: StationArtwork(station: station, size: 54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showPlayer(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (!loading)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: playing
                                  ? const Color(0xFF36D980)
                                  : Theme.of(context).colorScheme.outline,
                              shape: BoxShape.circle,
                              boxShadow: playing
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF36D980,
                                        ).withValues(alpha: 0.5),
                                        blurRadius: 7,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        if (!loading) const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            loading
                                ? s.buffering
                                : (state.liveTitle?.isNotEmpty == true
                                      ? state.liveTitle!
                                      : s.liveRadio),
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
            ),
            const SizedBox(width: 8),
            if (loading)
              const SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                ),
              )
            else
              _PrimaryPlaybackButton(
                playing: playing,
                onPressed: state.togglePlayback,
                playLabel: s.play,
                pauseLabel: s.pause,
                compact: true,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlayer(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          final station = state.currentStation;
          if (station == null) return const SizedBox.shrink();
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GlassSurface(
                borderRadius: BorderRadius.circular(38),
                blur: 34,
                padding: EdgeInsets.zero,
                child: _FullPlayer(
                  state: state,
                  onStop: () {
                    state.stop();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullPlayer extends StatelessWidget {
  const _FullPlayer({required this.state, required this.onStop});

  final AppState state;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final station = state.currentStation!;
    final s = S.of(context);
    final playing = state.playbackState.playing;
    final loading = {
      AudioProcessingState.loading,
      AudioProcessingState.buffering,
    }.contains(state.playbackState.processingState);

    return LayoutBuilder(
      builder: (context, constraints) {
        final artworkSize = (constraints.maxHeight * 0.29).clamp(150.0, 230.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: artworkSize * 0.9,
                      height: artworkSize * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FrekioPalette.violet.withValues(alpha: 0.2),
                        boxShadow: [
                          BoxShadow(
                            color: FrekioPalette.violet.withValues(alpha: 0.24),
                            blurRadius: 58,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    StationArtwork(station: station, size: artworkSize),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  s.nowPlaying.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: FrekioPalette.violetLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  station.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 9),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    loading
                        ? s.buffering
                        : (state.liveTitle?.isNotEmpty == true
                              ? state.liveTitle!
                              : (station.subtitle.isEmpty
                                    ? s.liveRadio
                                    : station.subtitle)),
                    key: ValueKey('$loading-${state.liveTitle}'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 27),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassIconButton(
                      icon: state.isFavorite(station)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      selected: state.isFavorite(station),
                      tooltip: state.isFavorite(station)
                          ? s.removeFavorite
                          : s.addFavorite,
                      onPressed: () => state.toggleFavorite(station),
                      size: 54,
                    ),
                    const SizedBox(width: 20),
                    _PrimaryPlaybackButton(
                      playing: playing,
                      onPressed: loading ? null : state.togglePlayback,
                      playLabel: s.play,
                      pauseLabel: s.pause,
                    ),
                    const SizedBox(width: 20),
                    GlassIconButton(
                      icon: Icons.stop_rounded,
                      tooltip: s.stop,
                      onPressed: onStop,
                      size: 54,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    s.sleepTimer,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TimerChip(
                      label: s.off,
                      selected: state.sleepTimerDuration == null,
                      onTap: () => state.setSleepTimer(null),
                    ),
                    for (final minutes in [15, 30, 45, 60])
                      _TimerChip(
                        label: s.minutes(minutes),
                        selected:
                            state.sleepTimerDuration ==
                            Duration(minutes: minutes),
                        onTap: () =>
                            state.setSleepTimer(Duration(minutes: minutes)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryPlaybackButton extends StatelessWidget {
  const _PrimaryPlaybackButton({
    required this.playing,
    required this.onPressed,
    required this.playLabel,
    required this.pauseLabel,
    this.compact = false,
  });

  final bool playing;
  final VoidCallback? onPressed;
  final String playLabel;
  final String pauseLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 50.0 : 76.0;
    return Tooltip(
      message: playing ? pauseLabel : playLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FrekioPalette.violetLight, FrekioPalette.violet],
          ),
          boxShadow: [
            BoxShadow(
              color: FrekioPalette.violet.withValues(alpha: 0.38),
              blurRadius: compact ? 16 : 28,
              offset: Offset(0, compact ? 7 : 12),
            ),
          ],
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: IconButton(
            onPressed: onPressed,
            iconSize: compact ? 27 : 38,
            color: Colors.white,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(playing),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    onSelected: (_) => onTap(),
  );
}
