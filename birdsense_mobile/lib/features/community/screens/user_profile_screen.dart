import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/community_models.dart';

class UserProfileScreen extends StatelessWidget {
  final UserProfileModel profile;

  const UserProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profil Contributeur', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Niveau
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(profile.avatarUrl),
                    radius: 46,
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name, style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(profile.handle, style: TextStyle(color: textSecondary, fontSize: 14)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${profile.levelTitle} (Niveau ${profile.levelNumber})',
                      style: const TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Statistiques principales
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Observations', '${profile.totalObservations}', textPrimary, textSecondary),
                  Container(height: 36, width: 1, color: textSecondary.withOpacity(0.2)),
                  _buildStatItem('Espèces', '${profile.totalSpecies}', textPrimary, textSecondary),
                  Container(height: 36, width: 1, color: textSecondary.withOpacity(0.2)),
                  _buildStatItem('Validations', '${profile.totalValidations}', textPrimary, textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Badges d'expertise
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Badges & Distinctions', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: profile.badges.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF1C40F), size: 18),
                      const SizedBox(width: 8),
                      Text(badge, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }
}
