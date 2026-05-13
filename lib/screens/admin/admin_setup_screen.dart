import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-create admin profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createAdminProfile();
    });
  }

  Future<void> _createAdminProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: 'admin',
        name: 'Super Admin',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      // Refresh user model in AuthService
      if (mounted) {
        await Provider.of<AuthService>(context, listen: false).checkLoginStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating admin profile: $e')),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Setting up Admin Account...'),
          ],
        ),
      ),
    );
  }
}
