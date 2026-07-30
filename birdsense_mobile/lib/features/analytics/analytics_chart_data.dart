// lib/features/analytics/analytics_chart_data.dart
//
// Transforme les données brutes de l'API en structures FL Chart exploitables.
// Ce fichier est SÉPARÉ du shell UI de Lansana Coly — il fournit uniquement
// les données (BarChartData, PieChartData, LineChartData), pas les widgets.
//
// Prérequis pubspec.yaml :
//   dependencies:
//     fl_chart: ^0.68.0   # à ajouter si absent

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'analytics_repository.dart';

// ── BarChart — Diversité des espèces ──────────────────────────────────────

/// Convertit la liste des espèces en [BarChartData] pour FL Chart.
///
/// Chaque espèce = une barre. Hauteur = nombre d'observations.
BarChartData buildSpeciesBarChartData(List<SpeciesDiversityItem> species) {
  final bars = species.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: item.count.toDouble(),
          color: _speciesColor(index),
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }).toList();

  return BarChartData(
    barGroups: bars,
    borderData: FlBorderData(show: false),
    gridData: const FlGridData(show: true),
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= species.length) {
              return const SizedBox.shrink();
            }
            return Text(
              species[idx].speciesName.substring(0, 3),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
  );
}

// ── PieChart — Répartition des espèces ───────────────────────────────────

/// Convertit la liste des espèces en [PieChartData] pour FL Chart.
PieChartData buildSpeciesPieChartData(List<SpeciesDiversityItem> species) {
  final total = species.fold<int>(0, (sum, e) => sum + e.count);
  if (total == 0) return PieChartData(sections: []);

  final sections = species.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    final percentage = (item.count / total) * 100;

    return PieChartSectionData(
      value: item.count.toDouble(),
      color: _speciesColor(index),
      title: '${percentage.toStringAsFixed(1)}%',
      radius: 80,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }).toList();

  return PieChartData(sections: sections, sectionsSpace: 2);
}

// ── LineChart — Volume temporel ───────────────────────────────────────────

/// Convertit le volume temporel en [LineChartData] pour FL Chart.
///
/// L'axe X = index chronologique, l'axe Y = nombre d'observations.
LineChartData buildTemporalLineChartData(List<TemporalVolumeItem> temporal) {
  final spots = temporal.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
  }).toList();

  return LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: const Color(0xFF4CAF50),
        barWidth: 3,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFF4CAF50).withOpacity(0.15),
        ),
      ),
    ],
    gridData: const FlGridData(show: true),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= temporal.length) {
              return const SizedBox.shrink();
            }
            final parts = temporal[idx].date.split('-');
            return Text(
              '${parts[2]}/${parts[1]}',
              style: const TextStyle(fontSize: 9),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
  );
}

// ── Utilitaires ───────────────────────────────────────────────────────────

/// Palette de couleurs distinctes pour les séries de graphiques.
Color _speciesColor(int index) {
  const colors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
  ];
  return colors[index % colors.length];
}
