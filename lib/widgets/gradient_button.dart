import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? borderColor;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.borderColor,
    this.isLoading = false,
    this.height = 56,
    this.borderRadius = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = gradient ?? AppColors.gradientRed;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: borderColor == null ? defaultGradient : null,
        color: borderColor != null ? Colors.transparent : null,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
        boxShadow: borderColor == null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
