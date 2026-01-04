import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BlockService {
  static const String _blockedUsersKey = 'blocked_users';

  static Future<Set<String>> getBlockedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedUsersJson = prefs.getString(_blockedUsersKey);
      if (blockedUsersJson != null) {
        final List<dynamic> blockedUsers = json.decode(blockedUsersJson);
        return Set<String>.from(blockedUsers);
      }
      return <String>{};
    } catch (e) {
      print('Error loading blocked users: $e');
      return <String>{};
    }
  }

  static Future<void> saveBlockedUsers(Set<String> blockedUsers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedUsersJson = json.encode(blockedUsers.toList());
      await prefs.setString(_blockedUsersKey, blockedUsersJson);
    } catch (e) {
      print('Error saving blocked users: $e');
    }
  }

  static Future<bool> toggleBlockUser(String userId) async {
    try {
      final blockedUsers = await getBlockedUsers();
      bool isBlocked = blockedUsers.contains(userId);
      
      if (isBlocked) {
        blockedUsers.remove(userId);
      } else {
        blockedUsers.add(userId);
      }
      
      await saveBlockedUsers(blockedUsers);
      return !isBlocked;
    } catch (e) {
      print('Error toggling block user: $e');
      return false;
    }
  }

  static Future<bool> isBlocked(String userId) async {
    try {
      final blockedUsers = await getBlockedUsers();
      return blockedUsers.contains(userId);
    } catch (e) {
      return false;
    }
  }
}

