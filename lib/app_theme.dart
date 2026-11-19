
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color background = Color(0xFFF7F4FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFEFE9F8);
  static const Color primary = Color(0xFF8964D8);
  static const Color secondary = Color(0xFFB69AEF);
  static const Color textPrimary = Color(0xFF292438);
  static const Color textSecondary = Color(0xFF81798F);
  static const Color border = Color(0xFFE8E1F0);

  static const Color darkBackground = Color(0xFF100D18);
  static const Color darkSurface = Color(0xFF1B1725);
  static const Color darkElevated = Color(0xFF292238);
  static const Color darkPrimary = Color(0xFFB69AFF);
  static const Color darkSecondary = Color(0xFFD6C5FF);
  static const Color darkText = Color(0xFFF5F0FF);
  static const Color darkTextSecondary = Color(0xFFB8AEC8);
  static const Color darkBorder = Color(0xFF393047);

  static const double radiusSmall = 12;
  static const double radiusMedium = 18;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 30;

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF34234F).withValues(alpha: 0.07),
      blurRadius: 22,
      offset: const Offset(0, 9),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.045),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  static ThemeData get appTheme {
    const scheme = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      primaryContainer: Color(0xFFE9DFFC),
      onPrimaryContainer: Color(0xFF39265D),
      secondaryContainer: Color(0xFFF0E9FC),
      onSecondaryContainer: Color(0xFF493B60),
      surfaceContainerHighest: Color(0xFFF0ECF7),
      onSurfaceVariant: textSecondary,
      outline: border,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
    );

    return _buildTheme(
      scheme: scheme,
      brightness: Brightness.light,
      scaffoldBackground: background,
      appBarBackground: background,
      cardColor: surface,
      inputColor: surface,
      borderColor: border,
      secondaryText: textSecondary,
    );
  }

  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      onPrimary: Color(0xFF28164C),
      onSecondary: Color(0xFF30234A),
      onSurface: darkText,
      primaryContainer: Color(0xFF392B55),
      onPrimaryContainer: Color(0xFFE9DEFF),
      secondaryContainer: Color(0xFF332A43),
      onSecondaryContainer: Color(0xFFE7DDF7),
      surfaceContainerHighest: Color(0xFF30283D),
      onSurfaceVariant: darkTextSecondary,
      outline: darkBorder,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
    );

    return _buildTheme(
      scheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackground: darkBackground,
      appBarBackground: darkBackground,
      cardColor: darkSurface,
      inputColor: darkElevated,
      borderColor: darkBorder,
      secondaryText: darkTextSecondary,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color cardColor,
    required Color inputColor,
    required Color borderColor,
    required Color secondaryText,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: GoogleFonts.poppins().fontFamily,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: borderColor),
        ),
      ),

      iconTheme: IconThemeData(color: scheme.onSurface),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.25),
        selectionHandleColor: scheme.primary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: secondaryText, fontSize: 13),
        labelStyle: TextStyle(color: secondaryText, fontSize: 13),
        prefixIconColor: secondaryText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: scheme.primary,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        labelStyle: TextStyle(color: secondaryText, fontSize: 12),
        secondaryLabelStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return secondaryText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return isDark ? darkElevated : surfaceElevated;
        }),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: scheme.onSurface,
        tileColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: secondaryText,
          fontSize: 13,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? darkElevated : textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 0.8,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : secondaryText,
          );
        }),
      ),
    );
  }
}
