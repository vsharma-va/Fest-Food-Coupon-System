import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  GradientText(this.text, this.fontSize);

  final String text;
  final double? fontSize;
  Gradient gradient = LinearGradient(
    colors: [
      Colors.blue.shade400,
      Colors.blue.shade900,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        overflow: TextOverflow.clip,
        style: TextStyle(
          fontSize: fontSize ?? 40,
          fontWeight: FontWeight.bold,
          shadows: <Shadow>[
            Shadow(
              offset: const Offset(3.0, 3.0),
              blurRadius: 3.0,
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            ),
            Shadow(
              offset: const Offset(3.0, 3.0),
              blurRadius: 8.0,
              color: const Color.fromARGB(125, 0, 0, 255).withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
