import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:eyexaminer_refactor/screens/login_page.dart';
import 'package:eyexaminer_refactor/screens/register_page.dart';
import 'package:eyexaminer_refactor/widgets/circle_decoration.dart';
import 'package:eyexaminer_refactor/widgets/gradient_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.bounceOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
        );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
        child: Stack(
          children: [
            CircleDecoration(
              top: -50,
              right: -50,
              size: 150,
              color: Colors.white12,
            ),
            CircleDecoration(
              top: 100,
              left: -30,
              size: 100,
              color: Colors.white12,
            ),
            CircleDecoration(
              top: 200,
              right: -40,
              size: 120,
              color: Colors.white24,
            ),
            CircleDecoration(
              top: 300,
              left: -20,
              size: 80,
              color: Colors.white10,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(
                      flex: 2,
                      child: AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: Image.asset(
                                        'assets/images/LOGOPKM.png',
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                AnimatedBuilder(
                                  animation: _textAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _textAnimation.value.clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          30 * (1 - _textAnimation.value),
                                        ),
                                        child: Column(
                                          children: [
                                            ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  const LinearGradient(
                                                    colors: [
                                                      Colors.white,
                                                      Color(0xFFE3F2FD),
                                                    ],
                                                  ).createShader(bounds),
                                              child: Text(
                                                'EyeXaminer',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Colors.white10,
                                                border: Border.all(
                                                  color: Colors.white30,
                                                ),
                                              ),
                                              child: Text(
                                                'see the risk early,\nsee the world longer',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SlideTransition(
                      position: _slideAnimation,
                      child: AnimatedBuilder(
                        animation: _buttonAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _buttonAnimation.value.clamp(0.0, 1.0),
                            child: Column(
                              children: [
                                GradientButton(
                                  label: 'Log In',
                                  icon: Icons.login,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GradientButton(
                                  label: 'Register',
                                  icon: Icons.person_add,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [Colors.white10, Colors.white12],
                                  ),
                                  borderColor: Colors.white30,
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
