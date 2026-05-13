import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';

/// Admin screen for creating and managing school announcements
class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() =>
      _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AnnouncementService _announcementService = AnnouncementService();
  final int _maxLength = 500;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendAnnouncement() async {
    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Please enter a message', isError: true);
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.send, color: PlayfulTheme.primaryTeal),
            SizedBox(width: 12),
            Text('Send Announcement?'),
          ],
        ),
        content: const Text(
          'This will send the announcement to all students. Continue?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlayfulTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final adminUid = authService.currentUser?.uid ?? '';

      final success = await _announcementService.createAdminAnnouncement(
        message: _messageController.text.trim(),
        adminUid: adminUid,
      );

      if (success) {
        _messageController.clear();
        _showSnackBar('✅ Announcement sent to all students!');
      } else {
        _showSnackBar('Failed to send announcement', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _deleteAnnouncement(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: const Text('Delete Announcement?'),
            ),
          ],
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _announcementService.deleteItem(
      'admin_announcements',
      id,
    );

    if (success) {
      _showSnackBar('Announcement deleted');
    } else {
      _showSnackBar('Failed to delete', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : PlayfulTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlayfulTheme.bgColor,
      appBar: AppBar(
        title: const Text('School Announcements'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Input section
          Container(
            margin: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: PlayfulTheme.primaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'New Announcement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  maxLength: _maxLength,
                  decoration: InputDecoration(
                    hintText: 'Type your announcement here...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: PlayfulTheme.primaryTeal,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: PlayfulTheme.bgColor,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendAnnouncement,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSending ? 'Sending...' : 'Send to All Students'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlayfulTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),

          // Announcements list header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: PlayfulTheme.primaryTeal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sent Announcements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Announcements list
          Expanded(
            child: StreamBuilder<List<AdminAnnouncement>>(
              stream: _announcementService.streamAdminAnnouncements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: PlayfulTheme.primaryTeal,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading announcements',
                          style: TextStyle(fontSize: 18),
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

                final announcements = snapshot.data ?? [];

                if (announcements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first announcement above',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    return Dismissible(
                      key: Key(announcement.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        await _deleteAnnouncement(announcement.id);
                        return false; // We handle deletion manually
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: PlayfulTheme.primaryTeal.withOpacity(0.2),
                          ),
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
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMM d, yyyy • h:mm a')
                                      .format(announcement.timestamp),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  iconSize: 20,
                                  onPressed: () =>
                                      _deleteAnnouncement(announcement.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              announcement.message,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: (50 * index).ms).fadeIn().slideX(
                            begin: 0.2,
                            end: 0,
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
