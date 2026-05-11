import 'dart:math';
import 'package:flutter/material.dart';
import 'package:eyexaminer_refactor/services/auth_service.dart';
import 'package:eyexaminer_refactor/screens/login_page.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:eyexaminer_refactor/widgets/custom_form_textfield.dart';
import 'package:eyexaminer_refactor/widgets/custom_button.dart';
import 'package:eyexaminer_refactor/widgets/custom_link.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';

  bool _isLoading = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  Future<void> _tryRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (password != confirmPassword) {
      setState(() {
        error = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      error = '';
    });

    final result = await _auth.registerWithEmailAndPassword(
      fullName,
      email,
      password,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        error = 'Failed to register. Please use a valid email.';
        _isLoading = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double designWidth = 1080.0;
    final double designHeight = 1920.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double scaleX = screenWidth / designWidth;
    final double scaleY = screenHeight / designHeight;

    double scaleW(double val) => val * scaleX;
    double scaleH(double val) => val * scaleY;
    double scaleFont(double val) => val * min(scaleX, scaleY);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: scaleW(65),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientBlue,
                  ),
                ),

                Positioned(
                  bottom: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(scaleW(120)),
                        topRight: Radius.circular(scaleW(120)),
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: scaleW(100)),
                    child: Column(
                      children: [
                        SizedBox(height: scaleH(350)),

                        Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            fontSize: scaleFont(120),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.25),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: scaleH(40)),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomFormTextField(
                                context: context,
                                hint: 'Full Name',
                                icon: Icons.person_outline,
                                onChanged: (val) => fullName = val,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Enter your full name';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: scaleH(50)),

                              CustomFormTextField(
                                context: context,
                                hint: 'Enter your email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (val) => email = val,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: scaleH(50)),

                              CustomFormTextField(
                                context: context,
                                hint: 'Enter password',
                                icon: Icons.lock_outline,
                                obscureText: _isPasswordObscure,
                                onChanged: (val) => password = val,
                                validator: (val) {
                                  if (val == null || val.length < 6) {
                                    return 'Password must be 6+ characters';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFFE53E3E),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordObscure = !_isPasswordObscure;
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: scaleH(50)),

                              CustomFormTextField(
                                context: context,
                                hint: 'Confirm password',
                                icon: Icons.lock_outline,
                                obscureText: _isConfirmPasswordObscure,
                                onChanged: (val) => confirmPassword = val,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Confirm your password';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFFE53E3E),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordObscure =
                                          !_isConfirmPasswordObscure;
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: scaleH(50)),

                              CustomButton(
                                onTap: _tryRegister,
                                text: 'Register',
                              ),

                              SizedBox(height: scaleH(160)),

                              CustomLink(
                                label: "Sudah punya akun?",
                                labelLink: "Login",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                              ),

                              if (error.isNotEmpty) ...[
                                SizedBox(height: scaleH(50)),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFE53E3E),
                                    fontSize: scaleFont(30),
                                  ),
                                ),
                              ],

                              SizedBox(height: scaleH(20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
