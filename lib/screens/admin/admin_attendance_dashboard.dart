import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_analytics_service.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../theme/playful_theme.dart';
import '../../widgets/class_attendance_excel_table.dart';
import '../teacher/teacher_attendance_screen.dart';
import 'package:intl/intl.dart';

class AdminAttendanceDashboard extends StatefulWidget {
  const AdminAttendanceDashboard({super.key});

  @override
  State<AdminAttendanceDashboard> createState() => _AdminAttendanceDashboardState();
}

class _AdminAttendanceDashboardState extends State<AdminAttendanceDashboard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  final AttendanceService _attendanceService = AttendanceService();
  Map<String, dynamic> _overallStats = {};
  List<ClassAttendanceStats> _classStats = [];
  bool _isLoading = true;
  
  // Detailed Sheet State
  String? _selectedClassId;
  DateTime _selectedTableMonth = DateTime.now();
  Map<String, List<AttendanceModel>> _allStudentRecords = {};
  List<UserModel> _currentClassStudents = [];
  bool _isLoadingSheet = false;
  final List<String> _availableClasses = ['Nursery', 'KG', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    // Check if we need to sync based on last sync time
    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = Provider.of<AttendanceAnalyticsService>(context, listen: false);
    
    if (authService.userModel != null) {
      // Don't force refresh every time, let checkAndSyncOnLogin handle it
      await analytics.checkAndSyncOnLogin(authService.userModel!.uid);
    }

    final stats = await _attendanceService.getOverallStats();
    final classwise = await _attendanceService.getClassWiseStats();
    
    if (mounted) {
      setState(() {
        _overallStats = stats;
        _classStats = classwise;
        _isLoading = false;
      });
      if (_selectedClassId != null) _loadSheetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh Statistics',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
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
                                    'Admin Panel',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: PlayfulTheme.textMain,
                                    ),
                                  ),
                                  Text(
                                    'Overview of school attendance',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TeacherAttendanceScreen()),
                                );
                              },
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Take Attendance'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),

                  // Today's Statistics
                  if (_overallStats['today'] != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Attendance',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate(delay: 200.ms),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total',
                                  value: _overallStats['today']['total'].toString(),
                                  icon: Icons.groups,
                                  color: PlayfulTheme.primaryTeal,
                                ).animate(delay: 250.ms).fadeIn().scale(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Present',
                                  value: _overallStats['today']['present'].toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                ).animate(delay: 300.ms).fadeIn().scale(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Absent',
                                  value: _overallStats['today']['absent'].toString(),
                                  icon: Icons.cancel,
                                  color: Colors.red,
                                ).animate(delay: 350.ms).fadeIn().scale(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Attendance Percentage Chart
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: PlayfulTheme.primaryPink.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.pie_chart,
                                    color: PlayfulTheme.primaryPink,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Present vs Absent',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_overallStats['today']['percentage'].toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: PlayfulTheme.primaryTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 50,
                                        sections: [
                                          PieChartSectionData(
                                            color: Colors.green,
                                            value: _overallStats['today']['present'].toDouble(),
                                            title: 'Present',
                                            radius: 60,
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            color: Colors.red,
                                            value: _overallStats['today']['absent'].toDouble(),
                                            title: 'Absent',
                                            radius: 60,
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLegendItem(
                                          'Present',
                                          Colors.green,
                                          _overallStats['today']['present'],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildLegendItem(
                                          'Absent',
                                          Colors.red,
                                          _overallStats['today']['absent'],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
                    ),
                  ],

                  // Class-wise Statistics
                  if (_classStats.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Class-wise Attendance',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate(delay: 500.ms),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: PlayfulTheme.accentOrange.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.bar_chart,
                                        color: PlayfulTheme.accentOrange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Today\'s Performance',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 250,
                                  child: BarChart(
                                    BarChartData(
                                      maxY: 100,
                                      barGroups: _classStats
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final colors = [
                                          PlayfulTheme.primaryTeal,
                                          PlayfulTheme.accentOrange,
                                          PlayfulTheme.accentPurple,
                                          PlayfulTheme.primaryPink,
                                          PlayfulTheme.primaryYellow,
                                          PlayfulTheme.primaryRed,
                                        ];
                                        return BarChartGroupData(
                                          x: entry.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: entry.value.attendanceRate,
                                              color: colors[entry.key % colors.length],
                                              width: 30,
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              if (value.toInt() < _classStats.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    _classStats[value.toInt()].classId,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${value.toInt()}%',
                                                style: const TextStyle(fontSize: 10),
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
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ],

                  // Teacher Assignment Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Teacher Assignments',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _showTeacherAssignmentDialog,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Assign'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PlayfulTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 700.ms),
                        const SizedBox(height: 16),
                        _buildTeacherAssignments(),
                      ],
                    ),
                  ),

                  // Detailed Sheets Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Class Sheets',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate(delay: 750.ms),
                        const SizedBox(height: 16),
                        _buildDetailedSheetsSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailedSheetsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableClasses.map((c) => DropdownMenuItem(value: c, child: Text('Class $c'))).toList(),
                  onChanged: (value) {
                    setState(() => _selectedClassId = value);
                    _loadSheetData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                      Text(DateFormat('MMM yyyy').format(_selectedTableMonth), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingSheet)
            const Center(child: CircularProgressIndicator())
          else if (_selectedClassId == null)
            const Center(child: Text('Select a class to view sheet'))
          else
            ClassAttendanceExcelTable(
              students: _currentClassStudents.map((s) => s.toMap()).toList(),
              studentRecords: _allStudentRecords,
              monthDate: _selectedTableMonth,
            ),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedTableMonth = DateTime(_selectedTableMonth.year, _selectedTableMonth.month + delta);
    });
    if (_selectedClassId != null) _loadSheetData();
  }

  Future<void> _loadSheetData() async {
    if (_selectedClassId == null) return;
    setState(() => _isLoadingSheet = true);

    try {
      final records = await _attendanceService.getClassMonthAttendance(
        classId: _selectedClassId!,
        month: _selectedTableMonth.month,
        year: _selectedTableMonth.year,
      );

      final Map<String, List<AttendanceModel>> grouped = {};
      for (var r in records) {
        grouped[r.studentId] = grouped[r.studentId] ?? [];
        grouped[r.studentId]!.add(r);
      }

      final studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('classId', isEqualTo: _selectedClassId)
          .get();
      
      final students = studentSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      students.sort((a,b) => (a.rollNo ?? '').compareTo(b.rollNo ?? ''));

      if (mounted) {
        setState(() {
          _allStudentRecords = grouped;
          _currentClassStudents = students;
          _isLoadingSheet = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sheet data: $e');
      if (mounted) setState(() => _isLoadingSheet = false);
    }
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherAssignments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final teachers = snapshot.data!.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (teachers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No teachers found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.accentPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: PlayfulTheme.accentPurple,
                  ),
                ),
                title: Text(
                  teacher.name ?? teacher.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  teacher.assignedClasses != null && teacher.assignedClasses!.isNotEmpty
                      ? 'Classes: ${teacher.assignedClasses!.join(', ')}'
                      : 'No classes assigned',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTeacherAssignment(teacher),
                  tooltip: 'Edit Assignment',
                ),
              ),
            ).animate(delay: (800 + index * 50).ms).fadeIn().slideX(begin: 0.2, end: 0);
          },
        );
      },
    );
  }

  void _showTeacherAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => const TeacherAssignmentDialog(),
    ).then((_) => _loadStatistics());
  }

  void _editTeacherAssignment(UserModel teacher) {
    showDialog(
      context: context,
      builder: (context) => TeacherAssignmentDialog(teacher: teacher),
    ).then((_) => _loadStatistics());
  }
}

// Teacher Assignment Dialog
class TeacherAssignmentDialog extends StatefulWidget {
  final UserModel? teacher;

  const TeacherAssignmentDialog({super.key, this.teacher});

  @override
  State<TeacherAssignmentDialog> createState() => _TeacherAssignmentDialogState();
}

class _TeacherAssignmentDialogState extends State<TeacherAssignmentDialog> {
  String? _selectedTeacherId;
  final List<String> _selectedClasses = [];
  final List<String> _availableClasses = ['Nursery', 'KG', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _selectedTeacherId = widget.teacher!.uid;
      _selectedClasses.addAll(widget.teacher!.assignedClasses ?? []);
    }
  }

  Future<void> _saveAssignment() async {
    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a teacher')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedTeacherId)
          .update({
        'assignedClasses': _selectedClasses,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.teacher != null ? 'Edit Assignment' : 'Assign Teacher to Classes'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.teacher == null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'teacher')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final teachers = snapshot.data!.docs
                      .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedTeacherId,
                    decoration: const InputDecoration(
                      labelText: 'Select Teacher',
                      border: OutlineInputBorder(),
                    ),
                    items: teachers.map((teacher) {
                      return DropdownMenuItem(
                        value: teacher.uid,
                        child: Text(teacher.name ?? teacher.email),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedTeacherId = value);
                    },
                  );
                },
              )
            else
              Text(
                'Teacher: ${widget.teacher!.name ?? widget.teacher!.email}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            const Text(
              'Assign Classes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableClasses.map((classId) {
                final isSelected = _selectedClasses.contains(classId);
                return FilterChip(
                  label: Text(classId),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedClasses.add(classId);
                      } else {
                        _selectedClasses.remove(classId);
                      }
                    });
                  },
                  selectedColor: PlayfulTheme.primaryTeal.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAssignment,
          style: ElevatedButton.styleFrom(
            backgroundColor: PlayfulTheme.primaryTeal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
