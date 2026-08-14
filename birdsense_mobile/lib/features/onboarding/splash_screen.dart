import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Artificial delay to show the loading screen for better UX
    await Future.delayed(const Duration(seconds: 2));

    String? hasSeenOnboarding;
    try {
      if (kIsWeb) {
        // flutter_secure_storage peut bloquer indéfiniment sur le web dans certaines configurations.
        // On simule une valeur nulle pour la démo ou on pourrait utiliser shared_preferences.
        hasSeenOnboarding = null;
      } else {
        const storage = FlutterSecureStorage();
        hasSeenOnboarding = await storage.read(key: 'has_seen_onboarding').timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      print('Erreur secure storage: $e');
      hasSeenOnboarding = null;
    }

    if (!mounted) return;

    if (hasSeenOnboarding == 'true') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.flutter_dash,
                    size: 100,
                    color: AppColors.primaryAction,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'BirdSense AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 60),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAction),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
