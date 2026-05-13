import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';
import 'vibrant_student_home.dart';
import 'tabs/student_attendance_tab.dart';
import 'vibrant_student_notes.dart';
import 'vibrant_student_profile.dart';

class VibrantStudentDashboard extends StatefulWidget {
  const VibrantStudentDashboard({super.key});

  @override
  State<VibrantStudentDashboard> createState() =>
      _VibrantStudentDashboardState();
}

class _VibrantStudentDashboardState extends State<VibrantStudentDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _tabs = [
    const VibrantStudentHome(),
    const StudentAttendanceTab(),
    const VibrantStudentNotes(),
    const VibrantStudentProfile(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: PlayfulTheme.primaryTeal,
            unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              _buildNavItem(Icons.home_filled, Icons.home_outlined, 'Home'),
              _buildNavItem(
                Icons.how_to_reg,
                Icons.how_to_reg_outlined,
                'Attendance',
              ),
              _buildNavItem(
                Icons.note_alt_rounded,
                Icons.note_alt_outlined,
                'Notes',
              ),
              _buildNavItem(
                Icons.person_rounded,
                Icons.person_outlined,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(inactiveIcon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}
