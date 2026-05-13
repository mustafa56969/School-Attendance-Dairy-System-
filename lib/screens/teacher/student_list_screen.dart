import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/whatsapp_service.dart';

class StudentListScreen extends StatelessWidget {
  final String className;

  const StudentListScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students - $className')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('classId', isEqualTo: className)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No students found in this class'));
          }

          // Sort by Roll No
          docs.sort((a, b) {
            final rollA = (a.data() as Map<String, dynamic>)['rollNo'] ?? '';
            final rollB = (b.data() as Map<String, dynamic>)['rollNo'] ?? '';
            // Try to sort numerically if possible
            final intA = int.tryParse(rollA) ?? 999999;
            final intB = int.tryParse(rollB) ?? 999999;
            return intA.compareTo(intB);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final fatherName = data['fatherName'] ?? 'Unknown';
              final rollNo = data['rollNo'] ?? '-';
              final phone = data['phone'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(child: Text(rollNo.toString())),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Father: $fatherName'),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.message, color: Colors.green),
                    onPressed: phone.isNotEmpty
                        ? () async {
                            try {
                              await WhatsAppService.launchWhatsApp(phone);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not open WhatsApp: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    tooltip: 'Contact Parent via WhatsApp',
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
