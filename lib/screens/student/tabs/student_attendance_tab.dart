import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/auth_service.dart';
import '../../../services/attendance_service.dart';
import '../../../models/attendance_model.dart';
import '../../../theme/playful_theme.dart';

class StudentAttendanceTab extends StatefulWidget {
  const StudentAttendanceTab({super.key});

  @override
  State<StudentAttendanceTab> createState() => _StudentAttendanceTabState();
}

class _StudentAttendanceTabState extends State<StudentAttendanceTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = true;
  AttendanceStats? _stats;
  List<MonthlyAttendance> _monthlyStats = [];
  List<AttendanceModel> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.userModel;

    if (user != null) {
      final stats = await _attendanceService.getAttendanceStats(studentId: user.uid);
      final monthly = await _attendanceService.getMonthlyStats(studentId: user.uid);
      final recent = await _attendanceService.getStudentAttendance(
        studentId: user.uid,
      );

      // Filter to last 30 days in memory to avoid indexing requirement
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentFiltered = recent.where((r) => r.date.isAfter(thirtyDaysAgo)).toList();

      // Sort recent records by date descending
      recentFiltered.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _stats = stats;
          _monthlyStats = monthly;
          _recentRecords = recentFiltered;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: PlayfulTheme.primaryTeal),
      );
    }

    if (_stats == null) {
      return const Center(child: Text('No attendance data found.'));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildOverallStats(),
              _buildMonthlyBreakdown(),
              _buildRecentHistory(),
              const SizedBox(height: 100), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  color: PlayfulTheme.primaryTeal,
                  size: 28,
                ),
              ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Analytics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: PlayfulTheme.textMain,
                          ),
                        ),
                        Text(
                          'Your school presence report',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, color: PlayfulTheme.primaryTeal),
                    tooltip: 'Refresh Analytics',
                  ),
                ],
              ),
            ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildOverallStats() {
    final percentage = _stats?.percentage ?? 0.0;
    final color = percentage >= 75
        ? PlayfulTheme.primaryTeal
        : percentage >= 60
            ? PlayfulTheme.primaryOrange
            : PlayfulTheme.primaryRed;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 10,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Overall',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ).animate(delay: 200.ms).scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildStatItem(
                    'Present',
                    _stats?.presentDays.toString() ?? '0',
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                  const Divider(height: 24),
                  _buildStatItem(
                    'Absent',
                    _stats?.absentDays.toString() ?? '0',
                    Icons.cancel_rounded,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown() {
    if (_monthlyStats.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Monthly Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _monthlyStats.length,
            itemBuilder: (context, index) {
              final month = _monthlyStats[index];
              return _buildMonthCard(month);
            },
          ),
        ),
      ],
    ).animate(delay: 300.ms).fadeIn();
  }

  Widget _buildMonthCard(MonthlyAttendance month) {
    final color = month.percentage >= 75 ? PlayfulTheme.primaryTeal : PlayfulTheme.primaryOrange;

    return Container(
      width: 120,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month.monthName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: month.percentage / 100,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${month.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${month.presentCount} Present',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'Recent Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (_recentRecords.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('No recent attendance records.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _recentRecords.length,
            itemBuilder: (context, index) {
              final record = _recentRecords[index];
              return _buildHistoryItem(record);
            },
          ),
      ],
    ).animate(delay: 400.ms).fadeIn();
  }

  Widget _buildHistoryItem(AttendanceModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: record.isPresent
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              record.isPresent ? Icons.check_rounded : Icons.close_rounded,
              color: record.isPresent ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(record.date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  record.isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    fontSize: 13,
                    color: record.isPresent ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('hh:mm a').format(record.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
