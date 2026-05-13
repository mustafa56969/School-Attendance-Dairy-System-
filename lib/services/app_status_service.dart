import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppStatusService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAppActive = true;
  String? _lockMessage;
  bool _isLoading = true;

  bool get isAppActive => _isAppActive;
  String? get lockMessage => _lockMessage;
  bool get isLoading => _isLoading;

  AppStatusService() {
    _initListener();
  }

  void _initListener() {
    // We listen to a specific document in Firestore that you can control from the Firebase Console
    // Collection: app_config, Document: status
    _firestore.collection('app_config').doc('status').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        _isAppActive = data['isActive'] ?? true;
        _lockMessage = data['message'];
        _isLoading = false;
        notifyListeners();
      } else {
        // If the document doesn't exist, we assume the app is active
        _isAppActive = true;
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint('Error listening to app status: $error');
      // On error, we default to active to not break the app for users
      _isAppActive = true;
      _isLoading = false;
      notifyListeners();
    });
  }
}
