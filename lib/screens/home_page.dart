import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eyexaminer_refactor/screens/article1_page.dart'; // Import artikel 1
import 'package:eyexaminer_refactor/screens/article2_page.dart'; // Import artikel 2
import 'package:eyexaminer_refactor/screens/location_page.dart';
import 'package:eyexaminer_refactor/screens/profile_page.dart';
import 'package:eyexaminer_refactor/screens/history_page.dart';
import 'package:eyexaminer_refactor/screens/scan_page.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'User';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 120.0),
      children: [
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.redLight, AppColors.primaryRed],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Icon(
                          Icons.person,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 30,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "See the risk early, see the world longer!",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanHistoryPage(),
                ),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
            label: Text(
              'Scan History',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "Tips & Articles",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildArticleCard(
          title: "About Diabetic Retinopathy",
          icon: Icons.article_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Article1Page()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildArticleCard(
          title: "Healthy Food for Diabetic Retinopathy patient",
          icon: Icons.restaurant_menu_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Article2Page()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required String title,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 00.1),
              spreadRadius: 1,
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softBlue.withValues(alpha: 00.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: AppColors.softBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePageContent(),
    const ScanPage(),
    const LocationPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ScanPage(ipCameraBaseUrl: "http://192.168.137.92:5000"),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/LOGOPKM.png', width: 32, height: 32),
            const SizedBox(width: 8),
            Text(
              'EyeXaminer',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: [
                SafeArea(child: _widgetOptions[0]),
                _widgetOptions[1],
                SafeArea(child: _widgetOptions[2]),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildCustomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 00.05),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, "Home", 0),
          _buildScanButton(),
          _buildNavItem(Icons.place_outlined, "Places", 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade500,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryRed : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(1),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.redLight, AppColors.primaryRed],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
