import 'package:flutter/material.dart';
import 'package:eyexaminer_refactor/services/auth_service.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:eyexaminer_refactor/widgets/common_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password baru dan konfirmasi tidak cocok."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final result = await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: result.contains("sukses")
                ? Colors.green
                : Colors.red,
          ),
        );

        if (result == "Password berhasil diubah.") {
          Navigator.of(context).pop();
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color buttonColor = AppColors.primaryRed;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Change Password',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CommonTextField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  icon: Icons.lock,
                  validator: (val) => val!.isEmpty
                      ? 'Please enter your current password'
                      : null,
                ),
                const SizedBox(height: 20),
                CommonTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  icon: Icons.lock,
                  validator: (val) => val!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 20),
                CommonTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  icon: Icons.lock,
                  validator: (val) =>
                      val!.isEmpty ? 'Please confirm your new password' : null,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Update Password',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
