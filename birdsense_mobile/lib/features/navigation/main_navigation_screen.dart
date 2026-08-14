import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../camera_detection/camera_view_screen.dart';

import '../observation_map/observation_map_screen.dart';
import '../species_catalog/species_catalog_screen.dart';
import '../dashboard/analytics_dashboard_screen.dart';
import '../chat/chat_screen.dart';
import '../community/screens/community_feed_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 1; // Start on Map (Index 1)

  // Only 4 screens — Chat is full-screen push, not a tab
  final List<Widget> _screens = const [
    CameraViewScreen(),        // index 0
    ObservationMapScreen(),    // index 1
    SpeciesCatalogScreen(),    // index 2
    AnalyticsDashboardScreen(),// index 3
    CommunityFeedScreen(),     // index 4
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentScreen = _screens[_currentIndex];

    // Colors for navbar
    final navBgColor = isDark
        ? const Color(0xFF162235).withOpacity(0.85)
        : Colors.white.withOpacity(0.85);

    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);

    return Scaffold(
      extendBody: true, // Allow body to stretch behind floating navbar
      body: currentScreen,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 0; // Focus Camera
          });
        },
        backgroundColor: AppColors.primaryAction,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: navBgColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavTab(
                    icon: Icons.map_outlined,
                    activeIcon: Icons.map_rounded,
                    label: 'Carte',
                    index: 1,
                    isDark: isDark,
                  ),
                  _buildNavTab(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: 'Espèces',
                    index: 2,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 48), // Space for FAB Camera
                  // Assistant IA — opens full-screen (no navbar)
                  _buildNavTab(
                    icon: Icons.smart_toy_outlined,
                    activeIcon: Icons.smart_toy_rounded,
                    label: 'Assistant IA',
                    index: -1, // Special: navigates full-screen
                    isDark: isDark,
                    onTapOverride: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const ChatScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                  _buildNavTab(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'Stats',
                    index: 3,
                    isDark: isDark,
                  ),
                  _buildNavTab(
                    icon: Icons.groups_outlined,
                    activeIcon: Icons.groups_rounded,
                    label: 'Communauté',
                    index: 4,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
    VoidCallback? onTapOverride,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primaryAction;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTapOverride ?? () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
