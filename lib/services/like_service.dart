import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LikeService {
  static const String _likedPostsKey = 'liked_posts';
  static const String _likeCountsKey = 'like_counts';

  static Future<Set<String>> getLikedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedPostsJson = prefs.getString(_likedPostsKey);
      if (likedPostsJson != null) {
        final List<dynamic> likedPosts = json.decode(likedPostsJson);
        return Set<String>.from(likedPosts);
      }
      return <String>{};
    } catch (e) {
      print('Error loading liked posts: $e');
      return <String>{};
    }
  }

  static Future<void> saveLikedPosts(Set<String> likedPosts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedPostsJson = json.encode(likedPosts.toList());
      await prefs.setString(_likedPostsKey, likedPostsJson);
    } catch (e) {
      print('Error saving liked posts: $e');
    }
  }

  static Future<Map<String, int>> getLikeCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likeCountsJson = prefs.getString(_likeCountsKey);
      if (likeCountsJson != null) {
        final Map<String, dynamic> decoded = json.decode(likeCountsJson);
        return decoded.map((key, value) => MapEntry(key, value as int));
      }
      return <String, int>{};
    } catch (e) {
      print('Error loading like counts: $e');
      return <String, int>{};
    }
  }

  static Future<void> saveLikeCounts(Map<String, int> likeCounts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likeCountsJson = json.encode(likeCounts);
      await prefs.setString(_likeCountsKey, likeCountsJson);
    } catch (e) {
      print('Error saving like counts: $e');
    }
  }

  static Future<bool> toggleLike(String postId, int currentLikes) async {
    try {
      final likedPosts = await getLikedPosts();
      final likeCounts = await getLikeCounts();
      
      bool isLiked = likedPosts.contains(postId);
      int currentCount = likeCounts[postId] ?? currentLikes;
      int newLikeCount;
      
      if (isLiked) {
        likedPosts.remove(postId);
        newLikeCount = currentCount > 0 ? currentCount - 1 : 0;
      } else {
        likedPosts.add(postId);
        newLikeCount = currentCount + 1;
      }
      
      likeCounts[postId] = newLikeCount;
      
      await saveLikedPosts(likedPosts);
      await saveLikeCounts(likeCounts);
      
      return !isLiked;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  static Future<int> getLikeCount(String postId, int defaultLikes) async {
    try {
      final likeCounts = await getLikeCounts();
      return likeCounts[postId] ?? defaultLikes;
    } catch (e) {
      return defaultLikes;
    }
  }

  static Future<bool> isLiked(String postId) async {
    try {
      final likedPosts = await getLikedPosts();
      return likedPosts.contains(postId);
    } catch (e) {
      return false;
    }
  }
}

