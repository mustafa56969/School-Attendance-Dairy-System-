import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_analytics_service.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../theme/playful_theme.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final Map<String, bool> _attendanceMap = {}; // studentId -> isPresent
  String? _selectedClassId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;
  List<UserModel> _currentStudents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final assignedClasses = authService.userModel?.assignedClasses ?? [];
      if (assignedClasses.isNotEmpty) {
        setState(() {
          _selectedClassId = assignedClasses.first;
        });
        _loadExistingAttendance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final assignedClasses = authService.userModel?.assignedClasses ?? [];

    if (assignedClasses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Take Attendance'),
          backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Classes Assigned',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Please contact the admin to assign classes for attendance marking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Set default class if not selected
    _selectedClassId ??= assignedClasses.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExistingAttendance,
            tooltip: 'Refresh List',
          ),
          if (_attendanceMap.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveAttendance,
              tooltip: 'Save Attendance',
            ),
        ],
      ),
      body: Column(
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
                        Icons.check_circle,
                        color: PlayfulTheme.primaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Mark Attendance',
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

          // Class and Date Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Class Dropdown
                DropdownButtonFormField<String>(
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
                      _attendanceMap.clear();
                    });
                    _loadExistingAttendance();
                  },
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PlayfulTheme.primaryPink.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: PlayfulTheme.primaryPink,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Tap to change date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _markAllPresent,
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('All Present'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _markAllAbsent,
                    icon: const Icon(Icons.cancel, size: 20),
                    label: const Text('All Absent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ),

          const SizedBox(height: 16),

          // Student List
          Expanded(
            child: _buildStudentList(),
          ),
        ],
      ),
      floatingActionButton: _attendanceMap.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveAttendance,
              backgroundColor: PlayfulTheme.primaryTeal,
              foregroundColor: Colors.white,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Attendance'),
            ).animate().fadeIn().scale()
          : null,
    );
  }

  Widget _buildStudentList() {
    if (_selectedClassId == null) {
      return const Center(child: Text('Please select a class'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('classId', isEqualTo: _selectedClassId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        students.sort((a, b) => (a.rollNo ?? '').compareTo(b.rollNo ?? ''));
        
        // Update current students list for saving
        _currentStudents = students;

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No students in this class',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final isPresent = _attendanceMap[student.uid];

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
                border: isPresent != null
                    ? Border.all(
                        color: isPresent ? Colors.green : Colors.red,
                        width: 2,
                      )
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isPresent == null
                        ? Colors.grey[200]
                        : (isPresent ? Colors.green : Colors.red).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      student.rollNo ?? '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPresent == null
                            ? Colors.grey[700]
                            : isPresent
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  student.name ?? student.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(student.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Present Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _attendanceMap[student.uid] = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPresent == true ? Colors.green : Colors.grey[300],
                        foregroundColor: isPresent == true ? Colors.white : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('P'),
                    ),
                    const SizedBox(width: 8),
                    // Absent Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _attendanceMap[student.uid] = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPresent == false ? Colors.red : Colors.grey[300],
                        foregroundColor: isPresent == false ? Colors.white : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('A'),
                    ),
                  ],
                ),
              ),
            ).animate(delay: (400 + index * 50).ms).fadeIn().slideX(begin: 0.2, end: 0);
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PlayfulTheme.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: PlayfulTheme.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _attendanceMap.clear();
      });
      _loadExistingAttendance();
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);

    final existingRecords = await _attendanceService.getClassAttendance(
      classId: _selectedClassId!,
      date: _selectedDate,
    );

    if (mounted) {
      setState(() {
        _attendanceMap.clear();
        for (var record in existingRecords) {
          _attendanceMap[record.studentId] = record.isPresent;
        }
        _isLoading = false;
      });
    }
  }

  void _markAllPresent() async {
    if (_selectedClassId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: _selectedClassId)
        .get();

    setState(() {
      for (var doc in snapshot.docs) {
        _attendanceMap[doc.id] = true;
      }
    });
  }

  void _markAllAbsent() async {
    if (_selectedClassId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: _selectedClassId)
        .get();

    setState(() {
      for (var doc in snapshot.docs) {
        _attendanceMap[doc.id] = false;
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_attendanceMap.isEmpty || _selectedClassId == null) return;

    setState(() => _isSaving = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final teacherId = authService.currentUser?.uid ?? '';

    try {
      final records = <Map<String, dynamic>>[];
      
      for (var entry in _attendanceMap.entries) {
        // Find student in our current list to get their name
        final student = _currentStudents.firstWhere(
          (s) => s.uid == entry.key,
          orElse: () => UserModel(uid: entry.key, email: '', role: 'student'),
        );
        
        records.add({
          'studentId': entry.key,
          'studentName': student.name ?? student.email,
          'classId': _selectedClassId,
          'date': _selectedDate,
          'isPresent': entry.value,
        });
      }

      if (records.isEmpty) {
        setState(() => _isSaving = false);
        return;
      }

      final success = await _attendanceService.markBulkAttendance(
        attendanceRecords: records,
        markedBy: teacherId,
      );

      if (mounted) {
        setState(() => _isSaving = false);

        if (success) {
          // Refresh analytics
          final analytics = Provider.of<AttendanceAnalyticsService>(context, listen: false);
          analytics.refreshNow(authService.userModel!.uid, classId: _selectedClassId);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save attendance'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
