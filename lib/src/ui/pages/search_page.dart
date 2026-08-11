import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/strings.dart';
import '../design/frekio_design.dart';
import '../widgets/station_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.state});

  final AppState state;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _turkeyOnly = true;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      if (value.trim().length < 2) {
        widget.state.clearSearch();
      } else {
        widget.state.search(value, turkeyOnly: _turkeyOnly);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final hasQuery = _controller.text.trim().length >= 2;
    final hasResults = widget.state.searchResults.isNotEmpty;

    return CustomScrollView(
      key: const PageStorageKey('search-scroll'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(title: s.search, subtitle: s.searchSubtitle),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassSurface(
              clear: true,
              blur: 20,
              borderRadius: BorderRadius.circular(29),
              shadow: false,
              child: SearchBar(
                controller: _controller,
                hintText: s.searchHint,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(Icons.search_rounded),
                ),
                trailing: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () {
                        _controller.clear();
                        widget.state.clearSearch();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
                onChanged: (value) {
                  setState(() {});
                  _changed(value);
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilterChip(
                avatar: Icon(
                  _turkeyOnly
                      ? Icons.location_on_rounded
                      : Icons.public_rounded,
                  size: 18,
                ),
                label: Text(s.turkeyOnly),
                selected: _turkeyOnly,
                showCheckmark: false,
                onSelected: (value) {
                  setState(() => _turkeyOnly = value);
                  if (hasQuery) {
                    widget.state.search(
                      _controller.text,
                      turkeyOnly: _turkeyOnly,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        if (widget.state.searching)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _SearchLoading(),
          )
        else if (!hasQuery)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _SearchMessage(
              icon: Icons.waves_rounded,
              title: s.search,
              message: s.searchEmpty,
            ),
          )
        else if (!hasResults)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _SearchMessage(
              icon: Icons.search_off_rounded,
              title: s.noSearchResults,
              message: s.searchHint,
            ),
          )
        else ...[
          StationSliverList(
            stations: widget.state.searchResults,
            state: widget.state,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 196)),
        ],
      ],
    );
  }
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(bottom: 150),
    child: Center(child: CircularProgressIndicator.adaptive()),
  );
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 168),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ContentSurface(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FrekioPalette.cyan.withValues(alpha: 0.13),
                ),
                child: Icon(icon, size: 34, color: FrekioPalette.cyan),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
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
