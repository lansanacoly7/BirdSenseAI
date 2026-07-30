import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/audio_waveform_widget.dart';
import 'offline_map_manager.dart';
import 'mbtiles_tile_provider.dart';

class ObservationMapScreen extends StatefulWidget {
  const ObservationMapScreen({super.key});

  @override
  State<ObservationMapScreen> createState() => _ObservationMapScreenState();
}

class _ObservationMapScreenState extends State<ObservationMapScreen> {
  final MapController _mapController = MapController();
  final OfflineMapManager _offlineManager = OfflineMapManager();
  
  // Coordonnées du Parc National des Oiseaux du Djoudj
  final LatLng _djoudjCenter = const LatLng(16.4258, -16.2333);

  // Exemple de points d'observations
  final List<Marker> _markers = [
    Marker(
      point: const LatLng(16.43, -16.23),
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: AppColors.primaryAction, size: 36),
    ),
    Marker(
      point: const LatLng(16.42, -16.24),
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: AppColors.accent, size: 36),
    ),
    Marker(
      point: const LatLng(16.44, -16.22),
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: AppColors.iucnEndangered, size: 36),
    ),
  ];

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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ListenableBuilder(
        listenable: _offlineManager,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cartes Hors-Ligne',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Téléchargez les cartes pour une utilisation en zone blanche.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
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
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pack.regionName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pack.estimatedSizeMb} MB',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                            if (pack.status == OfflinePackStatus.downloading)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAction),
                              )
                            else if (pack.status == OfflinePackStatus.downloaded)
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.iucnEndangered),
                                onPressed: () => _offlineManager.deletePack(pack.id),
                              )
                            else
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAction,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Pack'),
                                onPressed: () => _offlineManager.downloadPack(pack.id),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAudioScanner() {
    bool isListening = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scan Bioacoustique',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isListening ? 'Écoute de l\'environnement en cours...' : 'Scan terminé',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                AudioWaveformWidget(isRecording: isListening),
                const SizedBox(height: 40),
                if (isListening)
                  ElevatedButton(
                    onPressed: () {
                      setStateModal(() => isListening = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.iucnEndangered, // Red stop
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Text('Arrêter l\'écoute', style: TextStyle(color: Colors.white)),
                  )
                else
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primaryAction, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Pélican Blanc détecté !',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Voir les détails'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              heroTag: 'btn_audio',
              backgroundColor: AppColors.surface,
              onPressed: _showAudioScanner,
              child: const Icon(Icons.mic, color: AppColors.primaryAction),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              heroTag: 'btn_offline',
              backgroundColor: AppColors.surface,
              onPressed: _showOfflineSheet,
              child: const Icon(Icons.cloud_download_outlined, color: AppColors.primaryAction),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // The Actual Interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _djoudjCenter,
              initialZoom: 12.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.birdsense.app',
              ),
              // Extension : Couche Hors-Ligne (MBTiles)
              TileLayer(
                urlTemplate: '',
                tileProvider: MbTilesTileProvider(mbtilesPath: 'assets/maps/djoudj.mbtiles'),
                backgroundColor: Colors.transparent,
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // Floating Controls
          Positioned(
            right: 16,
            bottom: 150,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: AppColors.surface,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: AppColors.surface,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_loc',
                  backgroundColor: AppColors.primaryAction,
                  onPressed: _goToDjoudj,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),

          // Bottom Info Sheet
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.park, color: AppColors.primaryAction, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Parc National du Djoudj',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '142 observations enregistrées cette semaine',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
