import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _userKey = 'yall_user';
  static const String _tokenKey = 'yall_token';
  static const String _phoneNumberKey = 'yall_phone_number';
  static const String _videosKey = 'yall_videos';
  static const String _userVideosKey = 'yall_user_videos';

  late SharedPreferences _prefs;

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User session management
  Future<bool> saveUserSession(User user, String token) async {
    try {
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      await _prefs.setString(_tokenKey, token);
      await _prefs.setString(_phoneNumberKey, user.phoneNumber);
      return true;
    } catch (e) {
      print('Error saving user session: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final userJson = _prefs.getString(_userKey);
      final token = _prefs.getString(_tokenKey);

      if (userJson != null && token != null) {
        final user = User.fromJson(jsonDecode(userJson));
        return {
          'user': user,
          'token': token,
        };
      }
      return null;
    } catch (e) {
      print('Error retrieving user session: $e');
      return null;
    }
  }

  Future<bool> clearUserSession() async {
    try {
      await _prefs.remove(_userKey);
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_phoneNumberKey);
      return true;
    } catch (e) {
      print('Error clearing user session: $e');
      return false;
    }
  }

  // Video storage management
  Future<bool> saveVideos(List<Map<String, dynamic>> videos) async {
    try {
      await _prefs.setString(_videosKey, jsonEncode(videos));
      return true;
    } catch (e) {
      print('Error saving videos: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getVideos() async {
    try {
      final videosJson = _prefs.getString(_videosKey);
      if (videosJson != null) {
        final videos = List<Map<String, dynamic>>.from(
          jsonDecode(videosJson) as List,
        );
        return videos;
      }
      return [];
    } catch (e) {
      print('Error retrieving videos: $e');
      return [];
    }
  }

  // User's uploaded videos
  Future<bool> addUserVideo(Map<String, dynamic> video) async {
    try {
      final userVideos = await getUserVideos();
      userVideos.add(video);
      await _prefs.setString(_userVideosKey, jsonEncode(userVideos));
      return true;
    } catch (e) {
      print('Error adding user video: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserVideos() async {
    try {
      final videosJson = _prefs.getString(_userVideosKey);
      if (videosJson != null) {
        final videos = List<Map<String, dynamic>>.from(
          jsonDecode(videosJson) as List,
        );
        return videos;
      }
      return [];
    } catch (e) {
      print('Error retrieving user videos: $e');
      return [];
    }
  }

  Future<bool> clearAllData() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }
}
