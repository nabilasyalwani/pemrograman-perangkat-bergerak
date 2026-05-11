import 'package:flutter/material.dart';

class CircleDecoration extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  const CircleDecoration({
    required this.top,
    this.left,
    this.right,
    required this.size,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
