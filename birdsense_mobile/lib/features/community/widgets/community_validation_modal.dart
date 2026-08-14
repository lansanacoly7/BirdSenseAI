import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/community_models.dart';

class CommunityValidationModal extends StatefulWidget {
  final CommunityObservation observation;

  const CommunityValidationModal({super.key, required this.observation});

  @override
  State<CommunityValidationModal> createState() => _CommunityValidationModalState();
}

class _CommunityValidationModalState extends State<CommunityValidationModal> {
  late String _selectedSpecies;
  double _confidence = 85.0;
  final TextEditingController _commentController = TextEditingController();

  final List<String> _speciesOptions = [
    'Aigrette garzette',
    'Pélican blanc',
    'Aigle pêcheur d\'Afrique',
    'Flamant rose',
    'Héron garde-bœufs',
    'Sterne royale',
    'Vautour charognard',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.observation.speciesNameFr;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                'Aider à l\'identification',
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
          const SizedBox(height: 8),
          Text(
            'Proposer votre expertise communautaire pour valider ou corriger cette détection.',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 20),

          // Choix d'espèce
          Text(
            'Espèce proposée :',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSpecies,
                isExpanded: true,
                dropdownColor: cardBg,
                items: _speciesOptions.map((species) {
                  return DropdownMenuItem(
                    value: species,
                    child: Text(species, style: TextStyle(color: textPrimary)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSpecies = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Curseur de certitude
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre niveau de certitude :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
              ),
              Text(
                '${_confidence.toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAction,
                ),
              ),
            ],
          ),
          Slider(
            value: _confidence,
            min: 50,
            max: 100,
            divisions: 10,
            activeColor: AppColors.primaryAction,
            onChanged: (val) => setState(() => _confidence = val),
          ),

          const SizedBox(height: 12),
          // Explication textuelle
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Justification (ex: La forme du bec et la silhouette suggèrent plutôt...)',
              hintStyle: TextStyle(color: textSecondary.withOpacity(0.6), fontSize: 13),
              filled: true,
              fillColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bouton d'envoi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAction,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'species': _selectedSpecies,
                  'confidence': _confidence.toInt(),
                  'comment': _commentController.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Merci ! Votre contribution de validation a été soumise à la communauté.'),
                    backgroundColor: AppColors.primaryAction,
                  ),
                );
              },
              child: const Text(
                'Soumettre ma validation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
