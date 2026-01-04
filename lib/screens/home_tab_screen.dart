import 'package:flutter/material.dart';
import '../widgets/common_background.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/block_service.dart';
import '../widgets/user_card.dart';

class HomeTabScreen extends StatefulWidget {
  final int typeIndex;

  const HomeTabScreen({
    super.key,
    required this.typeIndex,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  List<UserModel> _allUsers = [];
  Set<String> _blockedUserIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await UserService.loadUsers();
    final blockedUsers = await BlockService.getBlockedUsers();
    setState(() {
      _allUsers = users;
      _blockedUserIds = blockedUsers;
      _isLoading = false;
    });
  }

  List<UserModel> _getDisplayUsers() {
    // 先过滤掉被拉黑的用户
    final filteredUsers = _allUsers.where((user) => !_blockedUserIds.contains(user.userId)).toList();
    
    if (widget.typeIndex == 0) {
      return UserService.getPopularUsers(filteredUsers);
    } else {
      return UserService.getNewUsers(filteredUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CommonBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFEA8DFF),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight + 16 + 146 + 20 + 86,
                  left: 20,
                  right: 20,
                  bottom: 0,
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 115),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _getDisplayUsers().length,
                  itemBuilder: (context, index) {
                    final user = _getDisplayUsers()[index];
                    return UserCard(
                      user: user,
                      tag: '',
                      onUserBlocked: () => _loadUsers(), // 刷新列表
                    );
                  },
                ),
              ),
      ),
    );
  }
}

