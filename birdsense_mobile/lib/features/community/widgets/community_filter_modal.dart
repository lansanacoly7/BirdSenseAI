import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CommunityFilterModal extends StatefulWidget {
  final String activeFilter;
  const CommunityFilterModal({super.key, required this.activeFilter});

  @override
  State<CommunityFilterModal> createState() => _CommunityFilterModalState();
}

class _CommunityFilterModalState extends State<CommunityFilterModal> {
  late String _selectedCategory;
  bool _onlyVerified = false;
  bool _hideSensitiveLocations = true;

  final List<String> _categories = [
    'Toutes',
    'Récentes',
    'Près de moi',
    'Espèces rares',
    'À vérifier',
    'Plus populaires',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.activeFilter;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtres de recherche',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Catégorie d\'observations',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.primaryAction,
                backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text('Uniquement les observations validées', style: TextStyle(color: textPrimary, fontSize: 14)),
            subtitle: Text('Exclut les détections IA non vérifiées', style: TextStyle(color: textSecondary, fontSize: 12)),
            value: _onlyVerified,
            activeColor: AppColors.primaryAction,
            onChanged: (val) => setState(() => _onlyVerified = val),
          ),
          SwitchListTile(
            title: Text('Floutage des zones sensibles', style: TextStyle(color: textPrimary, fontSize: 14)),
            subtitle: Text('Masque la géolocalisation exacte des nidifications rares', style: TextStyle(color: textSecondary, fontSize: 12)),
            value: _hideSensitiveLocations,
            activeColor: AppColors.primaryAction,
            onChanged: (val) => setState(() => _hideSensitiveLocations = val),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAction,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context, _selectedCategory),
              child: const Text('Appliquer les filtres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
