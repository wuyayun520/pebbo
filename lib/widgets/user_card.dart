import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/user_profile_screen.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final String tag;
  final VoidCallback? onUserBlocked;

  const UserCard({
    super.key,
    required this.user,
    required this.tag,
    this.onUserBlocked,
  });

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'trad':
        return const Color(0xFFEA8DFF);
      case 'bw':
        return const Color(0xFFEA8DFF);
      case 'realism':
        return const Color(0xFFEA8DFF);
      case 'geo':
        return const Color(0xFFEA8DFF);
      default:
        return const Color(0xFFEA8DFF);
    }
  }

  String _getUserTag(UserModel user) {
    final tags = user.videoPost.tags;
    if (tags.contains('traditional') || tags.contains('traditionaltattoo')) {
      return 'Trad';
    } else if (tags.contains('blackwork') || tags.contains('blackworktattoo')) {
      return 'BW';
    } else if (tags.contains('realism') || tags.contains('realismtattoo')) {
      return 'Realism';
    } else if (tags.contains('geometric') || tags.contains('geometrictattoo')) {
      return 'Geo';
    }
    return 'Trad';
  }

  @override
  Widget build(BuildContext context) {
    final userTag = _getUserTag(user);
    
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(user: user),
          ),
        );
        // 刷新列表（用户可能取消拉黑了）
        if (onUserBlocked != null) {
          onUserBlocked!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7FD4C1),
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
            Positioned.fill(
              child: Image.asset(
                user.avatar,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTagColor(userTag),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userTag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 50,
              bottom: 12,
              child: Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black,
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF59D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

