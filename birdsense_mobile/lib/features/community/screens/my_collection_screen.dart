import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/community_mock_data.dart';

class MyCollectionScreen extends StatelessWidget {
  const MyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final collection = CommunityMockData.getCollection();
    final unlockedCount = collection.where((c) => c.isUnlocked).length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ma Collection Personnelle', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progression globale
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.primaryAction, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progression du Catalogue', style: TextStyle(color: textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '$unlockedCount / ${collection.length} espèces débloquées',
                          style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: unlockedCount / collection.length,
                            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAction),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('Album des Espèces du Sénégal', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Grille des espèces
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: collection.length,
              itemBuilder: (context, index) {
                final item = collection[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                color: item.isUnlocked ? null : Colors.black87,
                                colorBlendMode: item.isUnlocked ? null : BlendMode.saturation,
                              ),
                              if (!item.isUnlocked)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.lock_rounded, color: Colors.white70, size: 24),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.speciesFr,
                              style: TextStyle(
                                color: item.isUnlocked ? textPrimary : textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.isUnlocked ? (item.firstObservedDate ?? 'Débloqué') : 'Non observée',
                              style: TextStyle(
                                color: item.isUnlocked ? AppColors.primaryAction : textSecondary.withOpacity(0.6),
                                fontSize: 11,
                                fontWeight: item.isUnlocked ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
