import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            index: 0,
            currentIndex: currentIndex,
            normalImage: 'assets/tab/pebbo_home_nor.webp',
            selectedImage: 'assets/tab/pebbo_home_pre.webp',
            onTap: () => onTap(0),
          ),
          _TabItem(
            index: 1,
            currentIndex: currentIndex,
            normalImage: 'assets/tab/pebbo_master_nor.webp',
            selectedImage: 'assets/tab/pebbo_master_pre.webp',
            onTap: () => onTap(1),
          ),
          _TabItem(
            index: 2,
            currentIndex: currentIndex,
            normalImage: 'assets/tab/pebbo_ai_nor.webp',
            selectedImage: 'assets/tab/pebbo_ai_pre.webp',
            onTap: () => onTap(2),
          ),
          _TabItem(
            index: 3,
            currentIndex: currentIndex,
            normalImage: 'assets/tab/pebbo_me_nor.webp',
            selectedImage: 'assets/tab/pebbo_me_pre.webp',
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String normalImage;
  final String selectedImage;
  final VoidCallback onTap;

  const _TabItem({
    required this.index,
    required this.currentIndex,
    required this.normalImage,
    required this.selectedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        isSelected ? selectedImage : normalImage,
        width: 72,
        height: 75,
        fit: BoxFit.contain,
      ),
    );
  }
}

