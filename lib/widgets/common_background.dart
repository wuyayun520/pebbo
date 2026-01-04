import 'package:flutter/material.dart';

class CommonBackground extends StatelessWidget {
  final Widget child;

  const CommonBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/pebbo_allbg.webp',
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    );
  }
}

