import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';
import '../../widgets/vibrant_subject_card.dart';
import '../../widgets/vibrant_subject_chart.dart';

class VibrantStudentSubjects extends StatelessWidget {
  const VibrantStudentSubjects({super.key});

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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
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
                    const SizedBox(width: 16),
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
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error Loading Subjects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'There was an error loading your subjects. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!subjectSnapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final subjects = subjectSnapshot.data!.docs;

            if (subjects.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 24),
                      Text(
                        'No Subjects Found',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You don\'t have any subjects assigned yet. Please contact your teacher.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
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
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.warning, size: 48, color: Colors.orange),
                          SizedBox(height: 16),
                          Text(
                            'Error Loading Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'There was an error loading subject data. Please try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!diarySnapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                final diaries = diarySnapshot.data!.docs;

                // Calculate subject weights based on diary count
                final subjectWeights = <Map<String, dynamic>>[];
                final subjectColors = [
                  PlayfulTheme.primaryTeal,
                  PlayfulTheme.primaryPink,
                  PlayfulTheme.primaryOrange,
                  PlayfulTheme.accentPurple,
                  PlayfulTheme.primaryRed,
                  PlayfulTheme.primaryYellow,
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
                    padding: const EdgeInsets.all(24),
                    child: VibrantSubjectChart(subjectData: subjectWeights),
                  ),
                );
              },
            );
          },
        ),

        // Subject List Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(
              'All Subjects',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error Loading Subjects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'There was an error loading your subjects. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final subjects = snapshot.data!.docs;

            if (subjects.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 24),
                      Text(
                        'No Subjects Found',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You don\'t have any subjects assigned yet. Please contact your teacher.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
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
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.warning, size: 48, color: Colors.orange),
                          SizedBox(height: 16),
                          Text(
                            'Error Loading Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'There was an error loading subject data. Please try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!diarySnapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                final diaries = diarySnapshot.data!.docs;
                final subjectColors = [
                  PlayfulTheme.primaryTeal,
                  PlayfulTheme.primaryPink,
                  PlayfulTheme.primaryOrange,
                  PlayfulTheme.accentPurple,
                  PlayfulTheme.primaryRed,
                  PlayfulTheme.primaryYellow,
                ];

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.95,
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

                      return VibrantSubjectCard(
                            name: subjectData['name'],
                            color: color,
                            progress: progress.clamp(0.0, 1.0),
                            diaryCount: diaryCount,
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
