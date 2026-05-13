import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';

/// Student screen for sending messages to admin
class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AnnouncementService _announcementService = AnnouncementService();
  String _selectedCategory = 'General';
  bool _isSending = false;

  final List<String> _categories = [
    'General',
    'Complaint',
    'Request',
    'Suggestion',
    'Question',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Please enter a message', isError: true);
      return;
    }

    // Show warning dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Important Notice',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ This message will be sent directly to the school administration.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Only send important messages\n• Be respectful and clear\n• Do not spam or misuse this feature\n• False complaints may have consequences',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              'Are you sure you want to send this message?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlayfulTheme.accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userModel = authService.userModel;

      if (userModel == null) {
        _showSnackBar('User not found', isError: true);
        return;
      }

      final success = await _announcementService.createStudentMessage(
        message: _messageController.text.trim(),
        studentUid: userModel.uid,
        studentName: userModel.name ?? 'Unknown Student',
        classId: userModel.classId ?? 'Unknown',
        category: _selectedCategory,
      );

      if (success) {
        _messageController.clear();
        _showSnackBar('✅ Message sent to admin!');
      } else {
        _showSnackBar('Failed to send message', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Message?'),
          ],
        ),
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
      'student_messages',
      messageId,
    );

    if (success) {
      _showSnackBar('Message deleted');
    } else {
      _showSnackBar('Failed to delete', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : PlayfulTheme.accentOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final studentUid = authService.currentUser?.uid ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mail,
                    color: PlayfulTheme.accentOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message to Admin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Use responsibly',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ).animate().fadeIn(),

          // Warning banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is a sensitive feature. Only send important messages.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Input section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category selection
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: PlayfulTheme.accentOrange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Message input
                  const Text(
                    'Your Message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: PlayfulTheme.accentOrange,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendMessage,
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
                      label: Text(_isSending ? 'Sending...' : 'Send to Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlayfulTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sent messages
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: PlayfulTheme.accentOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Sent Messages',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<List<StudentMessage>>(
                    stream: _announcementService.streamStudentMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: PlayfulTheme.accentOrange,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Could not load message history.\n${snapshot.error.toString().contains('permission-denied') ? 'Missing Permissions' : 'Error loading data'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        );
                      }

                      final allMessages = snapshot.data ?? [];
                      final myMessages = allMessages
                          .where((msg) => msg.studentId == studentUid)
                          .toList();

                      if (myMessages.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  size: 48,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No messages sent yet',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: myMessages.length,
                        itemBuilder: (context, index) {
                          final message = myMessages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: message.isRead
                                  ? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5)
                                  : PlayfulTheme.accentOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: message.isRead
                                    ? Theme.of(context).dividerColor.withOpacity(0.1)
                                    : PlayfulTheme.accentOrange.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: PlayfulTheme.accentOrange
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        message.category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: PlayfulTheme.accentOrange,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (message.isRead)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 12, color: Colors.green),
                                            SizedBox(width: 4),
                                            Text(
                                              'Read',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20),
                                      color: Colors.red,
                                      onPressed: () =>
                                          _deleteMessage(message.id),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  message.message,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('MMM d, yyyy • h:mm a')
                                      .format(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutCubic);
  }
}
