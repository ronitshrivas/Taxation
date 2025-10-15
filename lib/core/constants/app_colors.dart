import 'package:flutter/material.dart';

/// App-wide color constants following Material Design 3 principles
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF1565C0); // Deep Blue
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color primaryContainer = Color(0xFFD8E6FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50); // Green for savings
  static const Color secondaryLight = Color(0xFF80E27E);
  static const Color secondaryDark = Color(0xFF087F23);
  static const Color secondaryContainer = Color(0xFFE8F5E9);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  // Tax-specific Colors
  static const Color taxSavings = Color(0xFF66BB6A);
  static const Color taxLiability = Color(0xFFEF5350);
  static const Color deduction = Color(0xFF42A5F5);
  static const Color income = Color(0xFF9CCC65);
  static const Color expense = Color(0xFFFF7043);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFA726), // Orange
    Color(0xFFEF5350), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
  ];

  // Add this to the Semantic Colors section
static const Color successContainer = Color(0xFFE8F5E9);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'salary': Color(0xFF1976D2),
    'business': Color(0xFF4CAF50),
    'investment': Color(0xFF9C27B0),
    'rental': Color(0xFFFFA726),
    'office_rent': Color(0xFFEF5350),
    'salaries': Color(0xFF42A5F5),
    'utilities': Color(0xFFFFB74D),
    'travel': Color(0xFF66BB6A),
    'professional_fees': Color(0xFFBA68C8),
    'insurance': Color(0xFF26C6DA),
    'marketing': Color(0xFFFF7043),
    'training': Color(0xFF5C6BC0),
    'repairs': Color(0xFF8D6E63),
    'communication': Color(0xFF78909C),
  };

  // Status Colors
  static const Color approved = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFA726);
  static const Color rejected = Color(0xFFEF5350);
  static const Color draft = Color(0xFF9E9E9E);

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.08);
  static Color shadowMedium = Colors.black.withOpacity(0.12);
  static Color shadowDark = Colors.black.withOpacity(0.16);

  // Opacity variations
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}