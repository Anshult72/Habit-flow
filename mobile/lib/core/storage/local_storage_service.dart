import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A generic local storage service using Hive to cache JSON data.
/// This allows the app to load instantly from cache while offline.
class LocalStorageService {
  static const String _cacheBoxName = 'app_cache';
  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
  }

  /// Save dynamic data (usually a Map or List) as JSON string
  Future<void> saveData(String key, dynamic data) async {
    final jsonString = jsonEncode(data);
    await _cacheBox.put(key, jsonString);
  }

  /// Read data from cache and decode JSON. Returns null if not found.
  dynamic readData(String key) {
    final jsonString = _cacheBox.get(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Remove data from cache
  Future<void> removeData(String key) async {
    await _cacheBox.delete(key);
  }

  /// Clear entire cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }
}

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider must be overridden in main.dart');
});
