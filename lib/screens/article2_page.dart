import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:eyexaminer_refactor/widgets/circle_decoration.dart';
import 'package:eyexaminer_refactor/services/notification_service.dart';

class Article2Page extends StatelessWidget {
  const Article2Page({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // await NotificationService.createNotification(
      //   id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      //   title: 'URL Launch Error',
      //   body: 'Gagal membuka URL.',
      // );
      debugPrint('Could not launch $url');
    }
  }

  Widget _smallGap() => const SizedBox(height: 8);
  Widget _mediumGap() => const SizedBox(height: 16);
  Widget _largeGap() => const SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Health Article',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(
                        'Makanan dan Pola Hidup untuk Penderita Retinopati Diabetik',
                      ),
                      _smallGap(),
                      _buildParagraph(
                        'Selain pengobatan medis, pola makan dan gaya hidup yang tepat dapat membantu memperlambat progresi retinopati diabetik dan menjaga kesehatan mata.',
                      ),
                      _largeGap(),
                      _buildSubTitle('1. Makanan Kaya Antioksidan'),
                      _smallGap(),
                      _buildParagraph(
                        'Antioksidan membantu melindungi sel-sel mata dari kerusakan akibat radikal bebas. Konsumsi buah-buahan seperti blueberry, strawberry, dan sayuran hijau gelap seperti bayam dan brokoli sangat dianjurkan.',
                      ),
                      _largeGap(),
                      _buildSubTitle(
                        '2. Makanan yang Mengandung Asam Lemak Omega-3',
                      ),
                      _smallGap(),
                      _buildParagraph(
                        'Omega-3 dapat mendukung kesehatan pembuluh darah retina. Ikan berlemak seperti salmon, sarden, dan makarel, serta biji chia dan flaxseed, bisa menjadi pilihan rutin dalam diet Anda.',
                      ),
                      _largeGap(),
                      _buildSubTitle('3. Batasi Gula dan Karbohidrat Tinggi'),
                      _smallGap(),
                      _buildParagraph(
                        'Kontrol gula darah sangat penting bagi penderita diabetes. Hindari makanan dan minuman tinggi gula, serta karbohidrat olahan, untuk membantu mengurangi risiko kerusakan pembuluh darah retina.',
                      ),
                      _largeGap(),
                      _buildParagraph(
                        'Selain makanan, jangan lupa untuk rutin memeriksakan mata, mengontrol tekanan darah, dan mengikuti saran dokter. Gaya hidup sehat secara keseluruhan dapat memperlambat progresi retinopati diabetik.',
                      ),
                      _mediumGap(),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildSourceLink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.biruMedium,
        height: 1.3,
      ),
    );
  }

  Widget _buildSourceLink() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.redLight, AppColors.primaryRed],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.link, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                children: [
                  const TextSpan(
                    text: 'Sumber artikel asli:\n',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: 'National Eye Institute (NEI)',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL(
                          'https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/diabetic-retinopathy',
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
