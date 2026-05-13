import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_model.dart';
import '../models/subject_model.dart';
import 'cache_service.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get diaries for a specific class and date with caching
  Stream<List<DiaryModel>> getDiariesForClass(String classId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final cacheKey =
        'diaries_${classId}_${date.toIso8601String().split('T')[0]}';

    // Return stream that combines cached data with real-time updates
    return _firestore
        .collection('diaries')
        .where('classId', isEqualTo: classId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .asyncMap((snapshot) async {
          // Cache the data for offline use
          await CacheService.cacheFirestoreSnapshot(cacheKey, snapshot);
          final diaries = snapshot.docs
              .map(
                (doc) => DiaryModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
          
          // Sort client-side to avoid index requirement
          diaries.sort((a, b) => a.subjectName.compareTo(b.subjectName));
          return diaries;
        });
  }

  // Get cached diaries for offline use
  Future<List<DiaryModel>> getCachedDiariesForClass(
    String classId,
    DateTime date,
  ) async {
    final cacheKey =
        'diaries_${classId}_${date.toIso8601String().split('T')[0]}';
    final cachedData = await CacheService.getCachedFirestoreData(cacheKey);

    if (cachedData != null) {
      return cachedData.map((data) {
        final id = data['id'] as String;
        data.remove('id'); // Remove id from data as it's used separately
        return DiaryModel.fromMap(data, id);
      }).toList();
    }

    return [];
  }

  // Create a new diary entry
  Future<void> createDiary(DiaryModel diary) async {
    await _firestore.collection('diaries').doc(diary.id).set(diary.toMap());
    // Clear relevant caches
    await _clearDateCache(diary.classId, diary.date);
  }

  // Update an existing diary entry
  Future<void> updateDiary(DiaryModel diary) async {
    await _firestore.collection('diaries').doc(diary.id).update(diary.toMap());
    // Clear relevant caches
    await _clearDateCache(diary.classId, diary.date);
  }

  // Delete a diary entry
  Future<void> deleteDiary(
    String diaryId,
    String classId,
    DateTime date,
  ) async {
    await _firestore.collection('diaries').doc(diaryId).delete();
    // Clear relevant caches
    await _clearDateCache(classId, date);
  }

  // Helper to clear date-specific cache
  Future<void> _clearDateCache(String classId, DateTime date) async {
    final cacheKey =
        'diaries_${classId}_${date.toIso8601String().split('T')[0]}';
    await CacheService.clearCache(cacheKey);
  }

  // Get all subjects for a class with caching
  Stream<List<SubjectModel>> getSubjectsForClass(String classId) {
    final cacheKey = 'subjects_$classId';

    return _firestore
        .collection('subjects')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .asyncMap((snapshot) async {
          // Cache the data for offline use
          await CacheService.cacheFirestoreSnapshot(cacheKey, snapshot);
          return snapshot.docs
              .map(
                (doc) => SubjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  // Get cached subjects for offline use
  Future<List<SubjectModel>> getCachedSubjectsForClass(String classId) async {
    final cacheKey = 'subjects_$classId';
    final cachedData = await CacheService.getCachedFirestoreData(cacheKey);

    if (cachedData != null) {
      return cachedData.map((data) {
        final id = data['id'] as String;
        data.remove('id');
        return SubjectModel.fromMap(data, id);
      }).toList();
    }

    return [];
  }

  // Get students in a class with caching
  Stream<List<Map<String, dynamic>>> getStudentsInClass(String classId) {
    final cacheKey = 'students_$classId';

    return _firestore
        .collection('users')
        .where('classId', isEqualTo: classId)
        .where('role', isEqualTo: 'student')
        .snapshots()
        .asyncMap((snapshot) async {
          // Cache the data for offline use
          final List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
            final docData = doc.data();
            docData['id'] = doc.id;
            return docData;
          }).toList();

          // Sort client-side to avoid index requirement
          data.sort((a, b) => (a['rollNo'] ?? '').toString().compareTo((b['rollNo'] ?? '').toString()));

          await CacheService.cacheData(cacheKey, data);
          return data;
        });
  }

  // Get cached students for offline use
  Future<List<Map<String, dynamic>>> getCachedStudentsInClass(
    String classId,
  ) async {
    final cacheKey = 'students_$classId';
    final cachedData = await CacheService.getCachedData(cacheKey);

    if (cachedData is List) {
      return cachedData.cast<Map<String, dynamic>>();
    }

    return [];
  }

  // Get all diaries for a subject with caching
  Stream<List<DiaryModel>> getDiariesForSubject(String subjectId) {
    final cacheKey = 'diaries_subject_$subjectId';

    return _firestore
        .collection('diaries')
        .where('subjectId', isEqualTo: subjectId)
        .snapshots()
        .asyncMap((snapshot) async {
          // Cache the data for offline use
          await CacheService.cacheFirestoreSnapshot(cacheKey, snapshot);
          final diaries = snapshot.docs
              .map(
                (doc) => DiaryModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          // Sort client-side (descending date)
          diaries.sort((a, b) => b.date.compareTo(a.date));
          return diaries;
        });
  }

  // Get cached diaries for subject for offline use
  Future<List<DiaryModel>> getCachedDiariesForSubject(String subjectId) async {
    final cacheKey = 'diaries_subject_$subjectId';
    final cachedData = await CacheService.getCachedFirestoreData(cacheKey);

    if (cachedData != null) {
      return cachedData.map((data) {
        final id = data['id'] as String;
        data.remove('id');
        return DiaryModel.fromMap(data, id);
      }).toList();
    }

    return [];
  }

  // Get all classes with caching
  Future<List<String>> getAllClasses() async {
    final cacheKey = 'all_classes';

    // Try to get from cache first
    final cachedClasses = await CacheService.getCachedData(cacheKey);
    if (cachedClasses is List) {
      return cachedClasses.cast<String>();
    }

    // Fetch from Firestore if not cached
    final snapshot = await _firestore.collection('subjects').get();
    final classes = <String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('classId')) {
        classes.add(data['classId']);
      }
    }

    // Sort classes in a logical order
    final sortedClasses = classes.toList();
    sortedClasses.sort((a, b) {
      // Handle special cases like KG, Nursery
      if (a == 'KG') return -1;
      if (b == 'KG') return 1;
      if (a == 'Nursery') return -1;
      if (b == 'Nursery') return 1;

      // Handle numeric classes
      final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), ''));
      final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), ''));

      if (numA != null && numB != null) {
        return numA.compareTo(numB);
      }

      return a.compareTo(b);
    });

    // Cache the result
    await CacheService.cacheData(cacheKey, sortedClasses);

    return sortedClasses;
  }
}
