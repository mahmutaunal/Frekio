import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'l10n/strings.dart';
import 'ui/home_shell.dart';

class FrekioApp extends StatefulWidget {
  const FrekioApp({super.key, required this.state});
  final AppState state;

  @override
  State<FrekioApp> createState() => _FrekioAppState();
}

class _FrekioAppState extends State<FrekioApp> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_changed);
  }

  @override
  void dispose() {
    widget.state.removeListener(_changed);
    widget.state.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3A356F),
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB9B2FF),
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Frekio',
        locale: widget.state.locale,
        supportedLocales: S.supportedLocales,
        localizationsDelegates: const [
          _SimpleLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: widget.state.themeMode,
        theme: _theme(lightScheme),
        darkTheme: _theme(darkScheme),
        home: HomeShell(state: widget.state),
      ),
    );
  }

  ThemeData _theme(ColorScheme scheme) => ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    visualDensity: VisualDensity.standard,
    textTheme: ThemeData(brightness: scheme.brightness).textTheme.copyWith(
      displaySmall: TextStyle(
        fontSize: 38,
        height: 1.02,
        letterSpacing: -1.35,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 27,
        height: 1.08,
        letterSpacing: -0.65,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        height: 1.15,
        letterSpacing: -0.35,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.2,
        letterSpacing: -0.18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.35, color: scheme.onSurface),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.35),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      selectedColor: scheme.primary.withValues(alpha: 0.18),
      backgroundColor: scheme.surface.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withValues(alpha: 0.92)
              : scheme.surface.withValues(alpha: 0.4),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurface,
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(CircleBorder()),
        overlayColor: WidgetStatePropertyAll(
          scheme.primary.withValues(alpha: 0.12),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(52, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(
        scheme.surface.withValues(alpha: 0.54),
      ),
      side: WidgetStatePropertyAll(
        BorderSide(color: Colors.white.withValues(alpha: 0.24)),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.primary.withValues(alpha: 0.14),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashFactory: InkRipple.splashFactory,
  );
}

class _SimpleLocalizationsDelegate extends LocalizationsDelegate<S> {
  const _SimpleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      S.supportedLocales.any((e) => e.languageCode == locale.languageCode);

  @override
  Future<S> load(Locale locale) => SynchronousFuture(S(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<S> old) => false;
}
