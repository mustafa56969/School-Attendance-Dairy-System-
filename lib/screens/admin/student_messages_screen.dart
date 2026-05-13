import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/notification_service.dart';
import '../../theme/playful_theme.dart';

/// Screen for admin to view student messages in grid layout
class StudentMessagesScreen extends StatefulWidget {
  const StudentMessagesScreen({super.key});

  @override
  State<StudentMessagesScreen> createState() => _StudentMessagesScreenState();
}

class _StudentMessagesScreenState extends State<StudentMessagesScreen> {
  final AnnouncementService _announcementService = AnnouncementService();
  final NotificationService _notificationService = NotificationService();
  String _filter = 'all'; // all, unread, read

  @override
  void initState() {
    super.initState();
    _clearBadge();
  }

  Future<void> _clearBadge() async {
    await _notificationService.clearBadge('student_messages');
  }

  void _showMessageDetail(StudentMessage message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mail,
                      color: PlayfulTheme.accentOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Student Message',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Student details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PlayfulTheme.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: PlayfulTheme.primaryTeal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.studentName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Class ${message.classId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: PlayfulTheme.accentOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: PlayfulTheme.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Message content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.message,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Timestamp and actions
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMMM d, yyyy • h:mm a')
                        .format(message.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (!message.isRead)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _announcementService.markMessageAsRead(message.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Mark as Read'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlayfulTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Delete Message?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _announcementService.deleteItem(
                          'student_messages',
                          message.id,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlayfulTheme.bgColor,
      appBar: AppBar(
        title: const Text('Student Messages'),
        backgroundColor: PlayfulTheme.accentOrange.withOpacity(0.1),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Messages')),
              const PopupMenuItem(value: 'unread', child: Text('Unread Only')),
              const PopupMenuItem(value: 'read', child: Text('Read Only')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<StudentMessage>>(
        stream: _announcementService.streamStudentMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: PlayfulTheme.accentOrange,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading messages',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          var messages = snapshot.data ?? [];

          // Apply filter
          if (_filter == 'unread') {
            messages = messages.where((m) => !m.isRead).toList();
          } else if (_filter == 'read') {
            messages = messages.where((m) => m.isRead).toList();
          }

          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.accentOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      size: 64,
                      color: PlayfulTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _filter == 'unread'
                        ? 'All messages have been read'
                        : 'Students haven\'t sent any messages',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ).animate().scale(curve: Curves.elasticOut);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Reduced to 2 columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5, // Increased to prevent overflow
            ),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageGridCard(message)
                  .animate(delay: (50 * index).ms)
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageGridCard(StudentMessage message) {
    final preview = message.message.length > 80
        ? '${message.message.substring(0, 80)}...'
        : message.message;

    return InkWell(
      onTap: () => _showMessageDetail(message),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced from 14
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: message.isRead
                ? Colors.grey[300]!
                : PlayfulTheme.accentOrange.withOpacity(0.5),
            width: message.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: message.isRead
                  ? Colors.black.withOpacity(0.05)
                  : PlayfulTheme.accentOrange.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Student info and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: PlayfulTheme.accentOrange,
                    size: 12,
                  ),
                ),
                const Spacer(),
                if (!message.isRead)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Student name
            Text(
              message.studentName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Class and category
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Class ${message.classId}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Text('•', style: TextStyle(color: Colors.grey[400], fontSize: 9)),
                const SizedBox(width: 2),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      message.category,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: PlayfulTheme.accentOrange,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Message preview - NO Expanded
            Text(
              preview,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 9,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    DateFormat('MMM d, h:mm a').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 8,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
