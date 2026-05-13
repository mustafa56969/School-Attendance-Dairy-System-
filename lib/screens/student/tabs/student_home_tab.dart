import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/auth_service.dart';
import '../../../services/diary_service.dart';
import '../../../models/diary_model.dart';
import '../../../theme/playful_theme.dart';
import '../../../widgets/loading_widget.dart' hide EmptyStateWidget;
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/vibrant_error_widget.dart';

class StudentHomeTab extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const StudentHomeTab({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  late DiaryService _diaryService;

  @override
  void initState() {
    super.initState();
    _diaryService = DiaryService();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userClass = authService.userModel?.classId ?? '';

    if (userClass.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyStateWidget(
          title: 'No Class Assigned',
          message: 'Please contact your teacher to assign you to a class.',
          icon: Icons.class_outlined,
          iconColor: PlayfulTheme.primaryTeal,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // We'll put all our content in a single child since we can't use MultiSliver
            return Column(
              children: [
                // Date Header with Homework Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(widget.selectedDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('y').format(widget.selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: PlayfulTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('diaries')
                          .where('classId', isEqualTo: userClass)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Loading...',
                              style: TextStyle(
                                color: PlayfulTheme.primaryTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        // Count diaries for the selected date only
                        final docs = snapshot.data?.docs ?? [];
                        int count = 0;
                        for (var doc in docs) {
                          try {
                            final data = doc.data() as Map<String, dynamic>;
                            if (data['date'] is Timestamp) {
                              final date = (data['date'] as Timestamp).toDate();
                              if (date.year == widget.selectedDate.year &&
                                  date.month == widget.selectedDate.month &&
                                  date.day == widget.selectedDate.day) {
                                count++;
                              }
                            }
                          } catch (e) {
                            // Skip documents with date parsing errors
                          }
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count ${count == 1 ? 'subject' : 'subjects'}',
                            style: TextStyle(
                              color: PlayfulTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 20),

                // Diary Entries List with Offline Support
                FutureBuilder<List<DiaryModel>>(
                  // First try to get cached data for immediate display
                  future: _diaryService.getCachedDiariesForClass(
                    userClass,
                    widget.selectedDate,
                  ),
                  builder: (context, cachedSnapshot) {
                    // If we have cached data, show it immediately
                    if (cachedSnapshot.hasData &&
                        cachedSnapshot.data!.isNotEmpty) {
                      final cachedDiaries = _filterAndSortDiaries(
                        cachedSnapshot.data!,
                        widget.selectedDate,
                      );

                      if (cachedDiaries.isNotEmpty) {
                        return _buildDiaryList(cachedDiaries, isCached: true);
                      }
                    }

                    // Otherwise, fetch fresh data from Firestore
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('diaries')
                          .where('classId', isEqualTo: userClass)
                          .snapshots(),
                      builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            // If we have cached data, show it even if there's an error
                            if (cachedSnapshot.hasData &&
                                cachedSnapshot.data!.isNotEmpty) {
                              final cachedDiaries = _filterAndSortDiaries(
                                cachedSnapshot.data!,
                                widget.selectedDate,
                              );

                              if (cachedDiaries.isNotEmpty) {
                                return _buildDiaryList(
                                  cachedDiaries,
                                  isCached: true,
                                );
                              }
                            }

                            return _buildErrorWidget(snapshot.error.toString());
                          }

                        if (snapshot.connectionState == 
                                ConnectionState.waiting &&
                            (!cachedSnapshot.hasData ||
                                cachedSnapshot.data!.isEmpty)) {
                          return LoadingWidget(
                            message: 'Loading your homework...',
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        print('Number of documents found: ${docs.length}');

                        // Filter documents for the selected date and convert to DiaryModel objects
                        final diaries = <DiaryModel>[];

                        for (var doc in docs) {
                          try {
                            final data = doc.data() as Map<String, dynamic>;
                            // Check if the diary is for the selected date
                            if (data['date'] is Timestamp) {
                              final diaryDate = (data['date'] as Timestamp)
                                  .toDate();
                              if (diaryDate.year == widget.selectedDate.year &&
                                  diaryDate.month ==
                                      widget.selectedDate.month &&
                                  diaryDate.day == widget.selectedDate.day) {
                                final diary = DiaryModel.fromMap(data, doc.id);
                                diaries.add(diary);
                              }
                            }
                          } catch (e) {
                            print('Error converting document ${doc.id}: $e');
                          }
                        }

                        print(
                          'Number of diaries after filtering: ${diaries.length}',
                        );

                        // Sort diaries by subject name
                        diaries.sort(
                          (a, b) => a.subjectName.compareTo(b.subjectName),
                        );

                        // If no diaries found from network, but we have cached ones, show cached
                        if (diaries.isEmpty &&
                            cachedSnapshot.hasData &&
                            cachedSnapshot.data!.isNotEmpty) {
                          final cachedDiaries = _filterAndSortDiaries(
                            cachedSnapshot.data!,
                            widget.selectedDate,
                          );

                          if (cachedDiaries.isNotEmpty) {
                            return _buildDiaryList(
                              cachedDiaries,
                              isCached: true,
                            );
                          }
                        }

                        if (diaries.isEmpty) {
                          return EmptyStateWidget(
                            title: 'No homework for this day! 🎉',
                            message: 'Enjoy your free time!',
                            icon: Icons.event_available_rounded,
                            iconColor: PlayfulTheme.primaryTeal,
                          );
                        }

                        return _buildDiaryList(diaries, isCached: false);
                      },
                    );
                  },
                ),
              ],
            );
          },
          childCount: 1, // Single child containing everything
        ),
      ),
    );
  }

  List<DiaryModel> _filterAndSortDiaries(
    List<DiaryModel> diaries,
    DateTime selectedDate,
  ) {
    // Filter for selected date
    final filtered = diaries.where((diary) {
      return diary.date.year == selectedDate.year &&
          diary.date.month == selectedDate.month &&
          diary.date.day == selectedDate.day;
    }).toList();

    // Sort by subject name
    filtered.sort((a, b) => a.subjectName.compareTo(b.subjectName));

    return filtered;
  }

  Widget _buildDiaryList(List<DiaryModel> diaries, {required bool isCached}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        childAspectRatio: 0.85, // Card height ratio
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: diaries.length,
      itemBuilder: (context, i) {
        return Stack(
          children: [
            _buildDiaryCard(diaries[i]),
            if (isCached)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        )
            .animate(delay: (100 * i).ms)
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}), // Retry
            style: ElevatedButton.styleFrom(
              backgroundColor: PlayfulTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(DiaryModel entry) {
    // Generate a consistent color based on subject name
    final colors = [
      PlayfulTheme.primaryTeal,
      PlayfulTheme.accentOrange,
      PlayfulTheme.accentPurple,
      PlayfulTheme.primaryPink,
      PlayfulTheme.primaryRed,
      PlayfulTheme.primaryYellow,
    ];
    final colorIndex = entry.subjectName.hashCode % colors.length;
    final color = colors[colorIndex];

    // Short preview for grid
    final preview = entry.content.length > 60
        ? '${entry.content.substring(0, 60)}...'
        : entry.content;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.subjectName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Homework label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HOMEWORK',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Preview text
                  Expanded(
                    child: Text(
                      preview,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: PlayfulTheme.textMain,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tap to view indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Tap to view',
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
