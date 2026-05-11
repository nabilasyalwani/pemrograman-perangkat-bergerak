import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class CustomFormTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final BuildContext? context;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomFormTextField({
    super.key,
    required this.hint,
    this.icon = Icons.person,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.context,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return _buildTextFieldWithIcon(
      context: context,
      hint: hint,
      icon: icon,
      onChanged: (val) => onChanged?.call(val),
      validator: (val) => validator?.call(val),
      obscureText: obscureText,
      keyboardType: keyboardType,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildTextFieldWithIcon({
    required BuildContext context,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    double scaleFont(double val) =>
        val *
        min(
          MediaQuery.of(context).size.width / 1080.0,
          MediaQuery.of(context).size.height / 1920.0,
        );

    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: scaleFont(40), color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFFE53E3E)),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: scaleFont(40),
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20.0),
      ),
    );
  }
}
