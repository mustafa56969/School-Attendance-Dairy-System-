import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;
  final String classId;
  final String subjectId;
  final String subjectName;
  final String content;
  final DateTime date;
  final String teacherId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DiaryModel({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.content,
    required this.date,
    required this.teacherId,
    required this.createdAt,
    this.updatedAt,
  });

  factory DiaryModel.fromMap(Map<String, dynamic> data, String id) {
    // Handle date conversion properly
    DateTime parsedDate;
    DateTime parsedCreatedAt;
    DateTime? parsedUpdatedAt;

    try {
      // Try to parse the date field
      if (data['date'] is Timestamp) {
        parsedDate = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is DateTime) {
        parsedDate = data['date'] as DateTime;
      } else if (data['date'] is String) {
        parsedDate = DateTime.parse(data['date']);
      } else {
        // Default to today if parsing fails
        parsedDate = DateTime.now();
      }

      // Try to parse the createdAt field
      if (data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is DateTime) {
        parsedCreatedAt = data['createdAt'] as DateTime;
      } else if (data['createdAt'] is String) {
        parsedCreatedAt = DateTime.parse(data['createdAt']);
      } else {
        // Default to now if parsing fails
        parsedCreatedAt = DateTime.now();
      }

      // Try to parse the updatedAt field
      if (data['updatedAt'] != null) {
        if (data['updatedAt'] is Timestamp) {
          parsedUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] is DateTime) {
          parsedUpdatedAt = data['updatedAt'] as DateTime;
        } else if (data['updatedAt'] is String) {
          parsedUpdatedAt = DateTime.parse(data['updatedAt']);
        }
      }
    } catch (e) {
      // If any parsing fails, use default values
      parsedDate = DateTime.now();
      parsedCreatedAt = DateTime.now();
      parsedUpdatedAt = null;
    }

    return DiaryModel(
      id: id,
      classId: data['classId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? data['subject'] ?? '',
      content: data['content'] ?? '',
      date: parsedDate,
      teacherId: data['teacherId'] ?? '',
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'content': content,
      'date': date,
      'teacherId': teacherId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
