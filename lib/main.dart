import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/ideadetail_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/emptystates_screen.dart';
import 'screens/project_screen.dart';
import 'screens/projectdetail_screen.dart';
import 'screens/quickcapture_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.loadPreferences();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final preference = AppState.instance.themeIndex;
        final systemIsDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        final activeTheme = preference == 0
            ? _darkTheme()
            : preference == 1
            ? _lightTheme()
            : systemIsDark
            ? _systemDarkTheme()
            : _systemLightTheme();

        return AnimatedTheme(
          data: activeTheme,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          child: MaterialApp(
            title: 'Ideon',
            debugShowCheckedModeBanner: false,
            theme: activeTheme,
            themeMode: ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/home': (_) => const HomeScreen(),
              '/inbox': (_) => const InboxScreen(),
              '/projects': (_) => const ProjectsScreen(),
              '/project-detail': (context) => IdeonProjectDetailScreen(
                projectName:
                    ModalRoute.of(context)?.settings.arguments as String?,
              ),
              '/search': (_) => const SearchScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/quick-capture': (context) {
                final arguments = ModalRoute.of(context)?.settings.arguments;
                final values = arguments is Map ? arguments : const {};
                return QuickCaptureScreen(
                  initialType: values['type'] as String?,
                  initialProject: values['project'] as String?,
                );
              },
              '/idea-detail': (context) => IdeaDetailScreen(
                capture:
                    ModalRoute.of(context)?.settings.arguments is CaptureItem
                    ? ModalRoute.of(context)!.settings.arguments as CaptureItem
                    : null,
              ),
              '/lock': (_) => const LockScreen(),
              '/empty-states': (_) => const IdeonEmptyStatesScreen(),
            },
          ),
        );
      },
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      canvasColor: const Color(0xFFF5F7FB),
      cardColor: Colors.white,
      textTheme: _lightTextTheme(),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDCE3EF)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Color(0xFF172033),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: _lightInputTheme(),
      filledButtonTheme: _lightFilledButtonTheme(),
      outlinedButtonTheme: _lightOutlinedButtonTheme(),
      textButtonTheme: _lightTextButtonTheme(),
      elevatedButtonTheme: _lightElevatedButtonTheme(),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF172033),
        unselectedLabelColor: Color(0xFF52627A),
      ),
      chipTheme: _lightChipTheme(),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _IdeonPageTransitionsBuilder(),
          TargetPlatform.iOS: _IdeonPageTransitionsBuilder(),
          TargetPlatform.windows: _IdeonPageTransitionsBuilder(),
          TargetPlatform.macOS: _IdeonPageTransitionsBuilder(),
          TargetPlatform.linux: _IdeonPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF080B12),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _IdeonPageTransitionsBuilder(),
          TargetPlatform.iOS: _IdeonPageTransitionsBuilder(),
          TargetPlatform.windows: _IdeonPageTransitionsBuilder(),
          TargetPlatform.macOS: _IdeonPageTransitionsBuilder(),
          TargetPlatform.linux: _IdeonPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
    );
  }

  ThemeData _systemDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0EA5A8),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF071417),
      useMaterial3: true,
    );
  }

  ThemeData _systemLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      scaffoldBackgroundColor: const Color(0xFFF2FAF9),
      canvasColor: const Color(0xFFF2FAF9),
      cardColor: Colors.white,
      textTheme: _lightTextTheme(seed: const Color(0xFF0F766E)),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFC8E4E1)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: _lightInputTheme(),
      filledButtonTheme: _lightFilledButtonTheme(seed: const Color(0xFF0F766E)),
      outlinedButtonTheme: _lightOutlinedButtonTheme(
        seed: const Color(0xFF0F766E),
      ),
      textButtonTheme: _lightTextButtonTheme(seed: const Color(0xFF0F766E)),
      chipTheme: _lightChipTheme(seed: const Color(0xFF0F766E)),
      elevatedButtonTheme: _lightElevatedButtonTheme(
        seed: const Color(0xFF0F766E),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF52627A),
      ),
      useMaterial3: true,
    );
  }

  TextTheme _lightTextTheme({Color seed = const Color(0xFF2563EB)}) {
    return TextTheme(
      headlineLarge: const TextStyle(color: Color(0xFF172033)),
      headlineMedium: const TextStyle(color: Color(0xFF172033)),
      titleLarge: const TextStyle(color: Color(0xFF172033)),
      titleMedium: const TextStyle(color: Color(0xFF172033)),
      bodyLarge: const TextStyle(color: Color(0xFF26344D)),
      bodyMedium: const TextStyle(color: Color(0xFF52627A)),
      bodySmall: const TextStyle(color: Color(0xFF64748B)),
      labelLarge: TextStyle(color: seed, fontWeight: FontWeight.w700),
    );
  }

  InputDecorationTheme _lightInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF52627A)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFD9E2F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFD9E2F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
      ),
    );
  }

  FilledButtonThemeData _lightFilledButtonTheme({
    Color seed = const Color(0xFF2563EB),
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: seed.withValues(alpha: 0.24),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  OutlinedButtonThemeData _lightOutlinedButtonTheme({
    Color seed = const Color(0xFF2563EB),
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: seed,
        backgroundColor: seed.withValues(alpha: 0.06),
        side: BorderSide(color: seed.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  TextButtonThemeData _lightTextButtonTheme({
    Color seed = const Color(0xFF2563EB),
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: seed,
        backgroundColor: seed.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  ElevatedButtonThemeData _lightElevatedButtonTheme({
    Color seed = const Color(0xFF2563EB),
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ChipThemeData _lightChipTheme({Color seed = const Color(0xFF2563EB)}) {
    return ChipThemeData(
      backgroundColor: const Color(0xFFF0F4FA),
      selectedColor: seed,
      checkmarkColor: Colors.white,
      disabledColor: const Color(0xFFE8EDF5),
      secondarySelectedColor: seed,
      side: const BorderSide(color: Color(0xFFD5DFEC)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(
        color: Color(0xFF52627A),
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    );
  }
}

class _IdeonPageTransitionsBuilder extends PageTransitionsBuilder {
  const _IdeonPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
