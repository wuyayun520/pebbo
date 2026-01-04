import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/user_model.dart';
import '../services/like_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final UserModel user;
  final Function(String)? onNotInterested;
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onLikeToggled;

  const VideoPlayerScreen({
    super.key,
    required this.user,
    this.onNotInterested,
    this.isLiked = false,
    this.likeCount = 0,
    this.onLikeToggled,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeVideo();
  }

  Future<void> _handleLikeToggle() async {
    // 切换点赞状态并持久化
    final newIsLiked = await LikeService.toggleLike(widget.user.videoPost.postId, _likeCount);
    final newLikeCount = await LikeService.getLikeCount(widget.user.videoPost.postId, _likeCount);
    
    setState(() {
      _isLiked = newIsLiked;
      _likeCount = newLikeCount;
    });
    
    // 通知父组件更新（不再次切换，只刷新状态）
    if (widget.onLikeToggled != null) {
      widget.onLikeToggled!();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.user.videoPost.videoUrl);
      await _controller!.initialize();
      _controller!.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _duration = _controller!.value.duration;
          _isPlaying = true;
        });
        _controller!.play();
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      setState(() {
        _position = _controller!.value.position;
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _seekTo(Duration position) {
    if (_controller != null) {
      _controller!.seekTo(position);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showNotInterestedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Not Interested',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to hide this video?',
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
                if (widget.onNotInterested != null) {
                  widget.onNotInterested!(widget.user.videoPost.postId);
                }
                Navigator.of(context).pop({'likeToggled': false});
              },
              child: const Text(
                'Confirm',
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
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFEA8DFF),
                ),
              ),
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            if (_showControls)
              SafeArea(
                child: GestureDetector(
                  onTap: () {}, // 阻止事件冒泡到外层
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final likeToggled = _isLiked != widget.isLiked;
                                Navigator.of(context).pop({'likeToggled': likeToggled});
                              },
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
                                Icons.block,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: _showNotInterestedDialog,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: AssetImage(widget.user.avatar),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              InkWell(
                                onTap: () {
                                  _handleLikeToggle();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _isLiked ? const Color(0xFFEA8DFF) : Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: _isLiked ? const Color(0xFFEA8DFF) : Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$_likeCount',
                                        style: TextStyle(
                                          color: _isLiked ? const Color(0xFFEA8DFF) : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.user.videoPost.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.user.videoPost.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA8DFF).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEA8DFF),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    color: Color(0xFFEA8DFF),
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _duration.inMilliseconds > 0
                                        ? _position.inMilliseconds.toDouble()
                                        : 0.0,
                                    min: 0.0,
                                    max: _duration.inMilliseconds > 0
                                        ? _duration.inMilliseconds.toDouble()
                                        : 1.0,
                                    activeColor: const Color(0xFFEA8DFF),
                                    inactiveColor: Colors.white.withOpacity(0.3),
                                    onChanged: (value) {
                                      _seekTo(Duration(milliseconds: value.toInt()));
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  if (_controller != null) {
                                    _seekTo(_position - const Duration(seconds: 10));
                                  }
                                },
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: _isPlaying
                                    ? Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/pebbo_video_pause.webp',
                                        width: 57,
                                        height: 48,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  if (_controller != null) {
                                    _seekTo(_position + const Duration(seconds: 10));
                                  }
                                },
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
          ],
        ),
      ),
    );
  }
}

