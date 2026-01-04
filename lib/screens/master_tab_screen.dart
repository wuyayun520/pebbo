import 'package:flutter/material.dart';
import '../widgets/common_background.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/like_service.dart';
import '../services/block_service.dart';
import '../widgets/video_post_card.dart';

class MasterTabScreen extends StatefulWidget {
  const MasterTabScreen({super.key});

  @override
  State<MasterTabScreen> createState() => _MasterTabScreenState();
}

class _MasterTabScreenState extends State<MasterTabScreen> {
  List<UserModel> _allUsers = [];
  Set<String> _hiddenPostIds = {};
  Set<String> _likedPostIds = {};
  Map<String, int> _likeCounts = {};
  Set<String> _blockedUserIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await UserService.loadUsers();
    final likedPosts = await LikeService.getLikedPosts();
    final likeCounts = await LikeService.getLikeCounts();
    final blockedUsers = await BlockService.getBlockedUsers();
    
    final Map<String, int> initialLikeCounts = {};
    for (var user in users) {
      initialLikeCounts[user.videoPost.postId] = likeCounts[user.videoPost.postId] ?? user.videoPost.likes;
    }
    
    setState(() {
      _allUsers = users;
      _likedPostIds = likedPosts;
      _likeCounts = initialLikeCounts;
      _blockedUserIds = blockedUsers;
      _isLoading = false;
    });
  }

  void _onNotInterested(String postId) {
    if (!_hiddenPostIds.contains(postId)) {
      setState(() {
        _hiddenPostIds.add(postId);
      });
    }
  }

  Future<void> _onLikeToggled(String postId, int currentLikes) async {
    // 只从持久化存储中读取最新状态，不再次切换
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

  List<UserModel> get _visibleUsers {
    return _allUsers.where((user) => 
      !_hiddenPostIds.contains(user.videoPost.postId) && 
      !_blockedUserIds.contains(user.userId)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final tabBarHeight = 75.0;
    final tabBarBottom = 20.0;
    final tabBarMargin = 20.0;
    final bottomPadding = tabBarBottom + tabBarHeight + tabBarMargin;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CommonBackground(
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: statusBarHeight + 8,
              child: SizedBox(
                width: 262,
                height: 35,
                child: Image.asset(
                  'assets/pebbo_master_community.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: statusBarHeight + 8 + 35 + 20,
              bottom: bottomPadding,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEA8DFF),
                      ),
                    )
                  : ListView.builder(
                      key: ValueKey(_hiddenPostIds.length),
                      padding: EdgeInsets.zero,
                      itemCount: _visibleUsers.length,
                      itemBuilder: (context, index) {
                        final user = _visibleUsers[index];
                        final postId = user.videoPost.postId;
                        final isLiked = _likedPostIds.contains(postId);
                        final likeCount = _likeCounts[postId] ?? user.videoPost.likes;
                        return VideoPostCard(
                          user: user,
                          isLiked: isLiked,
                          likeCount: likeCount,
                          onNotInterested: _onNotInterested,
                          onLikeToggled: () => _onLikeToggled(postId, likeCount),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

