import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import 'design/frekio_design.dart';
import 'pages/discover_page.dart';
import 'pages/favorites_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'widgets/mini_player.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pages = [
      DiscoverPage(state: widget.state),
      FavoritesPage(state: widget.state),
      SearchPage(state: widget.state),
      SettingsPage(state: widget.state),
    ];
    final destinations = [
      _DestinationData(Icons.radio_rounded, s.home),
      _DestinationData(Icons.favorite_rounded, s.favorites),
      _DestinationData(Icons.search_rounded, s.search),
      _DestinationData(Icons.tune_rounded, s.settings),
    ];

    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 840;
            if (useRail) {
              return SafeArea(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                      child: GlassSurface(
                        borderRadius: BorderRadius.circular(34),
                        padding: const EdgeInsets.all(7),
                        child: _GlassNavigation(
                          destinations: destinations,
                          selectedIndex: _index,
                          vertical: true,
                          extended: constraints.maxWidth >= 1180,
                          onSelected: _select,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1120),
                              child: IndexedStack(
                                index: _index,
                                children: pages,
                              ),
                            ),
                          ),
                          if (widget.state.currentStation != null)
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 16,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 760,
                                  ),
                                  child: MiniPlayer(state: widget.state),
                                ),
                              ),
                            ),
                          if (widget.state.errorMessage != null)
                            Positioned(
                              top: 14,
                              left: 20,
                              right: 20,
                              child: _ErrorToast(state: widget.state),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final bottomInset = MediaQuery.paddingOf(context).bottom;
            return Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: IndexedStack(index: _index, children: pages),
                ),
                if (widget.state.currentStation != null)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: bottomInset + 88,
                    child: MiniPlayer(state: widget.state),
                  ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: bottomInset + 8,
                  child: GlassSurface(
                    borderRadius: BorderRadius.circular(34),
                    padding: const EdgeInsets.all(6),
                    child: _GlassNavigation(
                      destinations: destinations,
                      selectedIndex: _index,
                      onSelected: _select,
                    ),
                  ),
                ),
                if (widget.state.errorMessage != null)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 14,
                    right: 14,
                    child: _ErrorToast(state: widget.state),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _select(int value) {
    if (value == _index) return;
    setState(() => _index = value);
  }
}

class _GlassNavigation extends StatelessWidget {
  const _GlassNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.vertical = false,
    this.extended = false,
  });

  final List<_DestinationData> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool vertical;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var index = 0; index < destinations.length; index++)
        _NavigationItem(
          data: destinations[index],
          selected: index == selectedIndex,
          vertical: vertical,
          extended: extended,
          onTap: () => onSelected(index),
        ),
    ];
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/brand/frekio_icon_1024.png',
                width: 44,
                height: 44,
                cacheWidth: 132,
              ),
            ),
          ),
          ...items,
        ],
      );
    }
    return Row(children: [for (final item in items) Expanded(child: item)]);
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.data,
    required this.selected,
    required this.vertical,
    required this.extended,
    required this.onTap,
  });

  final _DestinationData data;
  final bool selected;
  final bool vertical;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: data.label,
      child: Padding(
        padding: vertical
            ? const EdgeInsets.symmetric(vertical: 4)
            : EdgeInsets.zero,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: extended ? 176 : 64,
          height: vertical ? 58 : 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FrekioPalette.violetLight, FrekioPalette.violet],
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: FrekioPalette.violet.withValues(alpha: 0.34),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: onTap,
              child: vertical && extended
                  ? Row(
                      children: [
                        const SizedBox(width: 18),
                        Icon(data.icon, color: foreground, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          data.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: foreground,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(data.icon, color: foreground, size: 24),
                        if (!vertical) ...[
                          const SizedBox(height: 3),
                          Text(
                            data.label,
                            maxLines: 1,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: foreground,
                              fontSize: 10.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorToast extends StatelessWidget {
  const _ErrorToast({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(22),
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.playbackProblem,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(onPressed: state.clearError, child: Text(s.dismiss)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationData {
  const _DestinationData(this.icon, this.label);

  final IconData icon;
  final String label;
}
