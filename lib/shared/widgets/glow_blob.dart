import 'package:flutter/material.dart';

class GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const GlowBlob({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
