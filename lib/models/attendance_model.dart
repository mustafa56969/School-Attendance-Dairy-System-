import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for individual attendance record
class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final DateTime date;
  final bool isPresent;
  final String markedBy; // Teacher ID who marked attendance
  final DateTime timestamp;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.date,
    required this.isPresent,
    required this.markedBy,
    required this.timestamp,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> data, String id) {
    return AttendanceModel(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date'].toString()),
      isPresent: data['isPresent'] ?? false,
      markedBy: data['markedBy'] ?? '',
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'isPresent': isPresent,
      'markedBy': markedBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

/// Model for attendance statistics
class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final double percentage;

  AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.percentage,
  });

  factory AttendanceStats.empty() {
    return AttendanceStats(
      totalDays: 0,
      presentDays: 0,
      absentDays: 0,
      percentage: 0.0,
    );
  }

  factory AttendanceStats.fromRecords(List<AttendanceModel> records) {
    final total = records.length;
    final present = records.where((r) => r.isPresent).length;
    final absent = total - present;
    final percentage = total > 0 ? (present / total) * 100 : 0.0;

    return AttendanceStats(
      totalDays: total,
      presentDays: present,
      absentDays: absent,
      percentage: percentage,
    );
  }
}

/// Model for monthly attendance breakdown
class MonthlyAttendance {
  final int month;
  final int year;
  final int presentCount;
  final int absentCount;
  final double percentage;

  MonthlyAttendance({
    required this.month,
    required this.year,
    required this.presentCount,
    required this.absentCount,
    required this.percentage,
  });

  int get totalDays => presentCount + absentCount;

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  factory MonthlyAttendance.fromRecords(
    int month,
    int year,
    List<AttendanceModel> records,
  ) {
    final present = records.where((r) => r.isPresent).length;
    final absent = records.length - present;
    final percentage = records.isNotEmpty ? (present / records.length) * 100 : 0.0;

    return MonthlyAttendance(
      month: month,
      year: year,
      presentCount: present,
      absentCount: absent,
      percentage: percentage,
    );
  }
}

/// Model for class attendance summary (for admin/teacher)
class ClassAttendanceStats {
  final String classId;
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final double attendanceRate;

  ClassAttendanceStats({
    required this.classId,
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.attendanceRate,
  });
}
