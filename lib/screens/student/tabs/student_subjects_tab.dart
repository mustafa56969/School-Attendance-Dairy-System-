import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/auth_service.dart';
import '../../../theme/playful_theme.dart';
import '../../../widgets/subject_chart_widget.dart';
import '../../../widgets/subject_stat_card.dart';
import '../../../widgets/empty_state_widget.dart';

class StudentSubjectsTab extends StatelessWidget {
  const StudentSubjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userClass = authService.userModel?.classId ?? '';

    if (userClass.isEmpty) {
      return const Center(child: Text('No class assigned'));
    }

    return CustomScrollView(
      slivers: [
        // Enhanced header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PlayfulTheme.primaryTeal.withOpacity(0.15),
                  PlayfulTheme.bgColor,
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: PlayfulTheme.primaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'My Subjects',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your learning progress',
                  style: TextStyle(
                    fontSize: 16,
                    color: PlayfulTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Subject Statistics Chart
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('subjects')
              .where('classId', isEqualTo: userClass)
              .snapshots(),
          builder: (context, subjectSnapshot) {
            if (subjectSnapshot.hasError) {
              return SliverToBoxAdapter(
                child: EmptyStateWidget(
                  title: 'Error Loading Subjects',
                  message:
                      'There was an error loading your subjects. Please try again.',
                  icon: Icons.error_outline,
                  iconColor: Colors.red,
                  onRetry: () =>
                      subjectSnapshot, // This will rebuild the widget
                ),
              );
            }

            if (!subjectSnapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final subjects = subjectSnapshot.data!.docs;

            if (subjects.isEmpty) {
              return SliverToBoxAdapter(
                child: EmptyStateWidget(
                  title: 'No Subjects Found',
                  message:
                      'You don\'t have any subjects assigned yet. Please contact your teacher.',
                  icon: Icons.book_outlined,
                  iconColor: PlayfulTheme.primaryTeal,
                ),
              );
            }

            // Get diary counts for each subject
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('diaries')
                  .where('classId', isEqualTo: userClass)
                  .snapshots(),
              builder: (context, diarySnapshot) {
                if (diarySnapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      title: 'Error Loading Data',
                      message:
                          'There was an error loading subject data. Please try again.',
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                      onRetry: () =>
                          diarySnapshot, // This will rebuild the widget
                    ),
                  );
                }

                if (!diarySnapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final diaries = diarySnapshot.data!.docs;

                // Calculate subject weights based on diary count
                final subjectWeights = <Map<String, dynamic>>[];
                final subjectColors = [
                  PlayfulTheme.primaryTeal,
                  PlayfulTheme.accentOrange,
                  PlayfulTheme.accentPurple,
                  PlayfulTheme.primaryPink,
                  PlayfulTheme.primaryRed,
                  PlayfulTheme.primaryYellow,
                  PlayfulTheme.primaryOrange,
                ];

                for (int i = 0; i < subjects.length; i++) {
                  final subject = subjects[i];
                  final subjectData = subject.data() as Map<String, dynamic>;

                  // Count diaries for this subject
                  int diaryCount = 0;
                  for (var diary in diaries) {
                    final diaryData = diary.data() as Map<String, dynamic>;
                    if (diaryData['subjectId'] == subject.id) {
                      diaryCount++;
                    }
                  }

                  subjectWeights.add({
                    'id': subject.id,
                    'name': subjectData['name'],
                    'count': diaryCount,
                    'color': subjectColors[i % subjectColors.length],
                  });
                }

                // Sort by count descending
                subjectWeights.sort((a, b) => b['count'].compareTo(a['count']));

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SubjectChartWidget(subjectData: subjectWeights),
                  ),
                );
              },
            );
          },
        ),

        // Subject List Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              'All Subjects',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Subject List
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('subjects')
              .where('classId', isEqualTo: userClass)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: EmptyStateWidget(
                  title: 'Error Loading Subjects',
                  message:
                      'There was an error loading your subjects. Please try again.',
                  icon: Icons.error_outline,
                  iconColor: Colors.red,
                  onRetry: () => snapshot, // This will rebuild the widget
                ),
              );
            }

            if (!snapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final subjects = snapshot.data!.docs;

            if (subjects.isEmpty) {
              return SliverToBoxAdapter(
                child: EmptyStateWidget(
                  title: 'No Subjects Found',
                  message:
                      'You don\'t have any subjects assigned yet. Please contact your teacher.',
                  icon: Icons.book_outlined,
                  iconColor: PlayfulTheme.primaryTeal,
                ),
              );
            }

            // Get diary data for progress calculation
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('diaries')
                  .where('classId', isEqualTo: userClass)
                  .snapshots(),
              builder: (context, diarySnapshot) {
                if (diarySnapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      title: 'Error Loading Data',
                      message:
                          'There was an error loading subject data. Please try again.',
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                    ),
                  );
                }

                if (!diarySnapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final diaries = diarySnapshot.data!.docs;
                final subjectColors = [
                  PlayfulTheme.primaryTeal,
                  PlayfulTheme.accentOrange,
                  PlayfulTheme.accentPurple,
                  PlayfulTheme.primaryPink,
                  PlayfulTheme.primaryRed,
                  PlayfulTheme.primaryYellow,
                  PlayfulTheme.primaryOrange,
                ];

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.9,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final subject = subjects[index];
                      final subjectData =
                          subject.data() as Map<String, dynamic>;
                      final color = subjectColors[index % subjectColors.length];

                      // Count diaries for this subject
                      int diaryCount = 0;
                      for (var diary in diaries) {
                        final diaryData = diary.data() as Map<String, dynamic>;
                        if (diaryData['subjectId'] == subject.id) {
                          diaryCount++;
                        }
                      }

                      // Calculate progress
                      final progress = subjects.length > 1
                          ? diaryCount / (subjects.length * 2.0)
                          : diaryCount > 0
                          ? 1.0
                          : 0.0;

                      return SubjectStatCard(
                            name: subjectData['name'],
                            color: color,
                            progress: progress.clamp(0.0, 1.0),
                            index: index,
                          )
                          .animate(delay: (100 * index).ms)
                          .scale(curve: Curves.elasticOut);
                    }, childCount: subjects.length),
                  ),
                );
              },
            );
          },
        ),

        // Add some bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}
