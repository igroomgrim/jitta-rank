import 'package:flutter/material.dart';

/// Semantic colours the app needs that a [ColorScheme] has no slot for.
///
/// Attached as a [ThemeExtension] so widgets read them from the theme like any
/// other token, and both light and dark get an explicit value. Previously
/// "positive/negative" was written as bare Colors.blue / Colors.red at each
/// call site, which is why nothing responded to dark mode.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.positive,
    required this.negative,
    required this.online,
    required this.offline,
  });

  /// A gain, and the app's accent for prices and scores.
  final Color positive;

  /// A loss.
  final Color negative;
  final Color online;
  final Color offline;

  @override
  AppSemanticColors copyWith({
    Color? positive,
    Color? negative,
    Color? online,
    Color? offline,
  }) {
    return AppSemanticColors(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      online: online ?? this.online,
      offline: offline ?? this.offline,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      online: Color.lerp(online, other.online, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}

abstract final class AppTheme {
  static const _seed = Color(0xFF1565C0);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: isDark ? 0 : 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
      extensions: [
        AppSemanticColors(
          // Brighter variants in dark mode: the light-mode reds and greens do
          // not carry enough contrast against a dark surface.
          positive: isDark ? const Color(0xFF7FD1A0) : const Color(0xFF1B7F4E),
          negative: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
          online: isDark ? const Color(0xFF82B1FF) : scheme.primary,
          offline: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
        ),
      ],
    );
  }
}
