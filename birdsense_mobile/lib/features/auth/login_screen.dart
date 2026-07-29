import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../navigation/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Navigate to Main Application Navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.flutter_dash, size: 72, color: AppColors.accentAmber),
              const SizedBox(height: 16),
              const Text(
                'BirdSense AI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Suivi & Détection Intelligente de la Biodiversité',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email d\'ornithologue',
                  prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _login,
                child: const Text('Se Connecter'),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: _login,
                child: const Text(
                  'Continuer en mode Invité / Hors-Ligne',
                  style: TextStyle(color: AppColors.accentAmber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
