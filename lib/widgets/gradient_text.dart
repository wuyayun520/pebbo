import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF9D4EDD),
          Color(0xFF7FD4C1),
          Color(0xFFFF6B9D),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        style: style?.copyWith(
          color: Colors.white,
        ) ?? const TextStyle(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

