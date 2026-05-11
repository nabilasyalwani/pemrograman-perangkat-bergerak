import 'package:flutter/material.dart';
import 'package:eyexaminer_refactor/services/auth_service.dart';
import 'package:eyexaminer_refactor/screens/register_page.dart';
import 'package:eyexaminer_refactor/screens/home_page.dart';
import 'package:eyexaminer_refactor/widgets/custom_link.dart';
import 'package:eyexaminer_refactor/widgets/custom_form_textfield.dart';
import 'package:eyexaminer_refactor/widgets/gradient_button.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool _isLoading = false;
  bool _isPasswordObscure = true;

  void _tryLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      dynamic result = await _auth.signInWithEmailAndPassword(email, password);

      if (!mounted) return;
      if (result == null) {
        setState(() {
          error = 'Could not sign in with those credentials.';
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
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
          ? Center(child: CircularProgressIndicator())
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
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: scaleH(350)),
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: scaleFont(120),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withValues(alpha: 0.25),
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: scaleH(100)),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleW(100),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomFormTextField(
                                  context: context,
                                  hint: 'Enter your email',
                                  icon: Icons.email_outlined,
                                  onChanged: (val) => email = val,
                                  validator: (val) => val!.isEmpty
                                      ? 'Please enter an email'
                                      : null,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: scaleH(50)),
                                CustomFormTextField(
                                  context: context,
                                  hint: 'Enter password',
                                  icon: Icons.lock_outline,
                                  obscureText: _isPasswordObscure,
                                  onChanged: (val) => password = val,
                                  validator: (val) => val!.length < 6
                                      ? 'Password must be 6+ characters'
                                      : null,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.primaryRed,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordObscure =
                                            !_isPasswordObscure;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: scaleH(50)),
                                GradientButton(
                                  label: 'Login',
                                  onPressed: _tryLogin,
                                ),
                                SizedBox(height: scaleH(160)),
                                CustomLink(
                                  label: "Belum punya akun?",
                                  labelLink: 'Register',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  },
                                ),
                                if (error.isNotEmpty) ...[
                                  SizedBox(height: scaleH(20)),
                                  Text(
                                    error,
                                    style: TextStyle(
                                      color: AppColors.primaryRed,
                                      fontSize: scaleFont(30),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
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
