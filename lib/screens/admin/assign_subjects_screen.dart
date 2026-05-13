import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignSubjectsScreen extends StatefulWidget {
  const AssignSubjectsScreen({super.key});

  @override
  State<AssignSubjectsScreen> createState() => _AssignSubjectsScreenState();
}

class _AssignSubjectsScreenState extends State<AssignSubjectsScreen> {
  final _subjectNameController = TextEditingController();
  String? _selectedClass;
  String? _selectedTeacher;
  
  final List<String> _classes = [
    'KG', 'Nursery', '1st', '2nd', '3rd', '4th', '5th', 
    '6th', '7th', '8th', '9th', '10th'
  ];

  Future<void> _assignSubject() async {
    if (_subjectNameController.text.isEmpty || _selectedClass == null || _selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('subjects').add({
      'name': _subjectNameController.text.trim(),
      'classId': _selectedClass,
      'teacherId': _selectedTeacher,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _subjectNameController.clear();
    setState(() {
      _selectedClass = null;
      _selectedTeacher = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject assigned!')),
      );
    }
  }

  Future<void> _deleteSubject(String subjectId) async {
    await FirebaseFirestore.instance.collection('subjects').doc(subjectId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Subjects')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                TextField(
                  controller: _subjectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name (e.g. Math, English)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                  ),
                  items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'teacher')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    
                    final teachers = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedTeacher,
                      decoration: const InputDecoration(
                        labelText: 'Assign to Teacher',
                        border: OutlineInputBorder(),
                      ),
                      items: teachers.map((t) {
                        final data = t.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(data['name'] ?? data['email'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedTeacher = v),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _assignSubject,
                  child: const Text('Assign Subject'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                
                final subjects = snapshot.data!.docs;
                if (subjects.isEmpty) {
                  return const Center(child: Text('No subjects assigned yet'));
                }

                return ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final data = subjects[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('${data['name']} - ${data['classId']}'),
                      subtitle: Text('Teacher ID: ${data['teacherId']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubject(subjects[index].id),
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
