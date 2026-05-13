import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

/// Service to manage student attendance
class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _attendanceCollection = 'attendance';
  static const String _usersCollection = 'users';

  /// Mark attendance for a single student
  Future<bool> markAttendance({
    required String studentId,
    required String studentName,
    required String classId,
    required DateTime date,
    required bool isPresent,
    required String markedBy,
  }) async {
    try {
      // Check if attendance already exists for this student on this date
      final existingQuery = await _firestore
          .collection(_attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .where('classId', isEqualTo: classId)
          .get();

      // Check if attendance exists for the same date
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      for (var doc in existingQuery.docs) {
        final data = doc.data();
        final existingDate = (data['date'] as Timestamp).toDate();
        final normalizedExisting = DateTime(
          existingDate.year,
          existingDate.month,
          existingDate.day,
        );

        if (normalizedExisting == normalizedDate) {
          // Update existing record
          await doc.reference.update({
            'isPresent': isPresent,
            'markedBy': markedBy,
            'timestamp': Timestamp.fromDate(DateTime.now()),
          });
          debugPrint('✅ Updated existing attendance for $studentName');
          return true;
        }
      }

      // Create new attendance record
      final attendance = AttendanceModel(
        id: '',
        studentId: studentId,
        studentName: studentName,
        classId: classId,
        date: normalizedDate,
        isPresent: isPresent,
        markedBy: markedBy,
        timestamp: DateTime.now(),
      );

      await _firestore.collection(_attendanceCollection).add(attendance.toMap());
      debugPrint('✅ Marked attendance for $studentName');
      return true;
    } catch (e) {
      debugPrint('❌ Error marking attendance: $e');
      return false;
    }
  }

  /// Mark attendance for multiple students (bulk operation)
  Future<bool> markBulkAttendance({
    required List<Map<String, dynamic>> attendanceRecords,
    required String markedBy,
  }) async {
    if (attendanceRecords.isEmpty) return true;
    
    try {
      final batch = _firestore.batch();
      final classId = attendanceRecords.first['classId'] as String;
      final date = attendanceRecords.first['date'] as DateTime;
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final startOfDay = normalizedDate;
      final endOfDay = normalizedDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

      // Fetch ALL existing records for this class and date in ONE query
      final existingRecordsSnapshot = await _firestore
          .collection(_attendanceCollection)
          .where('classId', isEqualTo: classId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();

      // Map studentId to its attendance document for quick lookup
      final Map<String, DocumentSnapshot> existingMap = {
        for (var doc in existingRecordsSnapshot.docs) doc['studentId'] as String: doc
      };

      for (var record in attendanceRecords) {
        final studentId = record['studentId'] as String;
        final isPresent = record['isPresent'] as bool;
        final studentName = record['studentName'] as String;

        if (existingMap.containsKey(studentId)) {
          // Update existing
          batch.update(existingMap[studentId]!.reference, {
            'isPresent': isPresent,
            'markedBy': markedBy,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new
          final attendance = AttendanceModel(
            id: '',
            studentId: studentId,
            studentName: studentName,
            classId: classId,
            date: normalizedDate,
            isPresent: isPresent,
            markedBy: markedBy,
            timestamp: DateTime.now(),
          );

          final docRef = _firestore.collection(_attendanceCollection).doc();
          batch.set(docRef, attendance.toMap());
        }
      }

      await batch.commit();
      debugPrint('✅ Bulk attendance saved for ${attendanceRecords.length} students');
      return true;
    } catch (e) {
      debugPrint('❌ Error in markBulkAttendance: $e');
      return false;
    }
  }

  /// Get attendance records for a specific student
  Future<List<AttendanceModel>> getStudentAttendance({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      List<AttendanceModel> records = snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filter by date in memory
      if (startDate != null) {
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        records = records.where((r) => r.date.isAtSameMomentAs(start) || r.date.isAfter(start)).toList();
      }

      if (endDate != null) {
        final endLimit = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
        records = records.where((r) => r.date.isBefore(endLimit)).toList();
      }

      return records;
    } catch (e) {
      debugPrint('❌ Error getting student attendance: $e');
      return [];
    }
  }

  /// Get attendance for entire class on a specific date
  Future<List<AttendanceModel>> getClassAttendance({
    required String classId,
    required DateTime date,
  }) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      final snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('classId', isEqualTo: classId)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((r) => (r.date.isAtSameMomentAs(normalizedDate) || r.date.isAfter(normalizedDate)) && 
                        r.date.isBefore(normalizedDate.add(const Duration(days: 1))))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting class attendance: $e');
      return [];
    }
  }

  /// Get attendance for all students in a class for a specific month
  Future<List<AttendanceModel>> getClassMonthAttendance({
    required String classId,
    required int month,
    required int year,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final nextMonth = DateTime(year, month + 1, 1);

      final snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('classId', isEqualTo: classId)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((r) => (r.date.isAtSameMomentAs(startDate) || r.date.isAfter(startDate)) && 
                        r.date.isBefore(nextMonth))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting class month attendance: $e');
      return [];
    }
  }

  /// Calculate attendance statistics for a student
  Future<AttendanceStats> getAttendanceStats({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      return AttendanceStats.fromRecords(records);
    } catch (e) {
      debugPrint('❌ Error calculating attendance stats: $e');
      return AttendanceStats.empty();
    }
  }

  /// Get month-wise attendance breakdown for a student
  Future<List<MonthlyAttendance>> getMonthlyStats({
    required String studentId,
    int? year,
  }) async {
    try {
      final currentYear = year ?? DateTime.now().year;
      final startDate = DateTime(currentYear, 1, 1);
      final endDate = DateTime(currentYear, 12, 31);

      final records = await getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      // Group records by month
      final monthlyRecords = <int, List<AttendanceModel>>{};
      for (var record in records) {
        final month = record.date.month;
        monthlyRecords[month] = monthlyRecords[month] ?? [];
        monthlyRecords[month]!.add(record);
      }

      // Convert to MonthlyAttendance objects
      final result = <MonthlyAttendance>[];
      for (var month = 1; month <= 12; month++) {
        final records = monthlyRecords[month] ?? [];
        if (records.isNotEmpty) {
          result.add(MonthlyAttendance.fromRecords(month, currentYear, records));
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error getting monthly stats: $e');
      return [];
    }
  }

  /// Get overall school-wide attendance statistics (for admin)
  Future<Map<String, dynamic>> getOverallStats() async {
    try {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final startOfDay = Timestamp.fromDate(normalizedToday);
      final endOfDay = Timestamp.fromDate(
        normalizedToday.add(const Duration(days: 1)),
      );

      // Get today's attendance
      final todaySnapshot = await _firestore
          .collection(_attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      final todayRecords = todaySnapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final totalToday = todayRecords.length;
      final presentToday = todayRecords.where((r) => r.isPresent).length;
      final absentToday = totalToday - presentToday;
      final percentageToday = totalToday > 0 ? (presentToday / totalToday) * 100 : 0.0;

      // Get recent stats (last 30 days) to avoid fetching thousands of docs
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      final recentSnapshot = await _firestore
          .collection(_attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();
      
      final recentRecords = recentSnapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final totalRecent = recentRecords.length;
      final presentRecent = recentRecords.where((r) => r.isPresent).length;
      final percentageRecent = totalRecent > 0 ? (presentRecent / totalRecent) * 100 : 0.0;

      // Get total students
      final studentsSnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'student')
          .get();
      final totalStudents = studentsSnapshot.size;

      return {
        'today': {
          'total': totalToday,
          'present': presentToday,
          'absent': absentToday,
          'percentage': percentageToday,
        },
        'overall': {
          'total': totalRecent,
          'present': presentRecent,
          'percentage': percentageRecent,
          'label': 'Past 30 Days',
        },
        'totalStudents': totalStudents,
      };
    } catch (e) {
      debugPrint('❌ Error getting overall stats: $e');
      return {};
    }
  }

  /// Get class-wise attendance statistics (for admin)
  Future<List<ClassAttendanceStats>> getClassWiseStats({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final normalizedDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final startOfDay = Timestamp.fromDate(normalizedDate);
      final endOfDay = Timestamp.fromDate(
        normalizedDate.add(const Duration(days: 1)),
      );

      // Get all attendance for the date
      final snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      final records = snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Group by class
      final classRecords = <String, List<AttendanceModel>>{};
      for (var record in records) {
        classRecords[record.classId] = classRecords[record.classId] ?? [];
        classRecords[record.classId]!.add(record);
      }

      // Convert to ClassAttendanceStats
      final result = <ClassAttendanceStats>[];
      for (var entry in classRecords.entries) {
        final classId = entry.key;
        final records = entry.value;
        final present = records.where((r) => r.isPresent).length;
        final absent = records.length - present;
        final rate = records.isNotEmpty ? (present / records.length) * 100 : 0.0;

        result.add(ClassAttendanceStats(
          classId: classId,
          totalStudents: records.length,
          presentToday: present,
          absentToday: absent,
          attendanceRate: rate,
        ));
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error getting class-wise stats: $e');
      return [];
    }
  }

  /// Stream attendance for a student
  Stream<List<AttendanceModel>> streamStudentAttendance({required String studentId}) {
    return _firestore
        .collection(_attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in memory to avoid aggregate index requirement
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    });
  }

  /// Stream class attendance for a specific date
  Stream<List<AttendanceModel>> streamClassAttendance({
    required String classId,
    required DateTime date,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return _firestore
        .collection(_attendanceCollection)
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
            .where((r) => r.date.isAfter(normalizedDate.subtract(const Duration(seconds: 1))) && 
                          r.date.isBefore(normalizedDate.add(const Duration(days: 1))))
            .toList());
  }

  /// Get statistics for all students in a class in one go
  Future<Map<String, AttendanceStats>> getClassAttendanceStats({
    required String classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final targetDate = startDate ?? DateTime.now();
      final records = await getClassMonthAttendance(
        classId: classId,
        month: targetDate.month,
        year: targetDate.year,
      );

      final Map<String, List<AttendanceModel>> studentRecords = {};
      for (var record in records) {
        studentRecords[record.studentId] = studentRecords[record.studentId] ?? [];
        studentRecords[record.studentId]!.add(record);
      }

      final Map<String, AttendanceStats> stats = {};
      for (var entry in studentRecords.entries) {
        stats[entry.key] = AttendanceStats.fromRecords(entry.value);
      }

      return stats;
    } catch (e) {
      debugPrint('❌ Error getting class attendance stats: $e');
      return {};
    }
  }
}
