import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class CacheStore {
  CacheStore(this._box, this.prefs);

  final Box<String> _box;
  final SharedPreferences prefs;

  static Future<CacheStore> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(AppConstants.hiveBoxCache);
    final prefs = await SharedPreferences.getInstance();
    return CacheStore(box, prefs);
  }

  Map<String, dynamic>? readJson(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await _box.put(key, jsonEncode(value));
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool get onboardingDone => prefs.getBool(AppConstants.prefsOnboarding) ?? false;

  Future<void> setOnboardingDone() => prefs.setBool(AppConstants.prefsOnboarding, true);

  /// نقش انتخاب‌شده در راه‌اندازی پروفایل (`admin` یا `member`).
  String? get intendedRole => prefs.getString(AppConstants.prefsIntendedRole);

  Future<void> setIntendedRole(String role) =>
      prefs.setString(AppConstants.prefsIntendedRole, role);
}
