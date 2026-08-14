import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onIntroEnd(context) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'has_seen_onboarding', value: 'true');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String imagePath,
    required bool isDark,
  }) {
    return Stack(
      children: [
        // Image en plein écran
        Positioned.fill(
          child: imagePath.endsWith('.png') && imagePath.contains('logo')
              ? Container(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(imagePath, height: 200, width: 200, fit: BoxFit.contain),
                    ),
                  ),
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
        ),
        // Dégradé noir pour la lisibilité
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),
        // Texte positionné en bas
        Positioned(
          bottom: 120, // Espace pour les boutons de navigation
          left: 40,
          right: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Toujours blanc grâce au dégradé noir
                ),
              ),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildPage(
                title: "Bienvenue sur BirdSense AI",
                description: "Votre compagnon intelligent pour identifier et recenser les espèces d'oiseaux du Sénégal.",
                imagePath: 'assets/logo.png',
                isDark: isDark,
              ),
              _buildPage(
                title: "Détection par IA",
                description: "Prenez une photo et laissez notre Intelligence Artificielle reconnaître l'espèce avec précision en quelques secondes.",
                imagePath: 'assets/birds/aigle_pecheur.png',
                isDark: isDark,
              ),
              _buildPage(
                title: "Votre Catalogue Personnel",
                description: "Gardez une trace de toutes vos observations, synchronisées sur le cloud et consultables même hors ligne.",
                imagePath: 'assets/birds/flamant_rose.png',
                isDark: isDark,
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentPage != 2
                    ? TextButton(
                        onPressed: () => _onIntroEnd(context),
                        child: const Text(
                          "Passer",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : const SizedBox(width: 64),
                Row(
                  children: List.generate(
                    3,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryAction
                            : Colors.white30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                _currentPage != 2
                    ? TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          "Suivant",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAction,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => _onIntroEnd(context),
                        child: const Text("Commencer"),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
