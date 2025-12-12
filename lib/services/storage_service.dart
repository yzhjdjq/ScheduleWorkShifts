import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class StorageService {
  static late final SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool containsKey(String key) => _prefs.containsKey(key);

  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  static Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  static Future<bool> setObject<T>(String key, T object) {
    try {
      final jsonString = jsonEncode(object);
      return _prefs.setString(key, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error when serializing an object: $e');
      }
      return Future.value(false);
    }
  }

  static bool? getBool(String key) => _prefs.getBool(key);
  static String? getString(String key) => _prefs.getString(key);
  static int? getInt(String key) => _prefs.getInt(key);
  static T? getObject<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) {
    try {
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final decodedJson = jsonDecode(jsonString);

      if (fromJson != null && decodedJson is Map<String, dynamic>) {
        return fromJson(decodedJson);
      }

      return decodedJson as T?;
    } catch (e) {
      if (kDebugMode) {
        print('Error when deserializing an object: $e');
      }
      return null;
    }
  }

  static List<T>? getObjectList<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) {
    try {
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final decodedJson = jsonDecode(jsonString);

      if (decodedJson is! List) {
        return null;
      }

      if (fromJson != null) {
        return decodedJson.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      }

      if (decodedJson.every((item) => item is T)) {
        return decodedJson.cast<T>().toList();
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error when deserializing a list: $e');
      }
      return null;
    }
  }

  static Future<bool> remove(String key) => _prefs.remove(key);
}
