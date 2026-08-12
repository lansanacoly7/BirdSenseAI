import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/audio_waveform_widget.dart';
import 'offline_map_manager.dart';
import 'mbtiles_tile_provider.dart';

class ObservationMapScreen extends ConsumerStatefulWidget {
  const ObservationMapScreen({super.key});

  @override
  ConsumerState<ObservationMapScreen> createState() => _ObservationMapScreenState();
}

class _ObservationMapScreenState extends ConsumerState<ObservationMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final OfflineMapManager _offlineManager = OfflineMapManager();
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  
  // Coordonnées du Parc National des Oiseaux du Djoudj
  final LatLng _djoudjCenter = LatLng(16.4258, -16.2333);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchObservations();
    });
  }

  List<Marker> _markers = [];
  bool _isLoading = false;

  Future<void> _fetchObservations() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/api/v1/observations/map',
        data: {
          "min_lat": -90.0,
          "min_lon": -180.0,
          "max_lat": 90.0,
          "max_lon": 180.0,
          "limit": 500
        },
      );
      final points = response.data['points'] as List;
      final newMarkers = points.map((p) {
        final lat = p['latitude'];
        final lon = p['longitude'];
        final isProtected = p['has_protected_species'] == true;
        final thumb = p['thumbnail_url'] ?? 'assets/birds/pelican_blanc.png'; 
        return _buildPremiumMarker(
          LatLng(lat, lon),
          thumb,
          isProtected ? AppColors.iucnEndangered : AppColors.primaryAction,
          isAlert: isProtected,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    } catch (e) {
      debugPrint("Erreur map: $e");
      if (mounted) {
        setState(() {
          _markers = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }



  Marker _buildPremiumMarker(LatLng point, String asset, Color borderColor, {bool isAlert = false}) {
    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isAlert)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withOpacity(0.3),
              ),
            ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(color: borderColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: ClipOval(
              child: asset.startsWith('http') 
                  ? Image.network(asset, fit: BoxFit.cover)
                  : Image.asset(asset, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.pets, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _goToDjoudj() {
    _mapController.move(_djoudjCenter, 12);
  }

  void _showOfflineSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGlassBottomSheet(
        child: ListenableBuilder(
          listenable: _offlineManager,
          builder: (context, _) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
            final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Text('Cartes Hors-Ligne', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 8),
                Text('Téléchargez les zones pour une utilisation sans réseau.', style: TextStyle(color: textSecondary)),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _offlineManager.availablePacks.length,
                    itemBuilder: (context, index) {
                      final pack = _offlineManager.availablePacks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pack.regionName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
                                const SizedBox(height: 4),
                                Text('${pack.estimatedSizeMb} MB', style: TextStyle(color: textSecondary, fontSize: 13)),
                              ],
                            ),
                            if (pack.status == OfflinePackStatus.downloading)
                              const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryAction)
                            else if (pack.status == OfflinePackStatus.downloaded)
                              IconButton(icon: const Icon(Icons.delete_rounded, color: AppColors.iucnEndangered), onPressed: () => _offlineManager.deletePack(pack.id))
                            else
                              IconButton(
                                icon: const Icon(Icons.cloud_download_rounded, color: AppColors.primaryAction, size: 28),
                                onPressed: () => _offlineManager.downloadPack(pack.id),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }
        ),
      ),
    );
  }

  void _showAudioScanner() {
    bool isListening = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

          return _buildGlassBottomSheet(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 32),
                Text('Scan Bioacoustique', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 8),
                Text(isListening ? 'Analyse de l\'environnement...' : 'Scan terminé', style: TextStyle(color: textSecondary)),
                const SizedBox(height: 48),
                AudioWaveformWidget(isRecording: isListening),
                const SizedBox(height: 48),
                if (isListening)
                  InkWell(
                    onTap: () => setStateModal(() => isListening = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.iucnEndangered.withOpacity(0.8), AppColors.iucnEndangered]),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [BoxShadow(color: AppColors.iucnEndangered.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Text('Arrêter l\'écoute', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.primaryAction.withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryAction, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text('Pélican Blanc détecté !', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textPrimary)),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAction,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Text('Voir la fiche', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassBottomSheet({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkBackground : AppColors.lightBackground).withOpacity(0.75),
            border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1))),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _djoudjCenter,
              initialZoom: 12.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.birdsense.app',
              ),
              // Hotspots (Heatmap simulation)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _djoudjCenter,
                    color: AppColors.primaryAction.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: AppColors.primaryAction,
                    useRadiusInMeter: true,
                    radius: 3000, // 3km radius
                  ),
                  CircleMarker(
                    point: LatLng(16.44, -16.22),
                    color: AppColors.iucnEndangered.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: AppColors.iucnEndangered,
                    useRadiusInMeter: true,
                    radius: 1500,
                  ),
                ],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAction),
            ),

          // Top HUD Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Rechercher une espèce, un parc...',
                            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primaryAction.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.tune_rounded, color: AppColors.primaryAction, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating Action Pills (Right Side)
          Positioned(
            right: 20,
            bottom: 220, // Remonté pour éviter le navbar
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildPillButton(Icons.add_rounded, _zoomIn, isDark),
                      _buildDivider(isDark),
                      _buildPillButton(Icons.remove_rounded, _zoomOut, isDark),
                      _buildDivider(isDark),
                      _buildPillButton(Icons.my_location_rounded, _goToDjoudj, isDark, color: AppColors.primaryAction),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action Pills (Left Side)
          Positioned(
            left: 20,
            bottom: 220, // Remonté pour éviter le navbar
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildPillButton(Icons.mic_rounded, _showAudioScanner, isDark, color: AppColors.accent),
                      _buildDivider(isDark),
                      _buildPillButton(Icons.cloud_download_rounded, _showOfflineSheet, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Info Sheet (Live Feed) - Surélevé pour ne pas être caché par la NavBar
          Positioned(
            bottom: 110, // CHANGEMENT ICI: Surélevé au dessus de la NavBar
            left: 20,
            right: 20,
            child: SlideTransition(
              position: _slideAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/birds/pelican_blanc.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(color: AppColors.primaryAction, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Observation en direct',
                                    style: TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Troupeau de Pélicans Blancs',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Il y a 2 minutes • Parc National du Djoudj',
                                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.primaryAction),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton(IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          color: color ?? (isDark ? Colors.white : Colors.black87),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 24,
      height: 1,
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
    );
  }
}
