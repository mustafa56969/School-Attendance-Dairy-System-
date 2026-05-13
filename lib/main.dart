import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/app_status_service.dart';
import 'services/attendance_analytics_service.dart';
import 'widgets/service_lock_overlay.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_profile_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/vibrant_student_dashboard.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/vibrant_admin_dashboard.dart';
import 'screens/admin/admin_setup_screen.dart';
import 'theme/playful_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    
    // Enable offline persistence explicitly
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    firebaseInitialized = true;

    // Initialize notification service
    await NotificationService().initialize();
  } catch (e) {
    print('Firebase initialization failed: $e');
    firebaseInitialized = false;
  }

  runApp(SchoolDiaryApp(firebaseEnabled: firebaseInitialized));
}

class SchoolDiaryApp extends StatelessWidget {
  final bool firebaseEnabled;

  const SchoolDiaryApp({super.key, required this.firebaseEnabled});

  @override
  Widget build(BuildContext context) {
    // ALWAYS show the app with login screen, even if Firebase fails
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AppStatusService()),
        ChangeNotifierProvider(create: (_) => AttendanceAnalyticsService()),
      ],
      child: Consumer2<ThemeService, AuthService>(
        builder: (context, themeService, authService, child) {
          // Only allow dark mode for students
          final bool isStudent = authService.userModel?.role == 'student';
          final ThemeMode effectiveThemeMode = isStudent ? themeService.themeMode : ThemeMode.light;

          return MaterialApp(
            title: 'Pak Turk School Diary',
            theme: PlayfulTheme.theme,
            darkTheme: PlayfulTheme.darkTheme,
            themeMode: effectiveThemeMode,
            home: firebaseEnabled ? const AuthWrapper() : const LoginScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return ServiceLockOverlay(child: child ?? const SizedBox());
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    // Check login status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Request notification permissions when app starts
        await _requestNotificationPermission();

        Provider.of<AuthService>(context, listen: false).checkLoginStatus();
      } catch (e) {
        print('Auth service error: $e');
      }
    });

    // Monitor connectivity
    _monitorConnectivity();
  }

  /// Request notification permission with popup dialog
  Future<void> _requestNotificationPermission() async {
    try {
      // Use the improved notification service method
      await NotificationService().requestPermissionWithPopup(context);
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  void _monitorConnectivity() {
    try {
      Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) {
        if (mounted) {
          setState(() {
            _isOnline = !results.contains(ConnectivityResult.none);
          });
        }
      });
    } catch (e) {
      print('Connectivity monitoring error: $e');
      // Assume online if connectivity check fails
      _isOnline = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Handle connection errors - show login screen instead of error
        if (authSnapshot.hasError) {
          return const LoginScreen();
        }

        // Handle auth state changes
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // Not logged in - show login screen
        if (authSnapshot.data == null) {
          return const LoginScreen();
        }

        // Logged in - check user model
        return Consumer<AuthService>(
          builder: (context, authService, _) {
            // Logged in - check user model
            if (authService.userModel != null) {
              final role = authService.userModel!.role;
              if (role == 'teacher' || role == 'admin') {
                // Trigger attendance sync in background for staff
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<AttendanceAnalyticsService>(context, listen: false)
                      .checkAndSyncOnLogin(
                        authService.userModel!.uid,
                        classId: authService.userModel!.classId,
                      );
                });
              }
            }

            // Loading state - only show loading if actively fetching
            if (authService.isLoading) {
              return _buildLoadingScreen();
            }

            // Check if it's admin without profile
            final email = authService.currentUser?.email ?? '';
            if (email == 'pak@admin.com' &&
                authService.userModel?.role != 'admin') {
              return const AdminSetupScreen();
            }

            // Check if user without profile (student)
            if (authService.userModel == null) {
              final isGoogleAuth = authService.currentUser?.providerData.any(
                    (info) => info.providerId == 'google.com',
                  ) ??
                  false;

              if (isGoogleAuth) {
                // For Google authenticated users, redirect to profile screen
                return const StudentProfileScreen();
              } else {
                // Email/password user without profile - error
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Account Not Found',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your account exists but has no profile. Please contact admin.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => authService.logout(),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }

            // Route based on role
            if (authService.userModel == null) {
              return _buildLoadingScreen();
            }
            
            Widget dashboard;
            final userRole = authService.userModel!.role;
            
            // Initialize broadcast notification listener for this user
            NotificationService().listenToBroadcastNotifications(userRole);
            
            switch (userRole) {
              case 'student':
                // Check if student profile is complete
                if (authService.userModel!.name == null ||
                    authService.userModel!.classId == null) {
                  dashboard = const StudentProfileScreen();
                } else {
                  dashboard = const VibrantStudentDashboard();
                }
                break;
              case 'teacher':
                dashboard = const TeacherDashboard();
                break;
              case 'admin':
                dashboard = const VibrantAdminDashboard();
                break;
              default:
                return const LoginScreen();
            }

            // Wrap dashboard with connectivity indicator if offline
            if (!_isOnline) {
              dashboard = Stack(
                children: [
                  dashboard,
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.orange.withOpacity(0.9),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Working offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return dashboard;
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using the app logo instead of Lottie animation
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.asset('assets/logo.webp', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Diary'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/logo.webp',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school,
                        size: 60,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App Title
              const Text(
                'School Diary App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Status Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                    SizedBox(height: 12),
                    Text(
                      'Offline Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Firebase connection unavailable.\nPlease check your internet connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry Connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
