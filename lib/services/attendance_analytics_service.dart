import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_service.dart';
import '../models/attendance_model.dart';

class AttendanceAnalyticsService extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isSyncing = false;
  
  bool get isSyncing => _isSyncing;

  // Cache keys
  static const String _lastSyncKey = 'attendance_last_sync_pkt';
  static const String _cacheKeyPrefix = 'attendance_cache_';

  /// Check if we need to sync today
  Future<void> checkAndSyncOnLogin(String studentId, {String? classId}) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    
    bool shouldSync = false;
    
    if (lastSyncStr == null) {
      shouldSync = true;
    } else {
      final lastSync = DateTime.parse(lastSyncStr);
      // If last sync was NOT today, sync now
      if (lastSync.year != now.year || lastSync.month != now.month || lastSync.day != now.day) {
        shouldSync = true;
      }
    }

    if (shouldSync) {
      debugPrint('🔄 Auto-syncing attendance for today...');
      await syncData(studentId, classId: classId);
    }
  }

  /// Manually trigger a refresh
  Future<void> refreshNow(String studentId, {String? classId}) async {
    await syncData(studentId, classId: classId);
  }

  /// Force sync data from Firestore
  Future<void> syncData(String studentId, {String? classId}) async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      // Fetch current year data (or last 2 months for performance)
      final startDate = DateTime(now.year, now.month - 1, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      final records = await _attendanceService.getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      // Save to local cache
      await _cacheAttendance(studentId, records);
      
      // Update last sync time (PKT)
      final nowPkt = DateTime.now().toUtc().add(const Duration(hours: 5));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, nowPkt.toIso8601String());
      
      debugPrint('✅ Attendance synced locally for $studentId');
    } catch (e) {
      debugPrint('❌ Error syncing attendance: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get attendance records for a specific month from local cache
  Future<List<AttendanceModel>> getLocalAttendance(String studentId, int month, int year) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix$studentId';
    final cachedData = prefs.getString(cacheKey);
    
    if (cachedData == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded
          .map((item) => AttendanceModel.fromMap(item as Map<String, dynamic>, item['id'] ?? ''))
          .where((r) => r.date.month == month && r.date.year == year)
          .toList();
    } catch (e) {
      debugPrint('❌ Error reading local attendance: $e');
      return [];
    }
  }

  Future<void> _cacheAttendance(String studentId, List<AttendanceModel> records) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix$studentId';
    
    final data = records.map((r) {
      final map = r.toMap();
      map['id'] = r.id; // Ensure ID is preserved for deserialization
      return map;
    }).toList();
    
    await prefs.setString(cacheKey, jsonEncode(data));
  }

  /// Calculate Percentage from local data
  double calculateMonthPercentage(List<AttendanceModel> monthRecords) {
    if (monthRecords.isEmpty) return 0.0;
    final present = monthRecords.where((r) => r.isPresent).length;
    return (present / monthRecords.length) * 100;
  }
}
