import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_analytics_service.dart';
import '../../widgets/class_attendance_excel_table.dart';
import '../../theme/playful_theme.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceAnalytics extends StatefulWidget {
  const TeacherAttendanceAnalytics({super.key});

  @override
  State<TeacherAttendanceAnalytics> createState() => _TeacherAttendanceAnalyticsState();
}

class _TeacherAttendanceAnalyticsState extends State<TeacherAttendanceAnalytics> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  final AttendanceService _attendanceService = AttendanceService();
  String? _selectedClassId;
  Map<String, AttendanceStats> _studentStats = {};
  bool _isLoading = false;
  
  // Sheet state
  bool _showRanking = true;
  DateTime _selectedTableMonth = DateTime.now();
  Map<String, List<AttendanceModel>> _allStudentRecords = {};
  List<UserModel> _currentClassStudents = [];
  bool _isLoadingSheet = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = Provider.of<AuthService>(context);
    final assignedClasses = authService.userModel?.assignedClasses ?? [];

    if (assignedClasses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance Analytics'),
          backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
          elevation: 0,
        ),
        body: const Center(
          child: Text('No classes assigned'),
        ),
      );
    }

    _selectedClassId ??= assignedClasses.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Stats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _loadClassStats();
              if (!_showRanking) _loadSheetData();
            },
            icon: const Icon(Icons.refresh, color: PlayfulTheme.primaryTeal),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          color: PlayfulTheme.accentPurple.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: PlayfulTheme.accentPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Class Analytics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // Class Selection
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration: InputDecoration(
                  labelText: 'Select Class',
                  prefixIcon: const Icon(Icons.class_),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: assignedClasses.map((classId) {
                  return DropdownMenuItem(
                    value: classId,
                    child: Text('Class $classId'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                    _studentStats.clear();
                  });
                  _loadClassStats();
                  _loadSheetData();
                },
              ).animate().fadeIn(delay: 100.ms),
            ),

            // Class Overview Infographic
            if (_studentStats.isNotEmpty && !_isLoading) _buildClassOverview(),

            // View Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTabButton('Rankings', _showRanking, () => setState(() => _showRanking = true)),
                  const SizedBox(width: 12),
                  _buildTabButton('Full Sheet', !_showRanking, () => setState(() => _showRanking = false)),
                ],
              ),
            ),

            if (!_showRanking) _buildMonthSelector(),

            // Student Statistics List or Excel Sheet
            if (_selectedClassId != null) 
              _showRanking ? _buildStudentStatsList() : _buildExcelSheetView(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassOverview() {
    double totalPercentage = 0;
    int studentsCount = _studentStats.length;
    int lowAttendanceCount = 0;

    _studentStats.forEach((uid, stats) {
      totalPercentage += stats.percentage;
      if (stats.percentage < 75) lowAttendanceCount++;
    });

    double avgPercentage = studentsCount > 0 ? totalPercentage / studentsCount : 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: PlayfulTheme.primaryTeal.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Class Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PlayfulTheme.textMain,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Average Gauge
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: avgPercentage / 100,
                            strokeWidth: 8,
                            backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(PlayfulTheme.primaryTeal),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${avgPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PlayfulTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Average Attendance',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PlayfulTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Divider
                Container(width: 1, height: 80, color: Colors.grey[200]),
                // Low Attendance Stats
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        lowAttendanceCount.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Low Attendance',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PlayfulTheme.textSecondary,
                      ),
                    ),
                    const Text(
                      '(Below 75%)',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? PlayfulTheme.primaryTeal : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [
              BoxShadow(color: PlayfulTheme.primaryTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
            ] : [],
            border: Border.all(color: isActive ? PlayfulTheme.primaryTeal : Colors.grey[300]!),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Text(DateFormat('MMMM yyyy').format(_selectedTableMonth), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedTableMonth = DateTime(_selectedTableMonth.year, _selectedTableMonth.month + delta);
    });
    _loadSheetData();
  }

  Widget _buildExcelSheetView() {
    if (_isLoadingSheet) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }

    if (_currentClassStudents.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No students found')));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClassAttendanceExcelTable(
        students: _currentClassStudents.map((s) => s.toMap()).toList(),
        studentRecords: _allStudentRecords,
        monthDate: _selectedTableMonth,
      ),
    );
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

  Widget _buildStudentStatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('classId', isEqualTo: _selectedClassId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: PlayfulTheme.primaryTeal),
            ),
          );
        }

        final students = snapshot.data!.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        students.sort((a, b) => (a.rollNo ?? '').compareTo(b.rollNo ?? ''));

        if (students.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No students in this class')),
          );
        }

        if (_studentStats.isEmpty && !_isLoading) _loadClassStats();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  'Student Rankings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PlayfulTheme.textMain,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final stats = _studentStats[student.uid] ?? AttendanceStats.empty();
                  final percentage = stats.percentage;
                  
                  Color statusColor = percentage >= 90 
                    ? Colors.green 
                    : percentage >= 75 
                      ? PlayfulTheme.primaryOrange 
                      : Colors.red;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Status leading bar
                            Container(width: 6, color: statusColor),
                            const SizedBox(width: 12),
                            // Roll Number
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  student.rollNo ?? '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name ?? 'Unknown Student',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: PlayfulTheme.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildMiniStat(stats.presentDays.toString(), 'P', Colors.green),
                                        const SizedBox(width: 8),
                                        _buildMiniStat(stats.absentDays.toString(), 'A', Colors.red),
                                        const SizedBox(width: 8),
                                        _buildMiniStat(stats.totalDays.toString(), 'T', Colors.blue),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Percentage
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  Text(
                                    percentage >= 75 ? 'Good' : 'Critical',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (400 + index * 50).ms).fadeIn().slideX(begin: 0.1, end: 0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _loadClassStats() async {
  if (_selectedClassId == null) return;

  setState(() => _isLoading = true);

  try {
    final stats = await _attendanceService.getClassAttendanceStats(
      classId: _selectedClassId!,
    );

    if (mounted) {
      setState(() {
        _studentStats = stats;
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('Error loading class stats: $e');
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
}
