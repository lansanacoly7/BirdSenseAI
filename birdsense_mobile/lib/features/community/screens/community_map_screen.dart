import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';
import 'observation_detail_screen.dart';

class CommunityMapScreen extends StatefulWidget {
  const CommunityMapScreen({super.key});

  @override
  State<CommunityMapScreen> createState() => _CommunityMapScreenState();
}

class _CommunityMapScreenState extends State<CommunityMapScreen> {
  final MapController _mapController = MapController();
  CommunityObservation? _selectedObservation;
  late List<CommunityObservation> _observations;

  @override
  void initState() {
    super.initState();
    _observations = CommunityMockData.getObservations();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Carte Communautaire',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // FlutterMap avec OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(14.7167, -17.4677), // Dakar
              initialZoom: 8.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.birdsense.app',
              ),
              MarkerLayer(
                markers: _observations.map((obs) {
                  final isSelected = _selectedObservation?.id == obs.id;
                  return Marker(
                    point: LatLng(obs.latitude, obs.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedObservation = obs);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryAction : obs.validationStatus.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Micro-Fiche preview en bas de carte au clic
          if (_selectedObservation != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ObservationDetailScreen(observation: _selectedObservation!),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
                    ],
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          _selectedObservation!.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedObservation!.speciesNameFr,
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _selectedObservation!.locationLabel,
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _selectedObservation!.validationStatus.color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _selectedObservation!.validationStatus.label,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (_selectedObservation!.isLocationBlurred) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.shield_outlined, size: 14, color: Color(0xFFE74C3C)),
                                  const SizedBox(width: 2),
                                  const Text('Zone Floutée', style: TextStyle(color: Color(0xFFE74C3C), fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ],
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
        ],
      ),
    );
  }
}
