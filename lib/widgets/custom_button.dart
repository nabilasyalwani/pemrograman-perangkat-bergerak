import 'dart:math';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double? width;
  final double horizontalPadding;
  final double verticalPadding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.onTap,
    this.text = "Register",
    this.width,
    this.horizontalPadding = 16,
    this.verticalPadding = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = min(size.width / 375.0, size.height / 812.0);
    final fontSize = (18 * scale).clamp(14.0, 24.0);
    final buttonHeight = (56 * scale).clamp(48.0, 72.0);
    final radius = (16 * scale).clamp(12.0, 30.0);

    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFE53935)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding * scale,
                vertical: verticalPadding * scale,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
