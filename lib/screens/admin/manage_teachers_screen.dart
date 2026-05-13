import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createTeacher() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      debugPrint('👨‍🏫 Creating teacher account: $email');

      // Use Firebase Auth REST API to create user without signing out current admin
      final response = await http.post(
        Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBhLMZlal-mgLaknqMcvjP9DgKlRdT7Zic',
        ),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': false,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📡 Firebase Auth API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final teacherId = data['localId'];

        debugPrint('✅ Teacher created in Firebase Auth, UID: $teacherId');

        // Create Firestore profile
        await FirebaseFirestore.instance.collection('users').doc(teacherId).set({
          'uid': teacherId,
          'email': email,
          'name': name,
          'role': 'teacher',
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Teacher profile saved to Firestore');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Teacher account created!\nEmail: $email\nPassword: $password'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
          _emailController.clear();
          _passwordController.clear();
          _nameController.clear();
        }
      } else {
        final error = json.decode(response.body);
        final errorMessage = error['error']['message'] ?? 'Failed to create account';
        debugPrint('❌ Firebase Auth API error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Error creating teacher: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
      appBar: AppBar(title: const Text('Manage Teachers')),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Add New Teacher'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Teacher Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTeacher,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Teacher Account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'teacher')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No teachers yet'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Text(data['email'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Delete from Firestore (Note: Can't delete from Firebase Auth via client)
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(docs[index].id)
                              .delete();
                        },
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
