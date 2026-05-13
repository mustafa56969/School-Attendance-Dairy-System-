import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/playful_theme.dart';

class PlayfulNavRail extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavRailItem> items;
  final Widget? avatar;

  const PlayfulNavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.avatar,
  });

  @override
  State<PlayfulNavRail> createState() => _PlayfulNavRailState();
}

class _PlayfulNavRailState extends State<PlayfulNavRail> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo Blob
          _buildLogoBlo(),
          const SizedBox(height: 48),
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return _buildNavItem(index);
              },
            ),
          ),
          // Avatar
          if (widget.avatar != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.avatar!,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogoBlo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: PlayfulTheme.primaryDark,
            borderRadius: BorderRadius.circular(
              30 + (10 * (0.5 - (value - 0.5).abs())),
            ),
            boxShadow: [
              BoxShadow(
                color: PlayfulTheme.primaryDark.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            color: Colors.white,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: GestureDetector(
              onTap: () {
                widget.onDestinationSelected(index);
                _controllers[index].forward().then((_) {
                  _controllers[index].reverse();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? item.color : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  item.icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavRailItem {
  final IconData icon;
  final String label;
  final Color color;

  const NavRailItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
