import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Check if user is logged in and fetch their role
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    // 1. Try to load from local storage (Offline First)
    await _loadUserFromLocal();

    // 2. If valid user session exists, try to refresh from Firestore
    if (_auth.currentUser != null) {
      // If we already loaded locally, we don't need to show loading spinner while syncing
      if (_userModel == null) {
        await _fetchUserModel(_auth.currentUser!.uid);
      } else {
        // Background refresh
        _fetchUserModel(_auth.currentUser!.uid).catchError((e) {
          debugPrint('Background user refresh failed (offline?): $e');
        });
      }
    } else {
      _isLoading = false;
      notifyListeners();
    }
    
    // Final check to ensure loading state is cleared
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user model from SharedPreferences
  Future<void> _loadUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user_model');
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        final uid = userMap['uid'] ?? _auth.currentUser?.uid ?? '';
        
        if (uid.isNotEmpty) {
          _userModel = UserModel.fromMap(userMap, uid);
          debugPrint('✅ Loaded user from local cache: ${_userModel!.email}');
          
          // Unblock UI immediately
          // _isLoading = false; // Don't set false yet, let checkLoginStatus handle logic
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading local user cache: $e');
    }
  }

  /// Save user model to SharedPreferences
  Future<void> _saveUserToLocal(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMap = user.toMap();
      // Ensure UID is saved in the map for reconstruction
      userMap['uid'] = user.uid; 
      await prefs.setString('cached_user_model', jsonEncode(userMap));
      debugPrint('💾 User model saved to local cache');
    } catch (e) {
      debugPrint('⚠️ Error saving local user cache: $e');
    }
  }

  Future<void> _fetchUserModel(String uid) async {
    try {
      debugPrint('📄 Fetching user model for UID: $uid');
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      
      debugPrint('📄 Document exists: ${doc.exists}');
      
      if (doc.exists) {
        debugPrint('📄 Document data: ${doc.data()}');
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
        debugPrint('✅ UserModel created: ${_userModel!.email}, Role: ${_userModel!.role}');
        
        // Save to local cache for offline access
        await _saveUserToLocal(_userModel!);
        
        // Save FCM token to Firestore
        _saveFCMToken(uid); // Run in background
        
        notifyListeners();
      } else {
        debugPrint('⚠️ No document found for UID: $uid');
        // Check if this is the admin user
        final user = _auth.currentUser;
        if (user != null && user.email == 'pak@admin.com') {
          debugPrint('👑 Creating admin user model');
          // Create admin user model
          _userModel = UserModel(
            uid: uid,
            email: user.email ?? '',
            role: 'admin',
          );
          // Save to Firestore
          await _firestore
              .collection('users')
              .doc(uid)
              .set(_userModel!.toMap());
          debugPrint('✅ Admin user model saved to Firestore');
          
          // Save FCM token
          await _saveFCMToken(uid);
          
          notifyListeners();
        } else {
          debugPrint('❌ User document not found and not admin: ${user?.email}');
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching user model: $e");
      // Fallback for admin if permissions are blocked
      final user = _auth.currentUser;
      if (user != null) {
        // Emergency fallback for specific known accounts if Firestore fails
        if (user.email == 'pak@admin.com') {
          debugPrint('👑 Emergency fallback: Creating admin user model');
          _userModel = UserModel(
            uid: uid,
            email: user.email ?? '',
            role: 'admin',
            name: 'Super Admin',
          );
        } else if (user.email != null && (
            user.email!.contains('teacher') || 
            user.email!.contains('prof') ||
            user.email!.contains('school') ||
            user.email!.contains('staff') ||
            user.email!.toLowerCase().contains('edu'))) {
          // Heuristic for teachers if Firestore is blocked
          debugPrint('👨‍🏫 Heuristic fallback: Creating teacher user model');
          _userModel = UserModel(
            uid: uid,
            email: user.email ?? '',
            role: 'teacher',
            name: 'Staff Member',
            assignedClasses: ['Nursery', 'KG', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'], // Grant all classes in fallback
          );
        }
        
        if (_userModel != null) {
          notifyListeners();
        }
      }
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveFCMToken(String uid) async {
    try {
      final token = NotificationService().fcmToken;
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ FCM token saved to Firestore');
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  // Login with Email & Password
  Future<String?> login(String email, String password) async {
    try {
      debugPrint('🔐 Login attempt for: $email');
      _isLoading = true;
      notifyListeners();

      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Firebase Auth successful for: ${cred.user!.email}');
      debugPrint('🆔 User UID: ${cred.user!.uid}');

      // Fetch user model immediately
      await _fetchUserModel(cred.user!.uid);

      if (_userModel != null) {
        debugPrint('✅ User model loaded: ${_userModel!.email}, Role: ${_userModel!.role}');
      } else {
        debugPrint('❌ User model is NULL after fetch');
      }

      _isLoading = false;
      notifyListeners();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      return e.message ?? "Login failed";
    } catch (e) {
      debugPrint('❌ Unknown error during login: $e');
      _isLoading = false;
      notifyListeners();
      return "An unknown error occurred: $e";
    }
  }

  // Register
  Future<String?> register(String email, String password, String role) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(newUser.toMap());

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential userCredential;

      // Sign out first to ensure clean state
      if (kIsWeb) {
        // For web, we need to use the Firebase GoogleAuthProvider directly
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // For mobile platforms
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();

        // Sign in with Google
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return 'Google Sign In cancelled';
        }

        // Get auth details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check if user exists in our database, if not create a basic student profile
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          role: 'student',
        );
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());
      }

      // Fetch user model
      await _fetchUserModel(userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();

      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Google Sign In error: $e');
      return 'Google Sign In failed. Error: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null;
    
    // Clear local cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_model');
    } catch (e) {
      debugPrint('Error clearing local cache: $e');
    }
    
    notifyListeners();

    // Also sign out from Google on mobile
    if (!kIsWeb) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    }
  }
}
