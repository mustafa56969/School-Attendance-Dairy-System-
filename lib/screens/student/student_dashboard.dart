import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/playful_theme.dart';
import 'tabs/student_home_tab.dart';
import 'tabs/student_subjects_tab.dart';
import 'tabs/student_notes_tab.dart';
import 'tabs/student_profile_tab.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  DateTime _selectedDate = DateTime.now();

  final List<Widget> _tabs = [
    StudentHomeTab(
      selectedDate: DateTime.now(),
      onDateChanged: (DateTime date) {},
    ),
    StudentSubjectsTab(),
    StudentNotesTab(),
    StudentProfileTab(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          children: [
            StudentHomeTab(
              selectedDate: _selectedDate,
              onDateChanged: (DateTime date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const StudentSubjectsTab(),
            const StudentNotesTab(),
            const StudentProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: PlayfulTheme.primaryTeal,
            unselectedItemColor: PlayfulTheme.textSecondary,
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Subjects',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit_note_rounded),
                activeIcon: Icon(Icons.edit_note_rounded),
                label: 'Notes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
