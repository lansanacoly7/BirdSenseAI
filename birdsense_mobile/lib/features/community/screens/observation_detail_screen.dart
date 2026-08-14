import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/community_models.dart';
import '../widgets/community_validation_modal.dart';

class ObservationDetailScreen extends StatefulWidget {
  final CommunityObservation observation;

  const ObservationDetailScreen({super.key, required this.observation});

  @override
  State<ObservationDetailScreen> createState() => _ObservationDetailScreenState();
}

class _ObservationDetailScreenState extends State<ObservationDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<CommentModel> _comments = [
    CommentModel(
      id: 'c-1',
      userName: 'Massogui Diop',
      userAvatar: 'assets/logo.png',
      content: 'Superbe prise de vue ! La coloration du bec est très caractéristique.',
      timeAgo: 'Il y a 10 min',
    ),
    CommentModel(
      id: 'c-2',
      userName: 'Pathé Fall',
      userAvatar: 'assets/logo.png',
      content: 'Confirmé. On observe ce comportement d\'alimentation en groupe sur la lagune.',
      timeAgo: 'Il y a 5 min',
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.add(
        CommentModel(
          id: DateTime.now().toIso8601String(),
          userName: 'Vous',
          userAvatar: 'assets/logo.png',
          content: _commentController.text.trim(),
          timeAgo: 'À l\'instant',
        ),
      );
      widget.observation.commentsCount += 1;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final obs = widget.observation;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail de l\'observation',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primaryAction),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carte de partage générée pour vos réseaux.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grande photo
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Image.asset(
                    obs.imageUrl,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
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
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: obs.validationStatus.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
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
            const SizedBox(height: 20),

            // Noms & Infos de l'espèce
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(obs.speciesNameFr, style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
                      Text(obs.speciesNameScientific, style: TextStyle(color: textSecondary, fontSize: 15, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAction.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${obs.count} individu${obs.count > 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profil de l'observateur
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage(obs.userAvatar), radius: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(obs.userName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(obs.userLevel, style: TextStyle(color: AppColors.primaryAction, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: textSecondary),
                            const SizedBox(width: 4),
                            Text(obs.locationLabel, style: TextStyle(color: textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section "Pourquoi cette identification ?" (Explicabilité IA)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryAction.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_rounded, color: AppColors.primaryAction),
                      SizedBox(width: 10),
                      Text(
                        'Pourquoi cette identification ?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryAction),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    obs.aiReasoning,
                    style: TextStyle(fontSize: 13, color: textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note : L\'IA fournit une estimation probabiliste et ne remplace pas l\'expertise naturaliste.',
                    style: TextStyle(fontSize: 11, color: textSecondary, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bouton Validation si "À vérifier"
            if (obs.validationStatus == ValidationStatus.needsReview)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAction,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.help_center_rounded),
                  label: const Text('Je peux aider à identifier', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommunityValidationModal(observation: obs),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            Text('Commentaires (${_comments.length})', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Liste des commentaires
            ..._comments.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(backgroundImage: AssetImage(c.userAvatar), radius: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(c.userName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(c.timeAgo, style: TextStyle(color: textSecondary, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(c.content, style: TextStyle(color: textPrimary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 12),
            // Saisie de commentaire
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ajouter une précision ou commenter...',
                      hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primaryAction),
                  onPressed: _addComment,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
