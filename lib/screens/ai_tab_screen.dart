import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_background.dart';
import 'pebbo_wallet_screen.dart';

class AiTabScreen extends StatefulWidget {
  const AiTabScreen({super.key});

  @override
  State<AiTabScreen> createState() => _AiTabScreenState();
}

class _AiTabScreenState extends State<AiTabScreen> {
  String? _selectedStyle;
  String? _selectedTheme;
  String? _selectedLocation;
  final TextEditingController _otherRequestsController = TextEditingController();
  bool _isLoading = false;

  final List<String> _styleOptions = ['Trad', 'Neo-Trad', 'BW', 'FL', 'Realism', 'Geo', 'WC'];
  final List<String> _themeOptions = ['Nature', 'Geometry', 'Portraits', 'Symbols', 'Pop Culture'];
  final List<String> _locationOptions = ['Chest', 'Arms', 'Back', 'Thighs', 'Calves'];
  
  static const int _requiredCoins = 18;

  Future<void> _generateTattoo() async {
    // 获取最新金币余额
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('pebboCoins') ?? 0;
    
    // 检查金币是否足够
    if (currentCoins < _requiredCoins) {
      _showInsufficientCoinsDialog();
      return;
    }
    
    // 扣除金币
    await prefs.setInt('pebboCoins', currentCoins - _requiredCoins);
    
    setState(() {
      _isLoading = true;
    });

    // 3秒后显示结果
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final random = Random();
        final imageNumber = random.nextInt(10) + 1;
        final imagePath = 'assets/tattooact/Tattoo$imageNumber.webp';
        
        setState(() {
          _isLoading = false;
        });
        
        _showResultDialog(imagePath);
      }
    });
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
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
            'Insufficient Coins',
            style: TextStyle(
              color: Color(0xFF7FD4C1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You need $_requiredCoins coins to generate a tattoo design. Your current balance is insufficient. Would you like to recharge?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
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
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PebboWalletScreen(),
                  ),
                );
              },
              child: const Text(
                'Recharge',
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
  }

  void _showResultDialog(String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B4E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7FD4C1),
                width: 2,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  // Scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Image
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 400,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF7FD4C1),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 300,
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Recommendation text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const Text(
                                  'Recommended Effect',
                                  style: TextStyle(
                                    color: Color(0xFF7FD4C1),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getRecommendationText(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Close button at bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7FD4C1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
  }

  String _getRecommendationText() {
    final recommendations = [
      'This design perfectly matches your selected style and theme. The placement recommendation is ideal for showcasing this artwork.',
      'Based on your preferences, this tattoo design offers excellent visual impact and complements your chosen location beautifully.',
      'This unique design combines your selected elements in a harmonious way, creating a stunning piece that will age gracefully.',
      'The recommended placement will enhance the design\'s visibility and allow it to flow naturally with your body\'s contours.',
      'This design is perfectly suited for your chosen style and will create a bold statement piece that reflects your personality.',
    ];
    final random = Random();
    return recommendations[random.nextInt(recommendations.length)];
  }

  @override
  void dispose() {
    _otherRequestsController.dispose();
    super.dispose();
  }

  Widget _buildOptionButton(String text, String? selectedValue, Function(String) onTap) {
    final isSelected = selectedValue == text;
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7FD4C1) : const Color(0xFF7FD4C1).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CommonBackground(
        child: Column(
          children: [
            SizedBox(
              height: 238,
              child: Image.asset(
                'assets/pebbo_ai_card.webp',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Style Section
                    const Text(
                      'Style',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _styleOptions.map((option) {
                        return _buildOptionButton(
                          option,
                          _selectedStyle,
                          (value) => setState(() => _selectedStyle = value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Theme Section
                    const Text(
                      'Theme',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _themeOptions.map((option) {
                        return _buildOptionButton(
                          option,
                          _selectedTheme,
                          (value) => setState(() => _selectedTheme = value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Location Section
                    const Text(
                      'Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _locationOptions.map((option) {
                        return _buildOptionButton(
                          option,
                          _selectedLocation,
                          (value) => setState(() => _selectedLocation = value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Other Requests Section
                    const Text(
                      'Other Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD4C1).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _otherRequestsController,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'A Blooming',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Generate Button
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _generateTattoo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                          decoration: BoxDecoration(
                            color: _isLoading 
                                ? const Color(0xFFE8F44C).withOpacity(0.6)
                                : const Color(0xFFE8F44C),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : const Text(
                                  'Generate',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    // Loading indicator
                    if (_isLoading) ...[
                      const SizedBox(height: 32),
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD4C1)),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Generating your tattoo design...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 100), // Extra space for TabBar
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
