import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import 'cache_service.dart';
import 'notification_service.dart';

/// Service to manage announcements and messages
class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Collection names
  static const String _adminAnnouncementsCollection = 'admin_announcements';
  static const String _studentMessagesCollection = 'student_messages';

  // Cache keys
  static const String _adminAnnouncementsCacheKey = 'admin_announcements';
  static const String _studentMessagesCacheKey = 'student_messages';

  // Auto-deletion threshold (30 days)
  static const int _deletionThresholdDays = 30;

  /// Create admin announcement
  Future<bool> createAdminAnnouncement({
    required String message,
    required String adminUid,
  }) async {
    try {
      final announcement = AdminAnnouncement(
        id: '',
        message: message,
        timestamp: DateTime.now(),
        createdBy: adminUid,
      );

      await _firestore
          .collection(_adminAnnouncementsCollection)
          .add(announcement.toMap());

      // Clear cache to force refresh
      await CacheService.clearCache(_adminAnnouncementsCacheKey);

      // Send FCM notification to all users (students and teachers)
      await _sendAnnouncementToAllUsers(
        title: 'New School Announcement',
        body: message.length > 100 ? '${message.substring(0, 100)}...' : message,
      );

      debugPrint('✅ Admin announcement created and sent to all users');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating admin announcement: $e');
      return false;
    }
  }

  /// Send announcement to all users via FCM
  Future<void> _sendAnnouncementToAllUsers({
    required String title,
    required String body,
  }) async {
    try {
      // Get all users (students and teachers)
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['student', 'teacher'])
          .get();

      debugPrint('📨 Sending announcement to ${usersSnapshot.docs.length} users');

      // For now, we'll store the notification data in Firestore
      // In a production app, you would use Cloud Functions to send actual FCM messages
      // Or use a server-side API

      // Show local notification for the current device
      await _notificationService.showLocalNotification(
        title: title,
        body: body,
        payload: 'admin_announcement',
      );

      // Create a broadcast notification document that can be picked up by clients
      await _firestore.collection('broadcast_notifications').add({
        'title': title,
        'body': body,
        'type': 'admin_announcement',
        'timestamp': FieldValue.serverTimestamp(),
        'sentTo': ['student', 'teacher'],
      });

      debugPrint('✅ Announcement broadcast created');

      // Note: For true FCM push notifications, you would need to implement:
      // 1. Cloud Functions to send FCM messages
      // 2. Or use an HTTP API to Firebase Cloud Messaging
      // This is a simplified version that works for demonstration
    } catch (e) {
      debugPrint('❌ Error sending announcement: $e');
    }
  }



  /// Create student message
  Future<bool> createStudentMessage({
    required String message,
    required String studentUid,
    required String studentName,
    required String classId,
    required String category,
  }) async {
    try {
      final studentMessage = StudentMessage(
        id: '',
        message: message,
        studentId: studentUid,
        studentName: studentName,
        classId: classId,
        category: category,
        timestamp: DateTime.now(),
        isRead: false,
      );

      debugPrint('📝 Attempting to create student message for: $studentUid');
      await _firestore
          .collection(_studentMessagesCollection)
          .add(studentMessage.toMap());
      debugPrint('✅ Student message added to collection');

      // Clear cache
      await CacheService.clearCache(_studentMessagesCacheKey);

      // Create a broadcast notification for admins
      debugPrint('📝 Attempting to create broadcast notification for admin');
      await _firestore.collection('broadcast_notifications').add({
        'title': 'New Message from $studentName',
        'body': message.length > 100 ? '${message.substring(0, 100)}...' : message,
        'type': 'student_message',
        'timestamp': FieldValue.serverTimestamp(),
        'sentTo': ['admin'],
      });

      debugPrint('✅ Student message created and broadcast to admin');
      return true;
    } catch (e) {
      debugPrint('❌ Error in createStudentMessage: $e');
      if (e is FirebaseException) {
        debugPrint('   Code: ${e.code}');
        debugPrint('   Message: ${e.message}');
      }
      return false;
    }
  }

  /// Get admin announcements with cache
  Future<List<AdminAnnouncement>> getAdminAnnouncements() async {
    try {
      // Try cache first
      final cachedData =
          await CacheService.getCachedFirestoreData(_adminAnnouncementsCacheKey);
      if (cachedData != null) {
        return cachedData
            .map((data) => AdminAnnouncement.fromMap(data, data['id']))
            .toList();
      }

      // Fetch from Firestore
      final snapshot = await _firestore
          .collection(_adminAnnouncementsCollection)
          .get();

      // Cache the data
      await CacheService.cacheFirestoreSnapshot(
        _adminAnnouncementsCacheKey,
        snapshot,
      );

      // Delete old announcements
      await _deleteOldAnnouncements(_adminAnnouncementsCollection);

      final results = snapshot.docs
          .map((doc) => AdminAnnouncement.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort in memory
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    } catch (e) {
      debugPrint('❌ Error getting admin announcements: $e');
      return [];
    }
  }



  /// Get student messages with cache
  Future<List<StudentMessage>> getStudentMessages() async {
    try {
      // Try cache first
      final cachedData =
          await CacheService.getCachedFirestoreData(_studentMessagesCacheKey);
      if (cachedData != null) {
        return cachedData
            .map((data) => StudentMessage.fromMap(data, data['id']))
            .toList();
      }

      // Fetch from Firestore
      final snapshot = await _firestore
          .collection(_studentMessagesCollection)
          .get();

      // Cache the data
      await CacheService.cacheFirestoreSnapshot(
        _studentMessagesCacheKey,
        snapshot,
      );

      // Delete old messages
      await _deleteOldAnnouncements(_studentMessagesCollection);

      final results = snapshot.docs
          .map((doc) => StudentMessage.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in memory
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    } catch (e) {
      debugPrint('❌ Error getting student messages: $e');
      return [];
    }
  }

  /// Delete announcement/message
  Future<bool> deleteItem(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();

      // Clear relevant cache
      if (collection == _adminAnnouncementsCollection) {
        await CacheService.clearCache(_adminAnnouncementsCacheKey);
      } else if (collection == _studentMessagesCollection) {
        await CacheService.clearCache(_studentMessagesCacheKey);
      }

      debugPrint('✅ Item deleted from $collection');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting item: $e');
      return false;
    }
  }

  /// Mark student message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      await _firestore
          .collection(_studentMessagesCollection)
          .doc(messageId)
          .update({'isRead': true});

      // Decrement badge
      await _notificationService.decrementBadge('student_messages');

      // Clear cache
      await CacheService.clearCache(_studentMessagesCacheKey);

      debugPrint('✅ Message marked as read');
      return true;
    } catch (e) {
      debugPrint('❌ Error marking message as read: $e');
      return false;
    }
  }

  /// Get unread student messages count
  Future<int> getUnreadMessagesCount() async {
    try {
      final snapshot = await _firestore
          .collection(_studentMessagesCollection)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete old announcements/messages (older than 30 days)
  Future<void> _deleteOldAnnouncements(String collection) async {
    try {
      final cutoffDate =
          DateTime.now().subtract(Duration(days: _deletionThresholdDays));

      final snapshot = await _firestore
          .collection(collection)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      // Delete in batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        debugPrint(
          '🗑️ Deleted ${snapshot.docs.length} old items from $collection',
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting old announcements: $e');
    }
  }

  /// Stream admin announcements
  Stream<List<AdminAnnouncement>> streamAdminAnnouncements() {
    return _firestore
        .collection(_adminAnnouncementsCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AdminAnnouncement.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }



  /// Stream student messages
  Stream<List<StudentMessage>> streamStudentMessages() {
    return _firestore
        .collection(_studentMessagesCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => StudentMessage.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }
}
