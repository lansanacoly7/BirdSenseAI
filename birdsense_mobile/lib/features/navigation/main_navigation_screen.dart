import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../camera_detection/camera_view_screen.dart';
import '../observation_map/observation_map_screen.dart';
import '../species_catalog/species_catalog_screen.dart';
import '../dashboard/analytics_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CameraViewScreen(), // index 0 (will not be used via bottom nav directly, handled via FAB)
    ObservationMapScreen(), // index 1
    SpeciesCatalogScreen(), // index 2
    AnalyticsDashboardScreen(), // index 3
  ];

  @override
  Widget build(BuildContext context) {
    // Determine which screen to show based on standard indices, but overriding 0 for Camera
    Widget currentScreen = _currentIndex == 0 ? const CameraViewScreen() : _screens[_currentIndex];

    return Scaffold(
      body: currentScreen,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 0; // Focus Camera
          });
        },
        backgroundColor: _currentIndex == 0 ? AppColors.primaryAction : AppColors.surface,
        elevation: _currentIndex == 0 ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Icon(
          Icons.camera_alt, 
          color: _currentIndex == 0 ? Colors.white : AppColors.primaryAction,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(
              icon: Icons.map_outlined, 
              activeIcon: Icons.map, 
              label: 'Carte', 
              index: 1,
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavButton(
              icon: Icons.grid_view_outlined, 
              activeIcon: Icons.grid_view, 
              label: 'Espèces', 
              index: 2,
            ),
            _buildNavButton(
              icon: Icons.bar_chart_outlined, 
              activeIcon: Icons.bar_chart, 
              label: 'Stats', 
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required IconData activeIcon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primaryAction : AppColors.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryAction : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
