import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';
import '../widgets/community_filter_modal.dart';
import '../widgets/community_validation_modal.dart';
import 'observation_detail_screen.dart';
import 'user_profile_screen.dart';
import 'my_collection_screen.dart';
import 'community_map_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  String _activeFilter = 'Toutes';
  String _searchQuery = '';
  late List<CommunityObservation> _observations;

  @override
  void initState() {
    super.initState();
    _observations = CommunityMockData.getObservations();
  }

  void _openFilterModal() async {
    final selectedFilter = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CommunityFilterModal(activeFilter: _activeFilter),
    );
    if (selectedFilter != null) {
      setState(() => _activeFilter = selectedFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final filteredList = _observations.where((obs) {
      final matchesSearch = obs.speciesNameFr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          obs.locationLabel.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_activeFilter == 'Espèces rares') return matchesSearch && obs.isSensitive;
      if (_activeFilter == 'À vérifier') return matchesSearch && obs.validationStatus == ValidationStatus.needsReview;
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Communauté BirdSense',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_rounded, color: AppColors.primaryAction),
            tooltip: 'Ma Collection',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyCollectionScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.primaryAction),
            tooltip: 'Carte Communautaire',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunityMapScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryAction),
            tooltip: 'Mon Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(profile: CommunityMockData.getSampleProfile()),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche + Filtre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: TextField(
                      style: TextStyle(color: textPrimary),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une espèce, une zone...',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAction),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _openFilterModal,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['Toutes', 'Récentes', 'Près de moi', 'Espèces rares', 'À vérifier', 'Plus populaires'].map((cat) {
                final isSelected = cat == _activeFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryAction,
                    backgroundColor: cardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _activeFilter = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Feed list
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Aucune observation trouvée', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final obs = filteredList[index];
                      return _buildObservationCard(obs, isDark, cardBg, textPrimary, textSecondary);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(
    CommunityObservation obs,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête observateur
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundImage: AssetImage(obs.userAvatar),
              radius: 20,
            ),
            title: Text(
              obs.userName,
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: textSecondary),
                const SizedBox(width: 4),
                Text(obs.locationLabel, style: TextStyle(color: textSecondary, fontSize: 12)),
                const SizedBox(width: 8),
                Text('• ${obs.timeAgo}', style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {
                _showReportDialog(obs);
              },
            ),
          ),

          // Image observation avec badges
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ObservationDetailScreen(observation: obs)),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  child: Image.asset(
                    obs.imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Badge de confiance IA
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFF1C40F), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Confiance IA : ${obs.confidenceScore}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge Statut
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: obs.validationStatus.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(obs.validationStatus.icon, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          obs.validationStatus.label,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu sous l'image
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obs.speciesNameFr,
                            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            obs.speciesNameScientific,
                            style: TextStyle(color: textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAction.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${obs.count} individu${obs.count > 1 ? 's' : ''}',
                        style: const TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions (Like, Commenter, Partager, Valider)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            obs.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: obs.isLiked ? const Color(0xFFE74C3C) : textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              obs.isLiked = !obs.isLiked;
                              obs.likesCount += obs.isLiked ? 1 : -1;
                            });
                          },
                        ),
                        Text('${obs.likesCount}', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline_rounded, color: textSecondary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ObservationDetailScreen(observation: obs)),
                            );
                          },
                        ),
                        Text('${obs.commentsCount}', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (obs.validationStatus == ValidationStatus.needsReview)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryAction,
                          backgroundColor: AppColors.primaryAction.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Aider à identifier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => CommunityValidationModal(observation: obs),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(CommunityObservation obs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler l\'observation'),
        content: const Text('Souhaitez-vous signaler cette observation pour contenu inapproprié ou mauvaise géolocalisation ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signalement pris en compte par nos modérateurs.')),
              );
            },
            child: const Text('Signaler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
