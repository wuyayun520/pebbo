import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../widgets/common_background.dart';

class PebboChatScreen extends StatefulWidget {
  // Pebbo 主题色和渐变
  static const Color primaryColor = Color(0xFF71AAFF);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF71AAFF), Color(0xFF5A8FDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color primaryEnd = Color(0xFF5A8FDD);
  final String userId;
  final String userName;
  final String userAvatar;

  const PebboChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<PebboChatScreen> createState() => _PebboChatScreenState();
}

class _PebboChatScreenState extends State<PebboChatScreen> {
  List<_PebboChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _voiceRecorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _loadMessages().then((_) {
      // Show tip dialog if no messages exist
      if (_messages.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showChatTipDialog();
        });
      }
    });
  }

  Future<String> _getMediaDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/pebbo_chat_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir.path;
  }

  Future<void> _loadMessages() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pebbo_chat_history_${widget.userId}.json');
    if (await file.exists()) {
      try {
        final jsonStr = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonStr);
        
        setState(() {
          _messages = jsonList.map((e) => _PebboChatMessage.fromJson(e)).toList();
        });
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      } catch (e) {
        debugPrint('Error loading messages: $e');
      }
    }
  }

  void _showChatTipDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PebboChatScreen.primaryColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: PebboChatScreen.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Chat Tip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Long voice messages can be played in the background.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: PebboChatScreen.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Got it',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMessages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pebbo_chat_history_${widget.userId}.json');
      
      final jsonStr = json.encode(_messages.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonStr);
      debugPrint('Saved ${_messages.length} messages for user ${widget.userId}');
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
        _messages.add(_PebboChatMessage(
        text: text,
        isMe: true,
        time: _getTimeStamp(),
          type: _PebboChatMessageType.text,
      ));
    });
    _textController.clear();
    _scrollToBottom();
    _saveMessages();
  }

  Future<void> _sendImage(File imageFile) async {
    try {
      final mediaDir = await _getMediaDirectory();
      final fileName = 'pebbo_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await imageFile.copy('$mediaDir/$fileName');
      
      setState(() {
        _messages.add(_PebboChatMessage(
          imagePath: fileName,
          isMe: true,
          time: _getTimeStamp(),
          type: _PebboChatMessageType.image,
        ));
      });
      _scrollToBottom();
      _saveMessages();
    } catch (e) {
      _showErrorSnackBar('Failed to send image: $e');
    }
  }

  Future<void> _sendVoice(String audioPath, Duration duration) async {
    try {
      final mediaDir = await _getMediaDirectory();
      final fileName = 'pebbo_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await File(audioPath).copy('$mediaDir/$fileName');
      
      setState(() {
        _messages.add(_PebboChatMessage(
          audioPath: fileName,
          audioDuration: duration,
          isMe: true,
          time: _getTimeStamp(),
          type: _PebboChatMessageType.audio,
        ));
      });
      _scrollToBottom();
      _saveMessages();
        
      _showSuccessSnackBar('Voice message sent! 🎵');
    } catch (e) {
      _showErrorSnackBar('Failed to send voice message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 85
      );
      if (picked != null) {
        await _sendImage(File(picked.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _toggleVoiceRecording() async {
    try {
      if (_isRecording) {
        // 停止录制
        final path = await _voiceRecorder.stop();
        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
        });
          
        if (path != null) {
          final duration = await _getAudioDuration(path);
          if (duration.inSeconds > 0) {
            await _sendVoice(path, duration);
          } else {
            _showErrorSnackBar('Recording too short');
          }
        }
      } else {
        // 检查权限
        if (await _voiceRecorder.hasPermission()) {
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/pebbo_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
            
          await _voiceRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: filePath,
          );
            
          setState(() {
            _isRecording = true;
            _recordingStartTime = DateTime.now();
          });
            
          _showInfoSnackBar('Recording... 🎙️ Tap again to stop');
        } else {
          _showErrorSnackBar('Microphone permission denied');
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
      });
      _showErrorSnackBar('Recording error: $e');
    }
  }

  Future<Duration> _getAudioDuration(String path) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(path);
      return player.duration ?? Duration.zero;
    } catch (e) {
      debugPrint('Error getting audio duration: $e');
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF71AAFF),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF71AAFF).withOpacity(0.9),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getTimeStamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _textController.dispose();
    _chatScrollController.dispose();
    _voiceRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/pebbo_all_back.webp',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                widget.userAvatar,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: CommonBackground(
        child: SafeArea(
            child: Column(
              children: [
                // 消息列表
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _chatScrollController,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 16,
                        ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _PebboChatBubble(
                          message: msg,
                          onImageTap: (file) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  backgroundColor: Colors.black,
                                  body: Stack(
                                    children: [
                                      Center(
                                        child: InteractiveViewer(
                                          minScale: 0.5,
                                          maxScale: 3.0,
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        right: 20,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // 输入栏
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: _PebboChatInputBar(
                    controller: _textController,
                    onSend: _sendMessage,
                    onImage: _pickImage,
                    onRecord: _toggleVoiceRecording,
                    isRecording: _isRecording,
                    recordingStartTime: _recordingStartTime,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: PebboChatScreen.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: PebboChatScreen.primaryColor.withOpacity(0.4),
                width: 2,
                ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 60,
              color: PebboChatScreen.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Send a message, photo, or voice note',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PebboChatMessageType { text, image, audio }

class _PebboChatMessage {
  final String? text;
  final String? imagePath;
  final String? audioPath;
  final Duration? audioDuration;
  final bool isMe;
  final String time;
  final _PebboChatMessageType type;

  _PebboChatMessage({
    this.text,
    this.imagePath,
    this.audioPath,
    this.audioDuration,
    required this.isMe,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'imagePath': imagePath,
    'audioPath': audioPath,
    'audioDuration': audioDuration?.inMilliseconds,
    'isMe': isMe,
    'time': time,
    'type': type.name,
  };

  static _PebboChatMessage fromJson(Map<String, dynamic> json) => _PebboChatMessage(
    text: json['text'],
    imagePath: json['imagePath'],
    audioPath: json['audioPath'],
    audioDuration: json['audioDuration'] != null 
        ? Duration(milliseconds: json['audioDuration']) 
        : null,
    isMe: json['isMe'] ?? true,
    time: json['time'] ?? '',
    type: _PebboChatMessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => _PebboChatMessageType.text,
    ),
  );
}

class _PebboChatBubble extends StatefulWidget {
  final _PebboChatMessage message;
  final void Function(File file)? onImageTap;
  const _PebboChatBubble({required this.message, this.onImageTap});

  @override
  State<_PebboChatBubble> createState() => _PebboChatBubbleState();
}

class _PebboChatBubbleState extends State<_PebboChatBubble> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == _PebboChatMessageType.audio) {
      _duration = widget.message.audioDuration ?? Duration.zero;
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      final msg = widget.message;
      final dir = await getApplicationDocumentsDirectory();
      final absPath = '${dir.path}/pebbo_chat_media/${msg.audioPath}';
      
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
        
        // 监听播放状态
        _audioPlayer!.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state.playing;
            });
          }
        });
        
        // 监听播放进度
        _audioPlayer!.positionStream.listen((pos) {
          if (mounted) {
            setState(() {
              _position = pos;
            });
          }
        });
        
        // 监听播放完成
        _audioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              setState(() {
                _position = Duration.zero;
                _isPlaying = false;
              });
            }
          }
        });
      }
      
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.setFilePath(absPath);
        await _audioPlayer!.play();
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    
    if (msg.type == _PebboChatMessageType.audio && msg.audioPath != null) {
      final current = _position > _duration ? _duration : _position;
      return Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
          decoration: BoxDecoration(
            gradient: msg.isMe 
                ? PebboChatScreen.primaryGradient
                : null,
            color: msg.isMe ? null : const Color(0xFF2D1B4E).withOpacity(0.6),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: msg.isMe ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(16),
            ),
            border: msg.isMe ? null : Border.all(color: PebboChatScreen.primaryColor.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: msg.isMe 
                    ? PebboChatScreen.primaryColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: msg.isMe 
                            ? Colors.white.withOpacity(0.25)
                            : PebboChatScreen.primaryEnd.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: msg.isMe 
                              ? Colors.white.withOpacity(0.3)
                              : PebboChatScreen.primaryEnd.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: msg.isMe 
                                ? Colors.white.withOpacity(0.2)
                                : PebboChatScreen.primaryEnd.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: msg.isMe ? Colors.white : PebboChatScreen.primaryEnd,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: (msg.isMe ? Colors.white : PebboChatScreen.primaryEnd).withOpacity(0.2),
                          ),
                          child: LinearProgressIndicator(
                            value: _duration.inMilliseconds == 0 
                                ? 0 
                                : current.inMilliseconds / _duration.inMilliseconds,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              msg.isMe ? Colors.white : PebboChatScreen.primaryEnd
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(current),
                              style: TextStyle(
                                color: msg.isMe ? Colors.white : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(
                                color: msg.isMe ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  msg.time,
                  style: TextStyle(
                    color: msg.isMe ? Colors.white70 : Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (msg.type == _PebboChatMessageType.image && msg.imagePath != null) {
      return Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () async {
            final dir = await getApplicationDocumentsDirectory();
            final absPath = '${dir.path}/pebbo_chat_media/${msg.imagePath}';
            widget.onImageTap?.call(File(absPath));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FutureBuilder<Directory>(
                    future: getApplicationDocumentsDirectory(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(width: 160, height: 160);
                      final absPath = '${snapshot.data!.path}/pebbo_chat_media/${msg.imagePath}';
                      return Image.file(
                        File(absPath),
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 160,
                            height: 160,
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    msg.time,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 文本消息
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: msg.isMe 
                ? PebboChatScreen.primaryGradient
              : null,
            color: msg.isMe ? null : const Color(0xFF2D1B4E).withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: msg.isMe ? null : Border.all(color: PebboChatScreen.primaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: msg.isMe 
                  ? PebboChatScreen.primaryEnd.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text ?? '',
              style: TextStyle(
                color: msg.isMe ? Colors.white : Colors.white,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                msg.time,
                  style: TextStyle(
                    color: msg.isMe ? Colors.white.withOpacity(0.7) : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PebboChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImage;
  final VoidCallback onRecord;
  final bool isRecording;
  final DateTime? recordingStartTime;
  
  const _PebboChatInputBar({
    required this.controller, 
    required this.onSend, 
    required this.onImage, 
    required this.onRecord, 
    required this.isRecording, 
    this.recordingStartTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Column(
          children: [
            if (isRecording && recordingStartTime != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: PebboChatScreen.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: PebboChatScreen.primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 录音动画指示器
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 录音图标
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 录音文字
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // 录音时长
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final elapsed = DateTime.now().difference(recordingStartTime!);
                          return Text(
                            '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1B4E).withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: PebboChatScreen.primaryColor.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: PebboChatScreen.primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 录音按钮
                  Container(
                    decoration: BoxDecoration(
                      gradient: isRecording
                          ? LinearGradient(
                              colors: [
                                PebboChatScreen.primaryEnd.withOpacity(0.8),
                                PebboChatScreen.primaryEnd,
                              ],
                            )
                          : PebboChatScreen.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3), 
                        width: isRecording ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PebboChatScreen.primaryEnd.withOpacity(0.4),
                          blurRadius: isRecording ? 16 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: isRecording ? 24 : 22,
                      ),
                      onPressed: onRecord,
                      tooltip: isRecording ? 'Stop recording' : 'Record voice',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 图片按钮
                  Container(
                    decoration: BoxDecoration(
                      color: PebboChatScreen.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: PebboChatScreen.primaryColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.image_rounded,
                        color: PebboChatScreen.primaryColor,
                        size: 22,
                      ),
                      onPressed: onImage,
                      tooltip: 'Send image',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 输入框
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0A2E).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: PebboChatScreen.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Colors.white60,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 发送按钮
                  Container(
                    decoration: BoxDecoration(
                      gradient: PebboChatScreen.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PebboChatScreen.primaryEnd.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: onSend,
                      tooltip: 'Send message',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}