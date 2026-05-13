import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/diary_service.dart';
import '../../models/diary_model.dart';
import '../../models/subject_model.dart';
import '../../theme/playful_theme.dart';
import 'create_diary_screen.dart';
import 'manage_diaries_screen.dart';
import 'student_list_screen.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_attendance_analytics.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late DiaryService _diaryService;
  String? _selectedSubjectId;
  String? _selectedClassId;
  String? _selectedSubjectName;
  List<SubjectModel> _subjects = [];

  @override
  void initState() {
    super.initState();
    _diaryService = DiaryService();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final teacherId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .where('teacherId', isEqualTo: teacherId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_person, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Access Restricted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Convert snapshot to SubjectModel list
          _subjects = (snapshot.data?.docs ?? []).map((doc) {
            return SubjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          // Set default selection if available
          if (_selectedSubjectId == null && _subjects.isNotEmpty) {
            _selectedSubjectId = _subjects.first.id;
            _selectedClassId = _subjects.first.classId;
            _selectedSubjectName = _subjects.first.name;
          }

          return Column(
            children: [
              // Header with greeting
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PlayfulTheme.primaryTeal.withOpacity(0.1),
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
                        // App Logo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/logo.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Welcome, Teacher!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ).animate().fadeIn(duration: 400.ms),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your classes and diaries',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
              ),

              // Subject selection
              if (_subjects.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubjectId,
                    decoration: InputDecoration(
                      labelText: 'Select Subject & Class',
                      prefixIcon: const Icon(Icons.book),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject.id,
                        child: Text(
                          '${subject.name} - Class ${subject.classId}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubjectId = value;
                        // Find the class ID and name for this subject
                        final subject = _subjects.firstWhere(
                          (s) => s.id == value,
                        );
                        _selectedClassId = subject.classId;
                        _selectedSubjectName = subject.name;
                      });
                    },
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No subjects assigned to you yet. Contact admin to assign subjects.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Action buttons
              if (_selectedSubjectId != null &&
                  _selectedClassId != null &&
                  _selectedSubjectName != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateDiaryScreen(
                                  className: _selectedClassId!,
                                  subjectName: _selectedSubjectName!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Diary',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlayfulTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentListScreen(
                                  className: _selectedClassId!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.people, color: Colors.white),
                          label: const Text(
                            'Students',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlayfulTheme.accentOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageDiariesScreen(
                            className: _selectedClassId!,
                            subjectName: _selectedSubjectName!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Manage Diaries',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlayfulTheme.accentPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate(delay: 300.ms),
                const SizedBox(height: 16),
                // Attendance buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TeacherAttendanceScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text(
                            'Take Attendance',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TeacherAttendanceAnalytics(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics, color: Colors.white),
                          label: const Text(
                            'Analytics',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 350.ms),
              ],

              const SizedBox(height: 24),

              // Recent diaries header
              if (_selectedSubjectId != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: PlayfulTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Diaries',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms),
                const SizedBox(height: 16),

                // Recent diaries list
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('diaries')
                        .where('subjectId', isEqualTo: _selectedSubjectId)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        // Handle the specific Firebase index error
                        if (snapshot.error.toString().contains(
                              'failed-precondition',
                            ) ||
                            snapshot.error.toString().contains('index')) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 48,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Database Index Required',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'This app needs a database index to work properly. Please ask your administrator to create the required index in Firebase.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => setState(() {}), // Retry
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 48,
                                  color: Colors.red,
                                ),
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
                                  snapshot.error.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => setState(() {}), // Retry
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      // Sort documents by date client-side
                      final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
                        ..sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;

                          try {
                            DateTime aDate, bDate;

                            if (aData['date'] is Timestamp) {
                              aDate = (aData['date'] as Timestamp).toDate();
                            } else {
                              aDate = DateTime.parse(aData['date'].toString());
                            }

                            if (bData['date'] is Timestamp) {
                              bDate = (bData['date'] as Timestamp).toDate();
                            } else {
                              bDate = DateTime.parse(bData['date'].toString());
                            }

                            return bDate.compareTo(aDate); // Descending order
                          } catch (e) {
                            return 0;
                          }
                        });

                      if (sortedDocs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text('No diaries created yet'),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap "Add Diary" to create your first diary entry',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sortedDocs.length,
                        itemBuilder: (context, index) {
                          final doc = sortedDocs[index];
                          final diary = DiaryModel.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          );
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: PlayfulTheme.primaryTeal.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.book,
                                  color: PlayfulTheme.primaryTeal,
                                ),
                              ),
                              title: Text(
                                diary.subjectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diary.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${diary.date.day}/${diary.date.month}/${diary.date.year}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to edit screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateDiaryScreen(
                                      className: diary.classId,
                                      subjectName: diary.subjectName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ).animate(delay: (index * 50).ms);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
