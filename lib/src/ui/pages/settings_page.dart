import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_state.dart';
import '../../config/alpware_links.dart';
import '../../l10n/strings.dart';
import '../../services/app_engagement_service.dart';
import '../../services/notification_permission_service.dart';
import '../design/frekio_design.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final localeValue = state.locale?.languageCode ?? 'system';
    final themeValue = switch (state.themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    return CustomScrollView(
      key: const PageStorageKey('settings-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(title: s.settings, subtitle: s.settingsSubtitle),
        ),
        const SliverToBoxAdapter(child: _StudioCard()),
        SliverToBoxAdapter(child: _SectionLabel(s.preferences)),
        SliverToBoxAdapter(
          child: _PreferenceCard(
            icon: Icons.language_rounded,
            title: s.language,
            subtitle: s.chooseLanguage,
            child: SegmentedButton<String>(
              expandedInsets: EdgeInsets.zero,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'system', label: Text(s.system)),
                ButtonSegment(value: 'tr', label: Text(s.turkish)),
                ButtonSegment(value: 'en', label: Text(s.english)),
              ],
              selected: {localeValue},
              onSelectionChanged: (value) => state.setLocale(value.first),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _PreferenceCard(
            icon: Icons.contrast_rounded,
            title: s.appearance,
            subtitle: s.chooseAppearance,
            child: SegmentedButton<String>(
              expandedInsets: EdgeInsets.zero,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: 'system',
                  icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                  label: Text(s.system),
                ),
                ButtonSegment(
                  value: 'light',
                  icon: const Icon(Icons.light_mode_rounded, size: 18),
                  label: Text(s.light),
                ),
                ButtonSegment(
                  value: 'dark',
                  icon: const Icon(Icons.dark_mode_rounded, size: 18),
                  label: Text(s.dark),
                ),
              ],
              selected: {themeValue},
              onSelectionChanged: (value) => state.setTheme(value.first),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _NotificationCard(state: state)),
        SliverToBoxAdapter(child: _SectionLabel(s.engagement)),
        SliverToBoxAdapter(
          child: _LinkGroup(
            items: [
              _LinkItem(
                icon: Icons.star_rounded,
                title: s.rateFrekio,
                detail: s.rateFrekioDescription,
                color: const Color(0xFFFFBE4F),
                onTap: () => _rate(context, state),
              ),
              _LinkItem(
                icon: Icons.system_update_rounded,
                title: s.checkForUpdates,
                detail: state.checkingForUpdate
                    ? s.checkingForUpdates
                    : s.appIsUpToDate,
                color: FrekioPalette.cyan,
                onTap: () => _checkForUpdates(context, state),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: _SectionLabel(s.supportAndLegal)),
        SliverToBoxAdapter(
          child: _LinkGroup(
            items: [
              _LinkItem(
                icon: Icons.language_rounded,
                title: s.visitWebsite,
                detail: 'alpwarestudio.com',
                color: FrekioPalette.cyan,
                onTap: () => _open(context, AlpWareLinks.website),
              ),
              _LinkItem(
                icon: Icons.mail_outline_rounded,
                title: s.contactSupport,
                detail: 'contact@alpwarestudio.com',
                color: FrekioPalette.pink,
                onTap: () => _open(context, AlpWareLinks.support),
              ),
              _LinkItem(
                icon: Icons.shield_outlined,
                title: s.privacyPolicy,
                detail: s.privateByDesign,
                color: const Color(0xFF54D6A5),
                onTap: () => _open(context, AlpWareLinks.privacy),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: _SectionLabel(s.application)),
        SliverToBoxAdapter(child: _ApplicationCard(state: state)),
        const SliverToBoxAdapter(child: SizedBox(height: 196)),
      ],
    );
  }

  static Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).linkUnavailable)));
    }
  }

  static Future<void> _rate(BuildContext context, AppState state) async {
    final opened = await state.requestNativeReview();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).reviewUnavailable)));
    }
  }

  static Future<void> _checkForUpdates(
    BuildContext context,
    AppState state,
  ) async {
    final result = await state.checkForUpdate();
    if (!context.mounted) return;
    final s = S.of(context);
    if (result.status == UpdateStatus.available) {
      final install = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.system_update_rounded),
          title: Text(s.updateAvailable),
          content: Text(s.updateAvailableBody(result.availableVersion)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(s.later),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(s.updateNow),
            ),
          ],
        ),
      );
      if (install == true) {
        final started = await state.installAvailableUpdate();
        if (!started && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(s.updateFailed)));
        }
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.status == UpdateStatus.upToDate
              ? s.appIsUpToDate
              : s.updateCheckUnavailable,
        ),
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  const _StudioCard();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6663F2), Color(0xFF302B78), Color(0xFF17152D)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: FrekioPalette.violet.withValues(alpha: 0.28),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    color: Colors.white.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/alpware_logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      cacheWidth: 144,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AlpWare Studio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.45,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.alpwareTagline,
                        style: const TextStyle(
                          color: Color(0xCFFFFFFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.north_east_rounded, color: Color(0xBFFFFFFF)),
              ],
            ),
            const SizedBox(height: 19),
            Text(
              s.alpwareDescription,
              style: const TextStyle(
                color: Color(0xE6FFFFFF),
                height: 1.42,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.05,
      ),
    ),
  );
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: ContentSurface(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadingTitle(icon: icon, title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _LeadingTitle extends StatelessWidget {
  const _LeadingTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: FrekioPalette.violet.withValues(alpha: 0.14),
        ),
        child: Icon(icon, color: FrekioPalette.violetLight, size: 21),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _LinkItem {
  const _LinkItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  final VoidCallback onTap;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final status = switch (state.notificationAuthorization) {
      NotificationAuthorization.authorized => s.notificationsAllowed,
      NotificationAuthorization.denied => s.notificationsNotAllowed,
      NotificationAuthorization.notDetermined => s.notificationsNotRequested,
    };
    final authorized =
        state.notificationAuthorization == NotificationAuthorization.authorized;

    return _PreferenceCard(
      icon: authorized
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
      title: s.notifications,
      subtitle: state.notificationPermission.isRequiredForSystemPlayer
          ? s.notificationsDescription
          : s.iosSystemPlayerDescription,
      child: Row(
        children: [
          Icon(
            authorized ? Icons.check_circle_rounded : Icons.info_rounded,
            color: authorized ? const Color(0xFF54D6A5) : FrekioPalette.pink,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(status)),
          FilledButton.tonal(
            onPressed: state.notificationPermission.isRequiredForSystemPlayer
                ? () async {
                    if (state.notificationAuthorization ==
                        NotificationAuthorization.notDetermined) {
                      await state.requestNotificationPermission();
                    } else {
                      await state.openNotificationSettings();
                    }
                  }
                : null,
            child: Text(
              !state.notificationPermission.isRequiredForSystemPlayer
                  ? s.notificationsAllowed
                  : state.notificationAuthorization ==
                        NotificationAuthorization.notDetermined
                  ? s.allow
                  : s.settings,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkGroup extends StatelessWidget {
  const _LinkGroup({required this.items});

  final List<_LinkItem> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ContentSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _LinkTile(item: items[index]),
            if (index != items.length - 1)
              Divider(
                height: 1,
                indent: 70,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
          ],
        ],
      ),
    ),
  );
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.item});

  final _LinkItem item;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: item.color.withValues(alpha: 0.13),
        ),
        child: Icon(item.icon, color: item.color, size: 21),
      ),
      title: Text(item.title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(item.detail, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.arrow_outward_rounded, size: 20),
      onTap: item.onTap,
    ),
  );
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ContentSurface(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 58,
                    height: 58,
                    cacheWidth: 174,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frekio',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${s.version} ${state.appVersion?.display ?? '—'} • MIT',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: FrekioPalette.violet.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    s.openSource,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: FrekioPalette.violetLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.code_rounded,
                  color: FrekioPalette.cyan,
                ),
                title: Text(s.openSourceLicenses),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Frekio',
                  applicationVersion: state.appVersion?.display ?? '',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 54,
                      height: 54,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                s.privacyText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
