import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'timestamp_';
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  // Cache data with optional expiration
  static Future<void> cacheData(
    String key,
    dynamic data, {
    Duration? cacheDuration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '${_timestampPrefix}$key';

      // Serialize data based on type
      String serializedData;
      if (data is String) {
        serializedData = data;
      } else if (data is Map || data is List) {
        serializedData = jsonEncode(data);
      } else {
        serializedData = data.toString();
      }

      // Save data and timestamp
      await prefs.setString(cacheKey, serializedData);
      await prefs.setInt(
        timestampKey,
        DateTime.now()
            .add(cacheDuration ?? _defaultCacheDuration)
            .millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silently fail to not break the app
      print('CacheService: Error caching data for key $key: $e');
    }
  }

  // Retrieve cached data if still valid
  static Future<dynamic> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '${_timestampPrefix}$key';

      // Check if data exists
      if (!prefs.containsKey(cacheKey) || !prefs.containsKey(timestampKey)) {
        return null;
      }

      // Check if data is still valid
      final expirationTime = prefs.getInt(timestampKey);
      if (expirationTime == null ||
          DateTime.now().millisecondsSinceEpoch > expirationTime) {
        // Data expired, remove it
        await prefs.remove(cacheKey);
        await prefs.remove(timestampKey);
        return null;
      }

      // Return cached data
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;

      // Try to parse as JSON, if it fails return as string
      try {
        return jsonDecode(cachedData);
      } catch (e) {
        return cachedData;
      }
    } catch (e) {
      // Silently fail to not break the app
      print('CacheService: Error retrieving cached data for key $key: $e');
      return null;
    }
  }

  // Clear specific cache entry
  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '${_timestampPrefix}$key';

      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
    } catch (e) {
      // Silently fail to not break the app
      print('CacheService: Error clearing cache for key $key: $e');
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // Remove all cache entries
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silently fail to not break the app
      print('CacheService: Error clearing all cache: $e');
    }
  }

  // Check if data is cached and valid
  static Future<bool> isCached(String key) async {
    try {
      final cachedData = await getCachedData(key);
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }

  // Cache Firestore snapshot data
  static Future<void> cacheFirestoreSnapshot(
    String key,
    QuerySnapshot snapshot,
  ) async {
    try {
      final List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        final docData = doc.data() as Map<String, dynamic>;
        docData['id'] = doc.id; 
        
        // Convert Timestamps to ISO strings for JSON encoding
        docData.forEach((key, value) {
          if (value is Timestamp) {
            docData[key] = value.toDate().toIso8601String();
          }
        });
        
        return docData;
      }).toList();

      await cacheData(key, data);
    } catch (e) {
      print('CacheService: Error caching Firestore snapshot for key $key: $e');
    }
  }

  // Get cached Firestore data
  static Future<List<Map<String, dynamic>>?> getCachedFirestoreData(
    String key,
  ) async {
    try {
      final cachedData = await getCachedData(key);
      if (cachedData is List) {
        return cachedData.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print(
        'CacheService: Error retrieving cached Firestore data for key $key: $e',
      );
      return null;
    }
  }
}
