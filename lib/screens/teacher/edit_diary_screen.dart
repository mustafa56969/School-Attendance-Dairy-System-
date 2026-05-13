import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditDiaryScreen extends StatefulWidget {
  final String className;
  final String subjectName;
  final String? diaryId;
  final String? existingContent;
  final DateTime? existingDate;

  const EditDiaryScreen({
    super.key,
    required this.className,
    required this.subjectName,
    this.diaryId,
    this.existingContent,
    this.existingDate,
  });

  @override
  State<EditDiaryScreen> createState() => _EditDiaryScreenState();
}

class _EditDiaryScreenState extends State<EditDiaryScreen> {
  late TextEditingController _contentController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.existingContent ?? '');
    _selectedDate = widget.existingDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter homework content')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final diaryData = {
        'classId': widget.className,
        'subject': widget.subjectName,
        'content': _contentController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
        'teacherId': user?.uid,
        if (widget.diaryId == null) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.diaryId != null) {
        // Update existing
        await FirebaseFirestore.instance
            .collection('diaries')
            .doc(widget.diaryId)
            .update(diaryData);
      } else {
        // Create new
        await FirebaseFirestore.instance.collection('diaries').add(diaryData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary saved successfully!')),
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
        title: Text(widget.diaryId != null ? 'Edit Diary' : 'Create Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.className} - ${widget.subjectName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Enter homework details...',
                border: OutlineInputBorder(),
                labelText: 'Homework Content',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDiary,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.diaryId != null ? 'Update Diary' : 'Create Diary'),
            ),
          ],
        ),
      ),
    );
  }
}
