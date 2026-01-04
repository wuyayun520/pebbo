import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class UserService {
  static Future<List<UserModel>> loadUsers() async {
    try {
      final String response = await rootBundle.loadString('assets/peebotattooart/peebotattooartdata.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> usersJson = data['users'] ?? [];
      
      return usersJson.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  static List<UserModel> getPopularUsers(List<UserModel> users) {
    final sorted = List<UserModel>.from(users);
    sorted.sort((a, b) => b.videoPost.likes.compareTo(a.videoPost.likes));
    return sorted.take(10).toList();
  }

  static List<UserModel> getNewUsers(List<UserModel> users) {
    return users.take(10).toList();
  }
}

