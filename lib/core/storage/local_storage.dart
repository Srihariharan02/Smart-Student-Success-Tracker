import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyToken = 's3t_access_token';
  static const String _keyUser = 's3t_user_profile';
  static const String _keyTheme = 's3t_theme_mode';
  static const String _keyApiBase = 'ssst_api_base_url';
  static const String _keyRemember = 'ssst_remember_me';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> saveToken(String token) async {
    await init();
    return _prefs!.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static Future<bool> clearToken() async {
    await init();
    return _prefs!.remove(_keyToken);
  }

  static Future<bool> saveUser(Map<String, dynamic> userMap) async {
    await init();
    return _prefs!.setString(_keyUser, jsonEncode(userMap));
  }

  static Map<String, dynamic>? getUser() {
    final str = _prefs?.getString(_keyUser);
    if (str == null || str.isEmpty) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> clearUser() async {
    await init();
    return _prefs!.remove(_keyUser);
  }

  static Future<bool> saveThemeMode(String mode) async {
    await init();
    return _prefs!.setString(_keyTheme, mode);
  }

  static String getThemeMode() {
    return _prefs?.getString(_keyTheme) ?? 'system';
  }

  static Future<bool> saveApiBaseUrl(String url) async {
    await init();
    return _prefs!.setString(_keyApiBase, url);
  }

  static String? getApiBaseUrl() {
    return _prefs?.getString(_keyApiBase);
  }

  static Future<bool> saveRememberMe(bool value) async {
    await init();
    return _prefs!.setBool(_keyRemember, value);
  }

  static bool getRememberMe() {
    return _prefs?.getBool(_keyRemember) ?? true;
  }

  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}
