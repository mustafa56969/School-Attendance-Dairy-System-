import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for admin announcements sent to all students
class AdminAnnouncement {
  final String id;
  final String message;
  final DateTime timestamp;
  final String createdBy; // Admin UID

  AdminAnnouncement({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.createdBy,
  });

  factory AdminAnnouncement.fromMap(Map<String, dynamic> data, String id) {
    DateTime ts;
    try {
      if (data['timestamp'] is Timestamp) {
        ts = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp'] is String) {
        ts = DateTime.parse(data['timestamp']);
      } else {
        ts = DateTime.now();
      }
    } catch (e) {
      ts = DateTime.now();
    }

    return AdminAnnouncement(
      id: id,
      message: data['message'] ?? '',
      timestamp: ts,
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdBy': createdBy,
    };
  }
}

/// Model for student messages sent to admin
class StudentMessage {
  final String id;
  final String message;
  final String studentId;
  final String studentName;
  final String classId;
  final String category; // General, Complaint, Request, etc.
  final DateTime timestamp;
  final bool isRead;

  StudentMessage({
    required this.id,
    required this.message,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.category,
    required this.timestamp,
    this.isRead = false,
  });

  factory StudentMessage.fromMap(Map<String, dynamic> data, String id) {
    DateTime ts;
    try {
      if (data['timestamp'] is Timestamp) {
        ts = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp'] is String) {
        ts = DateTime.parse(data['timestamp']);
      } else {
        ts = DateTime.now();
      }
    } catch (e) {
      ts = DateTime.now();
    }

    return StudentMessage(
      id: id,
      message: data['message'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      category: data['category'] ?? 'General',
      timestamp: ts,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  StudentMessage copyWith({bool? isRead}) {
    return StudentMessage(
      id: id,
      message: message,
      studentId: studentId,
      studentName: studentName,
      classId: classId,
      category: category,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
