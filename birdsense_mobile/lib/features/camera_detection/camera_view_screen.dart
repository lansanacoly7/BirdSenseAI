import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/detection_success_dialog.dart';
import '../../core/providers.dart';
import '../chat/chat_screen.dart';
import 'providers/camera_provider.dart';
import '../impact_sync/presentation/widgets/live_audio_level_gauge.dart';

/// Premium Camera View — Modern AI Vision Interface
/// No radar, no scanner, no green rectangles.
/// Clean viewfinder + floating detection cards + premium controls.
class CameraViewScreen extends ConsumerStatefulWidget {
  const CameraViewScreen({super.key});

  @override
  ConsumerState<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends ConsumerState<CameraViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _breatheController;
  late AnimationController _detectionFadeController;
  late Animation<double> _scanLineAnim;
  late Animation<double> _breatheAnim;
  late Animation<double> _detectionFadeAnim;

  bool _flashOn = false;
  bool _showDetections = true;
  bool _isAnalyzing = false;
  XFile? _pickedImage;

  static const List<_MockDetection> _mockDetections = [];

  @override
  void initState() {
    super.initState();

    // Subtle horizontal scan line (not radar)
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _scanLineAnim = Tween<double>(begin: -0.05, end: 1.05).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOutSine),
    );

    // Gentle breathing pulse for viewfinder corners
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Detection cards fade in
    _detectionFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _detectionFadeController.forward();
    });
    _detectionFadeAnim = CurvedAnimation(
      parent: _detectionFadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _breatheController.dispose();
    _detectionFadeController.dispose();
    super.dispose();
  }

  void _onCapture() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen(initialQuestion: "Analyse cette image capturée pour identifier l'oiseau.")),
    );
  }

  Future<void> _onPickGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen(initialQuestion: "Analyse cette image importée pour identifier l'oiseau.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cameraState = ref.watch(cameraProvider);
    
    final activeDetections = cameraState.detections.isNotEmpty
        ? cameraState.detections.map((dto) => _MockDetection(
            name: dto.label,
            scientificName: dto.label.contains('Pélican') ? 'Pelecanus onocrotalus' : 'Phoenicopterus roseus',
            confidence: dto.confidence,
            iucnCategory: 'LC',
            relX: dto.x,
            relY: dto.y,
            relW: dto.width,
            relH: dto.height,
            imageUrl: 'assets/birds/pelican_blanc.png',
          )).toList()
        : _mockDetections;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Simulated Camera Feed (Nature Scene Gradient) ───
          _buildCameraBackground(size),

          // ─── AI Scan Line (Subtle Light Sweep) ───
          _buildScanLine(size),

          // ─── Viewfinder Frame ───
          _buildViewfinder(size),

          // ─── Floating Detection Cards ───
          _buildDetectionOverlays(size, activeDetections),

          // ─── Top HUD Status Bar ───
          _buildTopHUD(activeDetections.length),

          // Audio Level Gauge on the right
          if (cameraState.isRecordingVideo)
            const Positioned(
              right: 16,
              bottom: 150,
              child: LiveAudioLevelGauge(),
            ),

          // ─── Bottom Controls Bar ───
          _buildBottomControls(),

          // ─── AI Analysis Overlay ───
          if (_isAnalyzing) _buildAnalysisOverlay(size),
        ],
      ),
    );
  }

  Widget _buildCameraBackground(Size size) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1628), // Deep navy
            Color(0xFF0D2137), // Dark teal
            Color(0xFF132E3D), // Wetland dusk
            Color(0xFF0A1628),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Nature atmosphere: subtle organic shapes
          Positioned(
            top: size.height * 0.15,
            left: size.width * 0.05,
            child: _buildAtmosphereBlob(120, const Color(0xFF1B4332), 0.15),
          ),
          Positioned(
            top: size.height * 0.35,
            right: size.width * 0.1,
            child: _buildAtmosphereBlob(90, const Color(0xFF14532D), 0.1),
          ),
          Positioned(
            bottom: size.height * 0.3,
            left: size.width * 0.3,
            child: _buildAtmosphereBlob(150, const Color(0xFF0F3D3E), 0.08),
          ),
          // Grid overlay for camera feel
          CustomPaint(
            size: size,
            painter: _ViewfinderGridPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphereBlob(double radius, Color color, double opacity) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildScanLine(Size size) {
    return AnimatedBuilder(
      animation: _scanLineAnim,
      builder: (context, child) {
        final yPos = size.height * _scanLineAnim.value;
        return Positioned(
          left: 0,
          right: 0,
          top: yPos - 30,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.secondaryAction.withOpacity(0.06),
                  AppColors.secondaryAction.withOpacity(0.12),
                  AppColors.secondaryAction.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewfinder(Size size) {
    return AnimatedBuilder(
      animation: _breatheAnim,
      builder: (context, child) {
        return Center(
          child: Container(
            width: size.width * 0.75,
            height: size.height * 0.45,
            child: CustomPaint(
              painter: _ViewfinderCornersPainter(
                opacity: _breatheAnim.value,
                color: AppColors.secondaryAction,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetectionOverlays(Size size, List<_MockDetection> activeDetections) {
    return FadeTransition(
      opacity: _detectionFadeAnim,
      child: Stack(
        children: activeDetections.map((det) {
          return Positioned(
            left: size.width * det.relX,
            top: size.height * det.relY,
            width: size.width * det.relW,
            height: size.height * det.relH,
            child: _DetectionCard(
              detection: det,
              breatheAnim: _breatheAnim,
              onTap: () {
                DetectionSuccessDialog.show(
                  context,
                  speciesName: det.name,
                  scientificName: det.scientificName,
                  confidence: det.confidence,
                  iucnCategory: det.iucnCategory,
                  imageUrl: det.imageUrl,
                  didYouKnow: det.name.contains('Pélican')
                      ? 'Les pélicans blancs pratiquent la pêche coopérative ! Ils se forment en demi-cercle pour rabattre les poissons.'
                      : 'Le flamant n\'est pas rose à la naissance ! C\'est l\'ingestion de caroténoïdes qui teint progressivement ses plumes.',
                  habitat: det.name.contains('Pélican')
                      ? 'Parc National du Djoudj, Sénégal'
                      : 'Lagunes côtières, Lac Rose, Somone',
                  wingspan: det.name.contains('Pélican') ? '2,26 – 3,60 m' : '1,40 – 1,75 m',
                  weight: det.name.contains('Pélican') ? '9 – 15 kg' : '2 – 4 kg',
                  diet: det.name.contains('Pélican')
                      ? 'Piscivore — 1,5 kg/jour'
                      : 'Filtreur d\'invertébrés aquatiques',
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopHUD(int detectionCount) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bird counter badge
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAction,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAction.withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$detectionCount Détection${detectionCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Row(
              children: [
                // Flash Toggle (moved to top)
                GestureDetector(
                  onTap: () => setState(() => _flashOn = !_flashOn),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _flashOn
                              ? AppColors.primaryAction.withOpacity(0.25)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _flashOn
                                ? AppColors.primaryAction.withOpacity(0.5)
                                : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Icon(
                          _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _flashOn ? AppColors.primaryAction : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // AI Engine badge
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryAction.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondaryAction.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.memory_rounded, size: 14, color: AppColors.secondaryAction),
                          const SizedBox(width: 6),
                          Text(
                            'YOLOv8 • 60 FPS',
                            style: TextStyle(
                              color: AppColors.secondaryAction,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              32, 24, 32, MediaQuery.of(context).padding.bottom + 100,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Camera mode label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DÉTECTION IA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Import Button
                    _buildControlButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galerie',
                      isActive: false,
                      onTap: _onPickGallery,
                    ),

                    // Video Button
                    FloatingActionButton.small(
                      heroTag: 'video_btn',
                      backgroundColor: ref.watch(cameraProvider).isRecordingVideo
                          ? Colors.red
                          : AppColors.surfaceDark,
                      onPressed: ref.read(cameraProvider.notifier).toggleVideoRecording,
                      child: Icon(
                        ref.watch(cameraProvider).isRecordingVideo ? Icons.stop : Icons.videocam,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    // Shutter Button
                    GestureDetector(
                      onTap: _onCapture,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Switch Camera
                    _buildControlButton(
                      icon: Icons.cameraswitch_rounded,
                      label: 'Rotation',
                      isActive: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primaryAction.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: isActive
                    ? AppColors.primaryAction.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primaryAction : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisOverlay(Size size) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated scanning icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 2 * math.pi,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondaryAction.withOpacity(0.8),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryAction.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppColors.secondaryAction,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Analyse IA en cours...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Identification de l\'espèce via le réseau neuronal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryAction),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detection Card Widget ───
class _DetectionCard extends StatelessWidget {
  final _MockDetection detection;
  final Animation<double> breatheAnim;
  final VoidCallback onTap;

  const _DetectionCard({
    required this.detection,
    required this.breatheAnim,
    required this.onTap,
  });

  Color _getIucnColor(String cat) {
    switch (cat) {
      case 'LC': return AppColors.iucnLeastConcern;
      case 'NT': return AppColors.iucnNearThreatened;
      case 'VU': return AppColors.iucnVulnerable;
      case 'EN': return AppColors.iucnEndangered;
      case 'CR': return AppColors.iucnCriticallyEndangered;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: breatheAnim,
        builder: (context, child) {
          final opacity = breatheAnim.value;
          return Stack(
            children: [
              // Detection bounding box — elegant corners only
              Positioned.fill(
                child: CustomPaint(
                  painter: _DetectionBoxPainter(
                    color: AppColors.secondaryAction,
                    opacity: opacity * 0.8,
                  ),
                ),
              ),

              // Floating label tag at top
              Positioned(
                top: -1,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryAction.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            detection.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${(detection.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // IUCN badge bottom-right
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getIucnColor(detection.iucnCategory).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    detection.iucnCategory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Data Model ───
class _MockDetection {
  final String name;
  final String scientificName;
  final double confidence;
  final String iucnCategory;
  final double relX, relY, relW, relH;
  final String imageUrl;

  const _MockDetection({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.iucnCategory,
    required this.relX,
    required this.relY,
    required this.relW,
    required this.relH,
    required this.imageUrl,
  });
}

// ─── Custom Painters ───

/// Grid overlay for camera feel
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    // Rule of thirds
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Elegant viewfinder corners (like Apple Camera / Google Lens)
class _ViewfinderCornersPainter extends CustomPainter {
  final double opacity;
  final Color color;

  _ViewfinderCornersPainter({required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLen = 30.0;
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    // Top-Left
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, cornerLen), paint);

    // Top-Right
    canvas.drawLine(r.topRight, r.topRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, cornerLen), paint);

    // Bottom-Left
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -cornerLen), paint);

    // Bottom-Right
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderCornersPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// Elegant detection bounding box — corners only, no full rectangle
class _DetectionBoxPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _DetectionBoxPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.5)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(opacity * 0.04)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, fillPaint);

    const cornerLen = 18.0;

    // Top-Left
    canvas.drawLine(rect.topLeft + const Offset(4, 0), rect.topLeft + Offset(cornerLen, 0), paint);
    canvas.drawLine(rect.topLeft + const Offset(0, 4), rect.topLeft + Offset(0, cornerLen), paint);

    // Top-Right
    canvas.drawLine(rect.topRight + const Offset(-4, 0), rect.topRight + Offset(-cornerLen, 0), paint);
    canvas.drawLine(rect.topRight + const Offset(0, 4), rect.topRight + Offset(0, cornerLen), paint);

    // Bottom-Left
    canvas.drawLine(rect.bottomLeft + const Offset(4, 0), rect.bottomLeft + Offset(cornerLen, 0), paint);
    canvas.drawLine(rect.bottomLeft + const Offset(0, -4), rect.bottomLeft + Offset(0, -cornerLen), paint);

    // Bottom-Right
    canvas.drawLine(rect.bottomRight + const Offset(-4, 0), rect.bottomRight + Offset(-cornerLen, 0), paint);
    canvas.drawLine(rect.bottomRight + const Offset(0, -4), rect.bottomRight + Offset(0, -cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
