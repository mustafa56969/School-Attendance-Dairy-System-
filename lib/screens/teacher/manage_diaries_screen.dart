import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import 'edit_diary_screen.dart';

class ManageDiariesScreen extends StatelessWidget {
  final String className;
  final String subjectName;

  const ManageDiariesScreen({
    super.key,
    required this.className,
    required this.subjectName,
  });

  Future<void> _deleteDiary(BuildContext context, String diaryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary'),
        content: const Text('Are you sure you want to delete this diary entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('diaries').doc(diaryId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: Text('$className - $subjectName Diaries'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditDiaryScreen(
                className: className,
                subjectName: subjectName,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('diaries')
            .where('classId', isEqualTo: className)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter by subject AND teacherId in memory to avoid composite index
          final allDocs = snapshot.data?.docs ?? [];
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['subject'] == subjectName && data['teacherId'] == user.uid;
          }).toList();
          
          // Sort by date descending in memory
          filteredDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = (aData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bDate = (bData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            return bDate.compareTo(aDate); // Descending order
          });
          
          final docs = filteredDocs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No diaries yet'),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first diary entry',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data['content'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditDiaryScreen(
                                className: className,
                                subjectName: subjectName,
                                diaryId: docs[index].id,
                                existingContent: data['content'] ?? '',
                                existingDate: date,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () => _deleteDiary(context, docs[index].id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
