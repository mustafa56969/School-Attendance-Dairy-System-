import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/diary_service.dart';
import '../../services/notification_service.dart';
import '../../models/diary_model.dart';
import '../../theme/playful_theme.dart';
import '../../widgets/glassy_icon_button.dart';
import 'announcement_viewer_screen.dart';
import 'send_message_screen.dart';

class VibrantStudentHome extends StatefulWidget {
  const VibrantStudentHome({super.key});

  @override
  State<VibrantStudentHome> createState() => _VibrantStudentHomeState();
}

class _VibrantStudentHomeState extends State<VibrantStudentHome> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  DateTime _selectedDate = DateTime.now();
  late DiaryService _diaryService;
  final NotificationService _notificationService = NotificationService();
  
  int _adminAnnouncementBadge = 0;

  @override
  void initState() {
    super.initState();
    _diaryService = DiaryService();
    _loadBadgeCounts();
  }

  Future<void> _loadBadgeCounts() async {
    final adminCount = await _notificationService.getBadgeCount('admin_announcements');
    
    if (mounted) {
      setState(() {
        _adminAnnouncementBadge = adminCount;
      });
    }
  }

  // Show date picker to allow selection of any date
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: PlayfulTheme.primaryTeal,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: PlayfulTheme.primaryTeal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Show beautiful modal with full diary details
  void _showDiaryDetailModal(DiaryModel diary) {
    try {
      final colors = [
        PlayfulTheme.primaryTeal,
        PlayfulTheme.primaryPink,
        PlayfulTheme.primaryOrange,
        PlayfulTheme.accentPurple,
        PlayfulTheme.primaryRed,
        PlayfulTheme.primaryYellow,
      ];
      final colorIndex = diary.subjectName.hashCode.abs() % colors.length;
      final color = colors[colorIndex];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
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

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon and subject
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getSubjectIcon(diary.subjectName),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diary.subjectName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Homework Assignment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Date and time info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: color, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat('EEE, MMM d, yyyy').format(diary.date),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.access_time, color: color, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('h:mm a').format(diary.date),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Homework content section
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: PlayfulTheme.primaryPink.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment,
                                color: PlayfulTheme.primaryPink,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Homework Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Full content
                         Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            diary.content.isNotEmpty 
                                ? diary.content 
                                : 'No homework details available.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Close button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Got it!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutCubic),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing diary modal: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to display diary details: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = Provider.of<AuthService>(context);
    final userName = authService.userModel?.name ?? 'Student';
    final userClass = authService.userModel?.classId ?? '';

    // Show error message if user has no class assigned
    if (userClass.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 24),
              const Text(
                'No class assigned',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Please contact your teacher or admin to assign you to a class.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Try to refresh user data
                  Provider.of<AuthService>(
                    context,
                    listen: false,
                  ).checkLoginStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlayfulTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with greeting
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PlayfulTheme.primaryTeal.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.15),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // App Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/logo.webp',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn(duration: 400.ms),
                            const SizedBox(height: 4),
                            Text(
                              'Ready to learn today?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          ],
                        ),
                      ),
                      // Announcement buttons
                      Row(
                        children: [
                          // Admin announcement button (school icon)
                          GlassyIconButton(
                            icon: Icons.campaign,
                            color: PlayfulTheme.primaryTeal,
                            badgeCount: _adminAnnouncementBadge,
                            size: 48,
                            onTap: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => DraggableScrollableSheet(
                                  initialChildSize: 0.85,
                                  minChildSize: 0.5,
                                  maxChildSize: 0.95,
                                  builder: (context, scrollController) =>
                                      const AnnouncementViewerScreen(),
                                ),
                              );
                              _loadBadgeCounts();
                            },
                          ).animate(delay: 200.ms).fadeIn().scale(),
                          const SizedBox(width: 12),
                          // Message to admin button (envelope)
                          GlassyIconButton(
                            icon: Icons.mail_outline,
                            color: PlayfulTheme.accentOrange,
                            size: 44,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => DraggableScrollableSheet(
                                  initialChildSize: 0.85,
                                  minChildSize: 0.5,
                                  maxChildSize: 0.95,
                                  builder: (context, scrollController) =>
                                      const SendMessageScreen(),
                                ),
                              );
                            },
                          ).animate(delay: 300.ms).fadeIn().scale(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Date Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child:
                  Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: PlayfulTheme.primaryTeal,
                            ),
                          ),
                          title: Text(
                            DateFormat(
                              'EEEE, MMMM d, yyyy',
                            ).format(_selectedDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text('Tap to change date', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          onTap: _showDatePicker,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      ),
            ),
          ),

          // Homework Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.primaryPink.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.book_rounded,
                      color: PlayfulTheme.primaryPink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Today\'s Homework',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('diaries')
                        .where('classId', isEqualTo: userClass)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      // Count diaries for the selected date only
                      final docs = snapshot.data?.docs ?? [];
                      int count = 0;
                      for (var doc in docs) {
                        try {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['date'] is Timestamp) {
                            final date = (data['date'] as Timestamp).toDate();
                            if (date.year == _selectedDate.year &&
                                date.month == _selectedDate.month &&
                                date.day == _selectedDate.day) {
                              count++;
                            }
                          }
                        } catch (e) {
                          // Skip documents with date parsing errors
                        }
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PlayfulTheme.primaryPink.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: PlayfulTheme.primaryPink.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.assignment,
                              size: 16,
                              color: PlayfulTheme.primaryPink,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$count',
                              style: const TextStyle(
                                color: PlayfulTheme.primaryPink,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ),

          // Diary Entries List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('diaries')
                .where('classId', isEqualTo: userClass)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Homework',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}), // Retry
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlayfulTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: PlayfulTheme.primaryTeal,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading your homework...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Filter documents for the selected date and convert to DiaryModel objects
              final diaries = <DiaryModel>[];

              for (var doc in docs) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  // Check if the diary is for the selected date
                  if (data['date'] is Timestamp) {
                    final diaryDate = (data['date'] as Timestamp).toDate();
                    if (diaryDate.year == _selectedDate.year &&
                        diaryDate.month == _selectedDate.month &&
                        diaryDate.day == _selectedDate.day) {
                      final diary = DiaryModel.fromMap(data, doc.id);
                      diaries.add(diary);
                    }
                  }
                } catch (e) {
                  // Skip documents with parsing errors
                }
              }

              // Sort diaries by subject name
              diaries.sort((a, b) => a.subjectName.compareTo(b.subjectName));

              if (diaries.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: PlayfulTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No homework for today! 🎉',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enjoy your free time!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(curve: Curves.elasticOut),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns for mobile
                    childAspectRatio: 0.85, // More compact "small" design
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () => _showDiaryDetailModal(diaries[index]),
                        child: _buildDiaryCard(diaries[index]),
                      )
                          .animate(delay: (100 * index).ms)
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            curve: Curves.easeOutBack,
                          );
                    },
                    childCount: diaries.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(DiaryModel entry) {
    // Generate a consistent color based on subject name
    final colors = [
      PlayfulTheme.primaryTeal,
      PlayfulTheme.primaryPink,
      PlayfulTheme.primaryOrange,
      PlayfulTheme.accentPurple,
      PlayfulTheme.primaryRed,
      PlayfulTheme.primaryYellow,
    ];
    final colorIndex = entry.subjectName.hashCode.abs() % colors.length;
    final color = colors[colorIndex];

    // Short preview for card
    final preview = entry.content.length > 50
        ? '${entry.content.substring(0, 50)}...'
        : entry.content;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background soft Glow/Wash
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon and Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSubjectIcon(entry.subjectName),
                        color: color,
                        size: 18,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(entry.date),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Subject Name
                Text(
                  entry.subjectName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Content (Compact)
                Expanded(
                  child: Text(
                    preview,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: PlayfulTheme.textMain.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Bottom Action Link (Compact)
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 14,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  IconData _getSubjectIcon(String subjectName) {
    final lowerName = subjectName.toLowerCase();

    if (lowerName.contains('math')) return Icons.calculate_outlined;
    if (lowerName.contains('science')) return Icons.science_outlined;
    if (lowerName.contains('english')) return Icons.language_outlined;
    if (lowerName.contains('history')) return Icons.history_edu_outlined;
    if (lowerName.contains('geography')) return Icons.public_outlined;
    if (lowerName.contains('art')) return Icons.palette_outlined;
    if (lowerName.contains('music')) return Icons.music_note_outlined;
    if (lowerName.contains('physical') || lowerName.contains('sport'))
      return Icons.sports_soccer_outlined;
    if (lowerName.contains('computer') || lowerName.contains('tech'))
      return Icons.computer_outlined;

    return Icons.school_outlined;
  }
}
