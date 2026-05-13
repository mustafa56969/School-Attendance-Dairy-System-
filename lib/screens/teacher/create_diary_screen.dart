import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateDiaryScreen extends StatefulWidget {
  final String className;
  final String subjectName;

  const CreateDiaryScreen({
    super.key,
    required this.className,
    required this.subjectName,
  });

  @override
  State<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends State<CreateDiaryScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveDiary() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      await FirebaseFirestore.instance.collection('diaries').add({
        'classId': widget.className,
        'subject': widget.subjectName,
        'content': _contentController.text.trim(),
        'date': FieldValue.serverTimestamp(),
        'teacherId': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary sent successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - ${widget.subjectName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Today\'s Diary',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold).copyWith(inherit: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Enter homework details...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveDiary,
              icon: const Icon(Icons.send),
              label: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Send Diary'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
