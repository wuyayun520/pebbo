import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_background.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_us_screen.dart';

class MeTabScreen extends StatefulWidget {
  const MeTabScreen({super.key});

  @override
  State<MeTabScreen> createState() => _MeTabScreenState();
}

class _MeTabScreenState extends State<MeTabScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _avatarFileName;
  String _displayName = '';
  String _moodStatus = 'Happy';
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  final List<String> _moodOptions = [
    'Happy',
    'Excited',
    'Calm',
    'Creative',
    'Inspired',
    'Focused',
    'Relaxed',
    'Energetic',
  ];

  static const String _avatarFileNameKey = 'me_avatar_file_name';
  static const String _displayNameKey = 'me_display_name';
  static const String _moodStatusKey = 'me_mood_status';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<String> _getAvatarDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${dir.path}/pebbo_avatars');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    return avatarDir.path;
  }

  Future<String?> _getAvatarPath() async {
    if (_avatarFileName == null || _avatarFileName!.isEmpty) {
      return null;
    }
    final avatarDir = await _getAvatarDirectory();
    final file = File('$avatarDir/$_avatarFileName');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<void> _loadUserData() async {
    // Load from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    _avatarFileName = prefs.getString(_avatarFileNameKey);
    _displayName = prefs.getString(_displayNameKey) ?? '';
    _moodStatus = prefs.getString(_moodStatusKey) ?? 'Happy';

    // Load default user data if no saved data
    if (_displayName.isEmpty) {
      final users = await UserService.loadUsers();
      if (users.isNotEmpty) {
        _currentUser = users.first;
        _displayName = _currentUser!.displayName;
        if (_moodStatus.isEmpty) {
          _moodStatus = 'Happy';
        }
      }
    }

    _nameController.text = _displayName;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarFileNameKey, _avatarFileName ?? '');
    await prefs.setString(_displayNameKey, _displayName);
    await prefs.setString(_moodStatusKey, _moodStatus);
  }


  void _showEditDialog() {
    _nameController.text = _displayName;
    String tempMoodStatus = _moodStatus;
    String? tempAvatarFileName = _avatarFileName;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2D1B4E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Color(0xFF7FD4C1),
                  width: 2,
                ),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Color(0xFF7FD4C1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Section
                    const Text(
                      'Avatar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final XFile? picked = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (picked != null) {
                            final avatarDir = await _getAvatarDirectory();
                            final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
                            await File(picked.path).copy('$avatarDir/$fileName');
                            
                            // Delete old avatar if exists
                            if (tempAvatarFileName != null && tempAvatarFileName!.isNotEmpty) {
                              final oldFile = File('$avatarDir/$tempAvatarFileName');
                              if (await oldFile.exists()) {
                                await oldFile.delete();
                              }
                            }
                            
                            setDialogState(() {
                              tempAvatarFileName = fileName;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to pick image: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: FutureBuilder<String?>(
                        future: () async {
                          if (tempAvatarFileName != null && tempAvatarFileName!.isNotEmpty) {
                            final dir = await _getAvatarDirectory();
                            return '$dir/$tempAvatarFileName';
                          } else {
                            return await _getAvatarPath();
                          }
                        }(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final file = File(snapshot.data!);
                            if (file.existsSync()) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF7FD4C1),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar();
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                          
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF7FD4C1),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _currentUser != null
                                  ? Image.asset(
                                      _currentUser!.avatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar();
                                      },
                                    )
                                  : _buildDefaultAvatar(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Name Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7FD4C1)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7FD4C1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Mood Status Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mood Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _moodOptions.map((mood) {
                        final isSelected = tempMoodStatus == mood;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempMoodStatus = mood;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF7FD4C1)
                                  : const Color(0xFF7FD4C1).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.white
                                    : const Color(0xFF7FD4C1).withOpacity(0.5),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              mood,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                    if (_nameController.text.trim().isNotEmpty) {
                      setState(() {
                        _displayName = _nameController.text.trim();
                        _moodStatus = tempMoodStatus;
                        if (tempAvatarFileName != null) {
                          _avatarFileName = tempAvatarFileName;
                        }
                      });
                      _saveUserData();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF7FD4C1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutUs() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutUsScreen(),
      ),
    );
  }

  Widget _buildMenuItem({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
            
            ),
            child: ClipRRect(
              
              child: Image.asset(
                imagePath,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 52,
                    height: 52,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: CommonBackground(
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFEA8DFF),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: CommonBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      // User Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4F4A7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: FutureBuilder<String?>(
                                  future: _getAvatarPath(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Image.file(
                                        File(snapshot.data!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildDefaultAvatar();
                                        },
                                      );
                                    } else if (_currentUser != null) {
                                      return Image.asset(
                                        _currentUser!.avatar,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildDefaultAvatar();
                                        },
                                      );
                                    } else {
                                      return _buildDefaultAvatar();
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display Name
                                  Text(
                                    _displayName.isNotEmpty ? _displayName : (_currentUser?.displayName ?? 'User'),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Mood Status
                                  Row(
                                    children: [
                                      const Text(
                                        '#',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.emoji_emotions,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      Text(
                                        _moodStatus,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Edit Button
                            GestureDetector(
                              onTap: _showEditDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.edit,
                                  size: 24,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Wallet Image (clickable)
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 90,
                            child: Image.asset(
                              'assets/pebbo_wallet_nor.webp',
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 90,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Menu Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4B5F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMenuItem(
                                  imagePath: 'assets/pebbo_me_user.webp',
                                  label: 'User Contract',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const TermsOfServiceScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildMenuItem(
                                  imagePath: 'assets/pebbo_me_privacy.webp',
                                  label: 'Privacy Policy',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const PrivacyPolicyScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMenuItem(
                                  imagePath: 'assets/pebbo_me_us.webp',
                                  label: 'About us',
                                  onTap: _showAboutUs,
                                ),
                                // Empty space for 2x2 grid
                                const SizedBox(width: 64, height: 64),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Calculate bottom padding to account for TabBar
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 100,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}
