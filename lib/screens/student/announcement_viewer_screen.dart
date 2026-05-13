import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/notification_service.dart';
import '../../theme/playful_theme.dart';

/// Screen for viewing school announcements in compact grid
class AnnouncementViewerScreen extends StatefulWidget {
  const AnnouncementViewerScreen({super.key});

  @override
  State<AnnouncementViewerScreen> createState() =>
      _AnnouncementViewerScreenState();
}

class _AnnouncementViewerScreenState extends State<AnnouncementViewerScreen> {
  final AnnouncementService _announcementService = AnnouncementService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _clearBadge();
  }

  Future<void> _clearBadge() async {
    await _notificationService.clearBadge('admin_announcements');
  }

  void _showAnnouncementDetail(AdminAnnouncement announcement) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: PlayfulTheme.primaryTeal.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PlayfulTheme.primaryTeal,
                      PlayfulTheme.primaryTeal.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'School Announcement',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Important Message',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: PlayfulTheme.primaryTeal.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: PlayfulTheme.primaryTeal,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMMM d, yyyy').format(announcement.timestamp),
                              style: const TextStyle(
                                fontSize: 13,
                                color: PlayfulTheme.primaryTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: PlayfulTheme.primaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('h:mm a').format(announcement.timestamp),
                              style: const TextStyle(
                                fontSize: 13,
                                color: PlayfulTheme.primaryTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Message Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          announcement.message,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.7,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PlayfulTheme.primaryTeal.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: PlayfulTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This announcement was sent to all students',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.campaign,
                    color: PlayfulTheme.primaryTeal,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'School Announcements',
                    style: TextStyle(
                      fontSize: 24,
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
          ).animate().fadeIn(),

          // Announcements grid
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
                  return _buildErrorState(snapshot.error);
                }

                final announcements = snapshot.data ?? [];

                if (announcements.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  color: PlayfulTheme.primaryTeal,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0, // Adjusted to prevent overflow
                    ),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return _buildAnnouncementGridCard(announcement)
                          .animate(delay: (50 * index).ms)
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildAnnouncementGridCard(AdminAnnouncement announcement) {
    // Truncate message for grid view - shorter for better fit
    final preview = announcement.message.length > 80
        ? '${announcement.message.substring(0, 80)}...'
        : announcement.message;

    return InkWell(
      onTap: () => _showAnnouncementDetail(announcement),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PlayfulTheme.primaryTeal.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PlayfulTheme.primaryTeal.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: PlayfulTheme.primaryTeal,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM d').format(announcement.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PlayfulTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message preview
            Expanded(
              child: Text(
                preview,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    DateFormat('h:mm a').format(announcement.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 80,
                color: PlayfulTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Announcements Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check back later for important updates\nfrom the school administration',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().scale(curve: Curves.elasticOut);
  }

  Widget _buildErrorState(dynamic error) {
    debugPrint('📢 Announcement Screen Error: $error');
    String errorMessage = 'Please check your connection\nand try again';
    
    if (error.toString().contains('permission-denied')) {
      errorMessage = 'Missing or insufficient permissions.\nCheck Firebase Security Rules.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlayfulTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
