import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';
import '../../widgets/vibrant_loading_widget.dart';
import '../../widgets/vibrant_error_widget.dart';
import 'manage_teachers_screen.dart';
import 'assign_subjects_screen.dart';
import 'view_all_diaries_screen.dart';
import 'all_classes_screen.dart';
import 'admin_announcement_screen.dart';
import 'student_messages_screen.dart';
import 'admin_attendance_dashboard.dart';
import 'class_promotion_screen.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';

class VibrantAdminDashboard extends StatefulWidget {
  const VibrantAdminDashboard({super.key});

  @override
  State<VibrantAdminDashboard> createState() => _VibrantAdminDashboardState();
}

class _VibrantAdminDashboardState extends State<VibrantAdminDashboard> {
  List<Map<String, dynamic>> _classDiaryData = [];
  List<Map<String, dynamic>> _monthlyDiaryData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealTimeData();
  }

  Future<void> _loadRealTimeData() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      // Fetch only recent diaries (from start of current month)
      final diariesSnapshot = await FirebaseFirestore.instance
          .collection('diaries')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      // Process data for class-based chart
      final classCounts = <String, int>{};
      final monthlyCounts = <String, int>{};

      for (var doc in diariesSnapshot.docs) {
        final data = doc.data();

        // Class-based data
        final classId = data['classId'] ?? 'Unknown';
        classCounts[classId] = (classCounts[classId] ?? 0) + 1;

        // Monthly data (last 6 months)
        if (data['date'] is Timestamp) {
          final date = (data['date'] as Timestamp).toDate();
          final monthKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
        }
      }

      // Convert to chart-friendly format
      final classData = classCounts.entries
          .map((entry) => {'class': entry.key, 'count': entry.value})
          .toList();

      final monthlyData = monthlyCounts.entries
          .map((entry) => {'month': entry.key, 'count': entry.value})
          .toList();

      // Sort by count descending
      classData.sort(
        (a, b) => (b['count'] as int).compareTo(a['count'] as int),
      );
      monthlyData.sort(
        (a, b) => (a['month'] as String).compareTo(b['month'] as String),
      );

      setState(() {
        _classDiaryData = classData;
        _monthlyDiaryData = monthlyData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading real-time data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.15),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRealTimeData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRealTimeData();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with greeting
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PlayfulTheme.primaryTeal.withOpacity(0.15),
                      PlayfulTheme.bgColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // App Logo
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/logo.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Welcome, Admin!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your school efficiently',
                      style: TextStyle(
                        fontSize: 16,
                        color: PlayfulTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics Cards with Real-time Data
              _buildRealTimeStatistics(),

              const SizedBox(height: 24),

              // Management Cards
              _buildManagementSection(),

              const SizedBox(height: 24),

              // Charts Section with Real-time Data
              _buildRealTimeCharts(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return _buildLoadingStatistics();
        }

        final users = userSnapshot.data!.docs;
        final students = users.where((doc) => doc['role'] == 'student').length;
        final teachers = users.where((doc) => doc['role'] == 'teacher').length;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
          builder: (context, subjectSnapshot) {
            if (!subjectSnapshot.hasData) {
              return _buildLoadingStatistics();
            }

            final subjects = subjectSnapshot.data!.docs;
            final uniqueClasses = <String>{};
            for (var doc in subjects) {
              final data = doc.data() as Map<String, dynamic>;
              if (data.containsKey('classId')) {
                uniqueClasses.add(data['classId']);
              }
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('diaries')
                  .snapshots(),
              builder: (context, diarySnapshot) {
                if (!diarySnapshot.hasData) {
                  return _buildLoadingStatistics();
                }

                final diaries = diarySnapshot.data!.docs.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate(delay: 200.ms),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVibrantStatCard(
                              title: 'Students',
                              value: students.toString(),
                              icon: Icons.school,
                              color: PlayfulTheme.primaryTeal,
                            ).animate(delay: 250.ms),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildVibrantStatCard(
                              title: 'Teachers',
                              value: teachers.toString(),
                              icon: Icons.people_alt,
                              color: PlayfulTheme.primaryPink,
                            ).animate(delay: 300.ms),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVibrantStatCard(
                              title: 'Classes',
                              value: uniqueClasses.length.toString(),
                              icon: Icons.class_,
                              color: PlayfulTheme.primaryOrange,
                            ).animate(delay: 350.ms),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildVibrantStatCard(
                              title: 'Diaries',
                              value: diaries.toString(),
                              icon: Icons.book,
                              color: PlayfulTheme.accentPurple,
                            ).animate(delay: 400.ms),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVibrantStatCard(
                  title: 'Students',
                  value: '--',
                  icon: Icons.school,
                  color: PlayfulTheme.primaryTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVibrantStatCard(
                  title: 'Teachers',
                  value: '--',
                  icon: Icons.people_alt,
                  color: PlayfulTheme.primaryPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVibrantStatCard(
                  title: 'Classes',
                  value: '--',
                  icon: Icons.class_,
                  color: PlayfulTheme.primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVibrantStatCard(
                  title: 'Diaries',
                  value: '--',
                  icon: Icons.book,
                  color: PlayfulTheme.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVibrantStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: PlayfulTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ).animate(delay: 500.ms),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildVibrantDashboardCard(
                context,
                title: 'Announcements',
                icon: Icons.campaign,
                color: PlayfulTheme.primaryTeal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAnnouncementScreen(),
                    ),
                  );
                },
              ).animate(delay: 550.ms),
              StreamBuilder<List<StudentMessage>>(
                stream: AnnouncementService().streamStudentMessages(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.hasData 
                      ? snapshot.data!.where((m) => !m.isRead).length 
                      : 0;
                  return _buildVibrantDashboardCard(
                    context,
                    title: 'Student Messages',
                    icon: Icons.mail_outline,
                    color: PlayfulTheme.accentOrange,
                    badgeCount: unreadCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentMessagesScreen(),
                        ),
                      );
                    },
                  );
                }
              ).animate(delay: 600.ms),
              _buildVibrantDashboardCard(
                context,
                title: 'Manage Teachers',
                icon: Icons.people,
                color: PlayfulTheme.accentPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageTeachersScreen(),
                    ),
                  );
                },
              ).animate(delay: 650.ms),
              _buildVibrantDashboardCard(
                context,
                title: 'Assign Subjects',
                icon: Icons.assignment,
                color: PlayfulTheme.primaryPink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssignSubjectsScreen(),
                    ),
                  );
                },
              ).animate(delay: 700.ms),
              _buildVibrantDashboardCard(
                context,
                title: 'View All Diaries',
                icon: Icons.book,
                color: PlayfulTheme.primaryOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewAllDiariesScreen(),
                    ),
                  );
                },
              ).animate(delay: 750.ms),
              _buildVibrantDashboardCard(
                context,
                title: 'All Classes',
                icon: Icons.class_,
                color: PlayfulTheme.primaryYellow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllClassesScreen(),
                    ),
                  );
                },
              ).animate(delay: 800.ms),
              _buildVibrantDashboardCard(
                context,
                title: 'Attendance',
                icon: Icons.how_to_reg,
                color: const Color(0xFF00BFA5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAttendanceDashboard(),
                    ),
                  );
                },
              ).animate(delay: 850.ms),
              _buildVibrantDashboardCard(
                context,
                title: 'Class Promotion',
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFF9C27B0), // Purple
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClassPromotionScreen(),
                    ),
                  );
                },
              ).animate(delay: 900.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVibrantDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: PlayfulTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().scale(curve: Curves.elasticOut),
            ),
        ],
      ),
    );
  }

  Widget _buildRealTimeCharts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ).animate(delay: 750.ms),
          const SizedBox(height: 16),

          // Diaries by Class Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: PlayfulTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Diaries by Class',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: _isLoading
                      ? const VibrantLoadingWidget(
                          message: 'Loading chart data...',
                        )
                      : _classDiaryData.isEmpty
                      ? const Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                              fontSize: 16,
                              color: PlayfulTheme.textSecondary,
                            ),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            barGroups: _generateClassBarGroups(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() <
                                        _classDiaryData.length) {
                                      final className =
                                          _classDiaryData[value
                                              .toInt()]['class'];
                                      // Limit class name length to prevent overflow
                                      String displayName = className.toString();
                                      if (displayName.length > 10) {
                                        displayName =
                                            '${displayName.substring(0, 7)}...';
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: PlayfulTheme.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: PlayfulTheme.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                            ),
                            maxY: _getMaxYValue(_classDiaryData),
                          ),
                        ),
                ),
              ],
            ),
          ).animate(delay: 800.ms),

          const SizedBox(height: 24),

          // Monthly Diaries Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: PlayfulTheme.primaryPink.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.show_chart,
                        color: PlayfulTheme.primaryPink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Monthly Diaries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _monthlyDiaryData.isEmpty
                      ? const Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                              fontSize: 16,
                              color: PlayfulTheme.textSecondary,
                            ),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateMonthlySpots(),
                                isCurved: true,
                                color: PlayfulTheme.primaryPink,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: PlayfulTheme.primaryPink,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: PlayfulTheme.primaryPink.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() <
                                        _monthlyDiaryData.length) {
                                      final monthKey =
                                          _monthlyDiaryData[value
                                              .toInt()]['month'];
                                      final parts = monthKey.split('-');
                                      if (parts.length == 2) {
                                        final month = int.parse(parts[1]);
                                        final monthNames = [
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'May',
                                          'Jun',
                                          'Jul',
                                          'Aug',
                                          'Sep',
                                          'Oct',
                                          'Nov',
                                          'Dec',
                                        ];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            monthNames[month - 1],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: PlayfulTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 35,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: PlayfulTheme.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            maxY: _getMaxYValue(_monthlyDiaryData),
                          ),
                        ),
                ),
              ],
            ),
          ).animate(delay: 850.ms),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateClassBarGroups() {
    final colors = [
      PlayfulTheme.primaryTeal,
      PlayfulTheme.primaryPink,
      PlayfulTheme.primaryOrange,
      PlayfulTheme.accentPurple,
      PlayfulTheme.primaryYellow,
    ];

    return List.generate(_classDiaryData.length, (index) {
      final data = _classDiaryData[index];
      final color = colors[index % colors.length];
      final count = data['count'] as int;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: color,
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            rodStackItems: [],
          ),
        ],
      );
    });
  }

  List<FlSpot> _generateMonthlySpots() {
    return List.generate(_monthlyDiaryData.length, (index) {
      final data = _monthlyDiaryData[index];
      final count = data['count'] as int;
      return FlSpot(index.toDouble(), count.toDouble());
    });
  }

  double _getMaxYValue(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 10;

    final maxCount = data
        .map((item) => item['count'] as int)
        .reduce((a, b) => a > b ? a : b);

    // Add 20% padding to the top
    return (maxCount * 1.2).ceilToDouble();
  }
}
