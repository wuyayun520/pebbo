import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/like_service.dart';
import '../services/block_service.dart';
import '../widgets/common_background.dart';
import '../widgets/video_post_card.dart';
import 'pebbo_chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<UserModel> _userPosts = [];
  Set<String> _likedPostIds = {};
  Map<String, int> _likeCounts = {};
  bool _isLoading = true;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    final isBlocked = await BlockService.isBlocked(widget.user.userId);
    setState(() {
      _isBlocked = isBlocked;
    });
  }

  Future<void> _loadUserPosts() async {
    // 获取所有用户，然后筛选出当前用户的视频
    final allUsers = await UserService.loadUsers();
    final userPosts = allUsers.where((u) => u.userId == widget.user.userId).toList();
    
    // 如果没有找到多个视频，至少显示当前用户的视频
    if (userPosts.isEmpty) {
      userPosts.add(widget.user);
    }
    
    final likedPosts = await LikeService.getLikedPosts();
    final likeCounts = await LikeService.getLikeCounts();
    
    final Map<String, int> initialLikeCounts = {};
    for (var post in userPosts) {
      initialLikeCounts[post.videoPost.postId] = likeCounts[post.videoPost.postId] ?? post.videoPost.likes;
    }
    
    setState(() {
      _userPosts = userPosts;
      _likedPostIds = likedPosts;
      _likeCounts = initialLikeCounts;
      _isLoading = false;
    });
  }

  Future<void> _onLikeToggled(String postId, int currentLikes) async {
    final isLiked = await LikeService.isLiked(postId);
    final newLikeCount = await LikeService.getLikeCount(postId, currentLikes);
    
    setState(() {
      if (isLiked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }
      _likeCounts[postId] = newLikeCount;
    });
  }

  void _onNotInterested(String postId) {
    // 可以在这里实现隐藏功能
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _isBlocked ? Icons.person_add : Icons.block,
                  color: Colors.white,
                ),
                title: Text(
                  _isBlocked ? 'Unblock User' : 'Block User',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleBlockUser();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.report,
                  color: Colors.white,
                ),
                title: const Text(
                  'Report User',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBlockUser() async {
    final newBlockStatus = await BlockService.toggleBlockUser(widget.user.userId);
    setState(() {
      _isBlocked = newBlockStatus;
    });

    if (newBlockStatus) {
      // Blocked successfully, show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User blocked'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Unblocked successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User unblocked'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Report User',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to report this user? We will review your report.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted, thank you for your feedback'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Confirm Report',
                style: TextStyle(color: Color(0xFFEA8DFF)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 返回按钮和更多按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/pebbo_all_back.webp',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _showMoreMenu,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 用户信息卡片
              if (!_isBlocked) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    child: ClipRRect(
                      
                      child: Stack(
                        children: [
                          // 背景图片
                          Positioned.fill(
                            child: Image.asset(
                              'assets/pebbo_me_people.webp',
                              fit: BoxFit.fill,
                            ),
                          ),
                          // 内容
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 头像
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          widget.user.avatar,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // 用户信息
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                widget.user.displayName,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          if (widget.user.bio.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              widget.user.bio,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          if (widget.user.location.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.black87,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  widget.user.location,
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // 聊天按钮
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => PebboChatScreen(
                                              userId: widget.user.userId,
                                              userName: widget.user.displayName,
                                              userAvatar: widget.user.avatar,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/pebbo_me_chat.webp',
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Post 标题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Post',
                        style: TextStyle(
                          color: const Color(0xFFEA8DFF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 视频列表
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEA8DFF),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _userPosts.length,
                          itemBuilder: (context, index) {
                            final post = _userPosts[index];
                            final postId = post.videoPost.postId;
                            final isLiked = _likedPostIds.contains(postId);
                            final likeCount = _likeCounts[postId] ?? post.videoPost.likes;
                            
                            return VideoPostCard(
                              user: post,
                              isLiked: isLiked,
                              likeCount: likeCount,
                              onNotInterested: _onNotInterested,
                              onLikeToggled: () => _onLikeToggled(postId, likeCount),
                            );
                          },
                        ),
                ),
              ] else ...[
                // 用户被拉黑时显示提示信息
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.block,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This user has been blocked',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You can unblock them from the menu',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

