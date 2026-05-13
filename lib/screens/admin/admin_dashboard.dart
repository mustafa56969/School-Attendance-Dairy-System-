import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';
import 'manage_teachers_screen.dart';
import 'assign_subjects_screen.dart';
import 'view_all_diaries_screen.dart';
import 'all_classes_screen.dart';
import 'admin_announcement_screen.dart';
import 'student_messages_screen.dart';
import 'admin_attendance_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _totalStudents = 0;
  int _totalTeachers = 0;
  int _totalClasses = 0;
  int _totalDiaries = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      // Load statistics in parallel
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final teachersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();

      final classesSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();

      final diariesSnapshot = await FirebaseFirestore.instance
          .collection('diaries')
          .get();

      // Extract unique classes
      final uniqueClasses = <String>{};
      for (var doc in classesSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('classId')) {
          uniqueClasses.add(data['classId']);
        }
      }

      setState(() {
        _totalStudents = studentsSnapshot.size;
        _totalTeachers = teachersSnapshot.size;
        _totalClasses = uniqueClasses.length;
        _totalDiaries = diariesSnapshot.size;
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with greeting
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PlayfulTheme.primaryTeal.withOpacity(0.1),
                    PlayfulTheme.bgColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your school efficiently',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                ],
              ),
            ),

            // Statistics Cards
            _buildStatisticsSection(),

            const SizedBox(height: 24),

            // Management Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(delay: 300.ms),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDashboardCard(
                        context,
                        title: 'Announcements',
                        icon: Icons.campaign,
                        color: PlayfulTheme.primaryTeal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminAnnouncementScreen(),
                            ),
                          );
                        },
                      ).animate(delay: 400.ms),
                      _buildDashboardCard(
                        context,
                        title: 'Student Messages',
                        icon: Icons.mail_outline,
                        color: PlayfulTheme.accentOrange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StudentMessagesScreen(),
                            ),
                          );
                        },
                      ).animate(delay: 450.ms),
                      _buildDashboardCard(
                        context,
                        title: 'Manage Teachers',
                        icon: Icons.people,
                        color: PlayfulTheme.accentPurple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageTeachersScreen(),
                            ),
                          );
                        },
                      ).animate(delay: 500.ms),
                      _buildDashboardCard(
                        context,
                        title: 'Assign Subjects',
                        icon: Icons.assignment,
                        color: PlayfulTheme.primaryPink,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AssignSubjectsScreen(),
                            ),
                          );
                        },
                      ).animate(delay: 550.ms),
                      _buildDashboardCard(
                        context,
                        title: 'View All Diaries',
                        icon: Icons.book,
                        color: PlayfulTheme.primaryYellow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ViewAllDiariesScreen(),
                            ),
                          );
                        },
                      ).animate(delay: 600.ms),
                      _buildDashboardCard(
                        context,
                        title: 'All Classes',
                        icon: Icons.class_,
                        color: PlayfulTheme.primaryRed,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllClassesScreen(),
                            ),
                          );
                        },
                      ).animate(delay: 650.ms),
                      _buildDashboardCard(
                        context,
                        title: 'Attendance',
                        icon: Icons.how_to_reg,
                        color: const Color(0xFF00BFA5), // Teal accent
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminAttendanceDashboard(),
                            ),
                          );
                        },
                      ).animate(delay: 700.ms),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Charts Section
            _buildChartsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate(delay: 200.ms),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Students',
                  value: _totalStudents.toString(),
                  icon: Icons.school,
                  color: PlayfulTheme.primaryTeal,
                ).animate(delay: 250.ms),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Teachers',
                  value: _totalTeachers.toString(),
                  icon: Icons.people_alt,
                  color: PlayfulTheme.accentOrange,
                ).animate(delay: 300.ms),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Classes',
                  value: _totalClasses.toString(),
                  icon: Icons.class_,
                  color: PlayfulTheme.accentPurple,
                ).animate(delay: 350.ms),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Diaries',
                  value: _totalDiaries.toString(),
                  icon: Icons.book,
                  color: PlayfulTheme.primaryPink,
                ).animate(delay: 400.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate(delay: 800.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diaries by Class',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: 8,
                              color: PlayfulTheme.primaryTeal,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 12,
                              color: PlayfulTheme.accentOrange,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: 6,
                              color: PlayfulTheme.accentPurple,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: 15,
                              color: PlayfulTheme.primaryPink,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 4,
                          barRods: [
                            BarChartRodData(
                              toY: 9,
                              color: PlayfulTheme.primaryYellow,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = [
                                'KG',
                                '1st',
                                '5th',
                                '9th',
                                '10th',
                              ];
                              return Text(labels[value.toInt()]);
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      maxY: 20,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 900.ms),
        ],
      ),
    );
  }
}
