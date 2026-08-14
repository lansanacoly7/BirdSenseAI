import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../navigation/main_navigation_screen.dart';

class LoadingTransitionScreen extends StatefulWidget {
  const LoadingTransitionScreen({super.key});

  @override
  State<LoadingTransitionScreen> createState() => _LoadingTransitionScreenState();
}

class _LoadingTransitionScreenState extends State<LoadingTransitionScreen> {
  @override
  void initState() {
    super.initState();
    _transitionToApp();
  }

  Future<void> _transitionToApp() async {
    // Artificial delay to show the loading screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
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
                  return const Icon(
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
              'Préparation de votre espace...',
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
