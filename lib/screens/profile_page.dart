import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eyexaminer_refactor/screens/change_password_page.dart';
import 'package:eyexaminer_refactor/screens/login_page.dart';
import 'package:eyexaminer_refactor/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firebase_auth.User? _currentUser =
      firebase_auth.FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  File? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = _currentUser?.photoURL;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      try {
        final uploadedUrl = await _uploadProfileImage();
        if (mounted) {
          await _currentUser?.updatePhotoURL(uploadedUrl);
          setState(() {
            _profileImageUrl = uploadedUrl;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile picture berhasil diupdate!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image gagal diupload: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<String> _uploadProfileImage() async {
    if (_imageFile == null || _currentUser == null) {
      throw Exception("Image file or user is null");
    }
    setState(() => _isLoading = true);

    final file = File(_imageFile!.path);
    if (!await file.exists()) {
      throw Exception("Image file not found: ${_imageFile!.path}");
    }

    final fileBytes = await file.readAsBytes();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _imageFile!.path.split('.').last;
    final fileName = 'scan_$timestamp.$extension';
    final destination = 'profile_images/$fileName';

    try {
      await Supabase.instance.client.storage
          .from('profile_images')
          .uploadBinary(destination, fileBytes);
      final publicUrl = Supabase.instance.client.storage
          .from('profile_images')
          .getPublicUrl(destination);
      if (publicUrl.isEmpty) {
        throw Exception('Failed to generate public URL');
      }
      return publicUrl;
    } catch (e) {
      if (e.toString().contains('already exists')) {
        try {
          await Supabase.instance.client.storage
              .from('profile_images')
              .uploadBinary(
                destination,
                fileBytes,
                fileOptions: const FileOptions(upsert: true),
              );

          final publicUrl = Supabase.instance.client.storage
              .from('profile_images')
              .getPublicUrl(destination);

          return publicUrl;
        } catch (retryError) {
          throw Exception('Image gagal diupload $retryError');
        }
      }

      throw Exception('Image gagal diupload $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color fullNameColor = AppColors.primaryRed;
    const Color emailColor = Colors.white;
    const Color iconColor = AppColors.primaryRed;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: emailColor,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: emailColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : _profileImageUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: iconColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentUser?.displayName ?? 'User Name',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: fullNameColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          _currentUser?.email ?? 'user@example.com',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 1),
                        Colors.white.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        iconColor: iconColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(indent: 20, endIndent: 20),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: 'Logout',
                        iconColor: iconColor, // Warna ikon logout disamakan
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final Color textColor = Color(0xFF2D3748);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 16,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
