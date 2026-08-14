import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import 'loading_transition_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isRegisterMode && username.isEmpty)) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);

      if (_isRegisterMode) {
        await apiClient.dio.post('/api/v1/auth/register', data: {
          'email': email,
          'username': username,
          'password': password,
          'full_name': username,
        });
      }

      final response = await apiClient.dio.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['access_token'] as String?;
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoadingTransitionScreen()),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      String errorMsg = 'Erreur serveur ou problème réseau.';
      if (e.response != null && e.response?.data != null) {
         final data = e.response?.data;
         if (data is Map<String, dynamic>) {
           if (data['detail'] is String) {
             errorMsg = data['detail'];
           } else if (data['detail'] is List) {
             errorMsg = (data['detail'] as List).first['msg'].toString();
             if (errorMsg.contains('String should have at least')) {
                 errorMsg = 'Le champ est trop court.';
             } else if (errorMsg.contains('String should match pattern')) {
                 errorMsg = 'Nom d\'utilisateur invalide (pas d\'espaces).';
             }
           }
         }
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Une erreur inattendue est survenue.';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sur le web, le clientId doit être configuré. On le passe explicitement pour éviter tout bug.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '155881539135-jl1m1fo4ufju4dobaek5s1smtm3rmr87.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        setState(() {
          _errorMessage = "Impossible de récupérer le jeton Google.";
          _isLoading = false;
        });
        return;
      }

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post('/api/v1/auth/google', data: {
        if (idToken != null) 'id_token': idToken,
        if (accessToken != null) 'access_token': accessToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['access_token'] as String?;
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoadingTransitionScreen()),
      );
    } catch (e) {
      print("Google sign in exception: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "Erreur de connexion Google. Le Client ID est-il configuré ?";
        _isLoading = false;
      });
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoadingTransitionScreen()),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _errorMessage = null;
    });
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with gradient overlay
          Image.asset(
            'assets/birds/aigle_pecheur.png', // Un bel oiseau en fond
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Form Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & App Name
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAction.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BirdSense AI',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRegisterMode ? 'Rejoignez la communauté des ornithologues' : 'Ravi de vous revoir',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Glassmorphism Card (Simplified for Web performance)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6), // Dark semi-transparent instead of blur
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Input Fields
                              if (_isRegisterMode) ...[
                                _buildTextField(
                                  controller: _usernameController,
                                  hint: 'Nom d\'utilisateur',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildTextField(
                                controller: _emailController,
                                hint: 'Adresse Email',
                                icon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                hint: 'Mot de passe',
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              
                              const SizedBox(height: 24),

                              // Main Action Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _submitAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAction,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text(
                                        _isRegisterMode ? 'Créer mon compte' : 'Se Connecter',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('OU', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                  ),
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Google Sign-In Button
                              OutlinedButton.icon(
                                onPressed: _isLoading ? null : _signInWithGoogle,
                                icon: Image.asset(
                                  'assets/google_logo.png',
                                  width: 24, height: 24,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
                                ),
                                label: const Text(
                                  'Continuer avec Google',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Toggle Register / Login
                      TextButton(
                        onPressed: _toggleMode,
                        child: RichText(
                          text: TextSpan(
                            text: _isRegisterMode ? 'Déjà un compte ? ' : 'Pas encore de compte ? ',
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            children: [
                              TextSpan(
                                text: _isRegisterMode ? 'Se connecter' : 'S\'inscrire',
                                style: const TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Guest Mode
                      TextButton(
                        onPressed: _continueAsGuest,
                        child: Text(
                          'Continuer en mode Invité',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
