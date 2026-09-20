import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette (Deep Teal / Emerald)
  static const Color primary = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryContainerLight = Color(0xFFCCFBF1); // Teal 100
  static const Color primaryContainerDark = Color(0xFF134E4A); // Teal 900

  // Secondary brand accents
  static const Color secondary = Color(0xFF6366F1); // Indigo 500
  static const Color accent = Color(0xFF06B6D4); // Cyan 500

  // Semantic Financial Colors
  static const Color income = Color(0xFF10B981); // Emerald 500
  static const Color incomeDark = Color(0xFF059669); // Emerald 600
  static const Color incomeLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color incomeTextDark = Color(0xFF065F46);

  static const Color expense = Color(0xFFEF4444); // Red 500
  static const Color expenseDark = Color(0xFFDC2626); // Red 600
  static const Color expenseLight = Color(0xFFFEE2E2); // Red 100
  static const Color expenseTextDark = Color(0xFF991B1B);

  // Debts & Balances
  static const Color lentColor = Color(0xFFF59E0B); // Amber 500 (Money I gave / Receivable)
  static const Color lentContainer = Color(0xFFFEF3C7);
  static const Color borrowedColor = Color(0xFF8B5CF6); // Purple 500 (Money I received / Payable)
  static const Color borrowedContainer = Color(0xFFEDE9FE);

  // Neutral Light Surface Colors
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // Neutral Dark Surface Colors
  static const Color darkBg = Color(0xFF0B0F19); // Deep dark
  static const Color darkSurface = Color(0xFF131B2E); // Dark surface card
  static const Color darkSurfaceVariant = Color(0xFF1E293B); // Slate 800
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500

  // Card & Chart Palette
  static const List<Color> categoryColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
    Color(0xFF64748B), // Slate
  ];
}
