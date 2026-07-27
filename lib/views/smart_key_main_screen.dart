import 'package:flutter/material.dart';

/// SmartKey Main Screen
/// A modern, clean, and production-ready main screen for the SmartKey smart control app.
class SmartKeyMainScreen extends StatefulWidget {
  const SmartKeyMainScreen({super.key});

  @override
  State<SmartKeyMainScreen> createState() => _SmartKeyMainScreenState();
}

class _SmartKeyMainScreenState extends State<SmartKeyMainScreen> {
  int _currentBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F1FD), // Light blue tint
              Color(0xFFF7FAFE), // Subtle blue-white transition
              Colors.white,      // Pure white at bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top App Bar / Header
              const _TopHeader(),
              const SizedBox(height: 16),

              // 2. AI Search & Command Bar
              const _AiSearchBar(),
              const SizedBox(height: 24),

              // 3. Favorites Section Header
              const _FavoritesHeader(),

              // 4. Main Content / Centered Empty State
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: const _EmptyStateWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // 5. Bottom Navigation Bar
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Top Header Widget
/// Contains Profile Avatar on Left, Plus Badge & Add Button on Right
/// ---------------------------------------------------------------------------
class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Profile Avatar with thin border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF4A5568),
                size: 24,
              ),
            ),
          ),

          // Right action buttons: Light-purple "Plus" pill badge & Standard "+" Button
          Row(
            children: [
              // Rounded light-purple "Plus" pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF), // Light purple badge
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD8B4FE).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: Color(0xFF7E22CE),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Plus',
                      style: TextStyle(
                        color: Color(0xFF7E22CE),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Standard "+" icon button inside subtle circular container
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// AI Search & Command Bar Widget
/// Features a vibrant multi-color gradient border and glow effect
/// ---------------------------------------------------------------------------
class _AiSearchBar extends StatelessWidget {
  const _AiSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Multi-color gradient border
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B5CF6), // Purple
              Color(0xFFEC4899), // Pink
              Color(0xFF3B82F6), // Blue
              Color(0xFF10B981), // Emerald
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.20),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2.0), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Multi-color AI Swirl / Sparkle Icon
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFEC4899),
                    Color(0xFF8B5CF6),
                    Color(0xFF3B82F6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Placeholder Text
              const Expanded(
                child: Text(
                  'How can I help?',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Microphone Icon
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Settings / Sliders Icon on Far Right
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Favorites Section Header Widget
/// Bold title text "Favorites" with a dropdown chevron icon aligned to the right
/// ---------------------------------------------------------------------------
class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Favorites',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF334155),
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Empty State Main Content Widget
/// Displays "Add your first device" heading, subtitle, and "Add Now" pill button
/// ---------------------------------------------------------------------------
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Subtle decorative icon container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.devices_other_rounded,
            size: 38,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 24),

        // Main Heading
        const Text(
          'Add your first device',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Connect a device and let AI control it for you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Action Button: Solid black, rounded pill-shaped button
        ElevatedButton(
          onPressed: () {
            // Handle Add Device action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A), // Solid dark black
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Add Now',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Custom Bottom Navigation Bar Widget
/// 4 distinct tabs with badge indicator on Explore
/// ---------------------------------------------------------------------------
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home Tab (Active)
              _NavBarItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: onTap,
              ),

              // 2. Smart Tab (Square with checkmark)
              _NavBarItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.check_box_outlined,
                label: 'Smart',
                onTap: onTap,
              ),

              // 3. Explore Tab (Hexagonal icon with red dot notification)
              _NavBarItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.widgets_outlined, // Hexagonal/geometric style
                label: 'Explore',
                hasNotification: true,
                onTap: onTap,
              ),

              // 4. Me Tab (User outline icon)
              _NavBarItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.person_outline_rounded,
                label: 'Me',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget for individual navigation item
class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final bool hasNotification;
  final ValueChanged<int> onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    this.hasNotification = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;
    const Color activeColor = Color(0xFF0F172A);
    const Color inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? activeColor : inactiveColor,
                ),
                // Small red notification dot indicator on top-right corner
                if (hasNotification)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
