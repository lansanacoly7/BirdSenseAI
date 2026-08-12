import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Emerald Bio-Tech & Apple Style)
  static const Color primaryAction = Color(0xFF10B981); // Emerald Bio Vert
  static const Color secondaryAction = Color(0xFF06B6D4); // Cyber Cyan (Audio/Stats)
  static const Color accent = Color(0xFFF59E0B); // Amber (Tendances/Alertes)
  static const Color danger = Color(0xFFEF4444); // Crimson (Urgence/Alertes)

  // Light Mode Colors (Apple Weather Clean)
  static const Color lightBackground = Color(0xFFF8FAFC); 
  static const Color lightSurface = Color(0xFFFFFFFF); 
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Colors (Obsidian Navy & Soft Glass)
  static const Color darkBackground = Color(0xFF0B132B); 
  static const Color darkSurface = Color(0xFF1C2541); 
  static const Color darkSurfaceElevated = Color(0xFF253258);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0x1FFFFFFF); // 12% White Border

  // Legacy compatibility getters (Default to dynamic theme-aware values)
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color border = lightBorder;

  // IUCN Status Colors
  static const Color iucnLeastConcern = Color(0xFF10B981); 
  static const Color iucnNearThreatened = Color(0xFFEAB308); 
  static const Color iucnVulnerable = Color(0xFFF97316); 
  static const Color iucnEndangered = Color(0xFFEF4444); 
  static const Color iucnCriticallyEndangered = Color(0xFF991B1B); 
}

