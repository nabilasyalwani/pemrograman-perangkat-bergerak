import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eyexaminer_refactor/services/firestore_service.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanResultPage extends StatefulWidget {
  final String imagePath;
  final String? imagePathRaw;
  final String? imagePathCrop;
  final Map<String, dynamic> analysisResult;
  final String detectedDRType;

  const ScanResultPage({
    super.key,
    required this.imagePath,
    required this.imagePathRaw,
    required this.imagePathCrop,
    required this.analysisResult,
    required this.detectedDRType,
  });

  @override
  ScanResultPageState createState() => ScanResultPageState();
}

class ScanResultPageState extends State<ScanResultPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;
  String? _notificationMessage;
  bool _isError = false;
  int? progressionDays;
  final supabase = Supabase.instance.client;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageSliderCard() {
    final items = [
      {'label': 'Raw', 'path': widget.imagePathRaw ?? widget.imagePath},
      {'label': 'Cropped', 'path': widget.imagePathCrop ?? widget.imagePath},
      {'label': 'Processed', 'path': widget.imagePath},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            SizedBox(
              height: 260,
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final path = items[index]['path'];
                  if (path == null || path.isEmpty) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No image',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final file = File(path);
                  if (!file.existsSync()) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Text(
                          'Image not found',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(file, fit: BoxFit.cover),
                      // Label overlay
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            items[index]['label'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (i) {
                  final selected = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: selected ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception("Image file not found: $imagePath");
    }

    final fileBytes = await file.readAsBytes();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imagePath.split('.').last;
    final fileName = 'scan_$timestamp.$extension';
    final destination = 'scan_images/$fileName';

    try {
      await Supabase.instance.client.storage
          .from('scan_results')
          .uploadBinary(destination, fileBytes);
      final publicUrl = Supabase.instance.client.storage
          .from('scan_results')
          .getPublicUrl(destination);
      if (publicUrl.isEmpty) {
        throw Exception('Failed to generate public URL');
      }

      return publicUrl;
    } catch (e) {
      if (e.toString().contains('already exists')) {
        try {
          await Supabase.instance.client.storage
              .from('scan_results')
              .uploadBinary(
                destination,
                fileBytes,
                fileOptions: const FileOptions(upsert: true),
              );

          final publicUrl = Supabase.instance.client.storage
              .from('scan_results')
              .getPublicUrl(destination);

          return publicUrl;
        } catch (retryError) {
          throw Exception('Retry upload failed: $retryError');
        }
      }
    }
    return '';
  }

  void _saveScanResult() async {
    setState(() {
      _isSaving = true;
      _notificationMessage = null;
    });

    try {
      String? imageUrl;
      try {
        imageUrl = await _uploadImage(widget.imagePath);
      } catch (supabaseError) {
        throw Exception('Supabase upload failed: $supabaseError');
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
          "User not logged in to Firebase (needed for saving scan history)",
        );
      }
      final label = widget.analysisResult['label'];
      final confidence = widget.analysisResult['confidence'];
      final blindRisk5y = widget.analysisResult['probEvent5y'];
      final scanResult = <String, dynamic>{
        'imageUrl': imageUrl,
        'rawLabel': label,
        'confidence': confidence,
        'detectedCondition': _mapLabelToName(label),
        'blindnessRisk5Years': blindRisk5y,
        'riskLevel': _riskLevel(label),
        'riskCategory': _getRiskCategory(blindRisk5y),
        'urgencyLevel': _getUrgencyLevel(label),
        'recommendedCheckupInterval': _getCheckupInterval(label),
        'progressionRisk': _getProgressionRisk(label),
        'survivalCurve': widget.analysisResult['survivalCurve'],
        'riskCurves': widget.analysisResult['riskCurves'],
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestoreService.addScanToHistory(scanResult);
      setState(() {
        _notificationMessage = 'Riwayat berhasil disimpan!';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _notificationMessage = 'Failed to save scan: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// === DR CUSTOM LOGIC ===
  String _mapLabelToName(String label) {
    switch (label.toLowerCase()) {
      case '0':
      case 'mild':
        return "Mild DR";
      case '1':
      case 'moderate':
        return "Moderate DR";
      case '2':
      case 'no dr':
        return "No DR";
      case '3':
      case 'proliferatif dr':
        return "Proliferative DR";
      case '4':
      case 'severe':
        return "Severe DR";
      default:
        return "Unknown";
    }
  }

  String _riskLevel(String label) {
    switch (label.toLowerCase()) {
      case 'no dr':
        return "Low";
      case 'mild':
        return "Medium";
      case 'moderate':
        return "Medium";
      case 'severe':
      case 'proliferatif dr':
        return "High";
      default:
        return "Unknown";
    }
  }

  // Additional prediction methods for comprehensive storage
  String _getRiskCategory(dynamic blindRisk5y) {
    if (blindRisk5y == null) return "Unknown";
    final risk = (blindRisk5y is String)
        ? double.tryParse(blindRisk5y) ?? 0.0
        : (blindRisk5y as num).toDouble();

    if (risk < 5) return "Very Low Risk";
    if (risk < 10) return "Medium Risk";
    if (risk < 20) return "High Risk";
    return "Very High Risk";
  }

  String _getUrgencyLevel(String label) {
    switch (label.toLowerCase()) {
      case 'no dr':
        return "Routine Monitoring";
      case 'mild':
        return "Regular Follow-up";
      case 'moderate':
        return "Close Monitoring";
      case 'severe':
        return "Urgent Attention";
      case 'proliferatif dr':
        return "Immediate Treatment";
      default:
        return "Consult Specialist";
    }
  }

  String _getCheckupInterval(String label) {
    switch (label.toLowerCase()) {
      case 'no dr':
        return "12 months";
      case 'mild':
        return "6-8 months";
      case 'moderate':
        return "3-4 months";
      case 'severe':
        return "1-2 months";
      case 'proliferatif dr':
        return "2-4 weeks";
      default:
        return "Consult doctor";
    }
  }

  String _getProgressionRisk(String label) {
    switch (label.toLowerCase()) {
      case 'no dr':
        return "Minimal";
      case 'mild':
        return "Slow progression likely";
      case 'moderate':
        return "Moderate progression risk";
      case 'severe':
        return "High progression risk";
      case 'proliferatif dr':
        return "Rapid progression possible";
      default:
        return "Unknown";
    }
  }

  List<FlSpot> _mapCurveToSpots(Map<String, dynamic> curve) {
    return curve.entries.map((e) {
      final x = double.tryParse(e.key) ?? 0.0; // waktu (tahun)
      final y = (e.value as num).toDouble(); // probabilitas
      return FlSpot(x, y);
    }).toList()..sort((a, b) => a.x.compareTo(b.x)); // urutkan sumbu-x
  }

  @override
  Widget build(BuildContext context) {
    final String detectedType = _mapLabelToName(widget.analysisResult['label']);
    final double confidence =
        ((widget.analysisResult['confidence'] ?? 0.0) * 100);

    final String risk = _riskLevel(widget.analysisResult['label']);
    final riskCurve = Map<String, dynamic>.from(
      widget.analysisResult['riskCurves'] ?? {},
    );

    final riskSpots = _mapCurveToSpots(riskCurve);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.biruCerah, // biru cerah
            AppColors.biruMedium, // biru medium
            AppColors.biruTua, // biru tua
            AppColors.biruGelap, // navy
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Hasil Scan DR',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryRed),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image slider card (Raw -> Cropped -> Processed)
              _buildImageSliderCard(),
              const SizedBox(height: 32),

              /// Result Cards
              _buildResultCard(
                title: 'Klasifikasi',
                value: detectedType,
                icon: Icons.remove_red_eye_outlined,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'Tingkat Keyakinan',
                value: '${confidence.toStringAsFixed(1)}%',
                icon: Icons.verified_user_outlined,
                iconColor: AppColors.primaryRed,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'Tingkat Risiko',
                value: risk,
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'Prediksi Kebutaan 5 Tahun',
                value:
                    "${widget.analysisResult['probEvent5y']?.toString() ?? "0"} %",
                icon: Icons.timeline,
                iconColor: Colors.blueAccent,
              ),
              const SizedBox(height: 24),

              /// Enhanced Chart Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.timeline,
                            color: AppColors.primaryRed,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grafik Perkembangan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Prediksi risiko dalam tahun',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final percentage = (barSpot.y * 100)
                                      .toStringAsFixed(2);
                                  return LineTooltipItem(
                                    'Tahun ke ${barSpot.x.toStringAsFixed(1)}\n$percentage%',
                                    GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    (value * 100).toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                              axisNameWidget: Text(
                                'Probabilitas (%)',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                              axisNameSize: 15,
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                              axisNameWidget: Text(
                                'Waktu (Tahun)',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                              axisNameSize: 25,
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: riskSpots,
                              isCurved: true,
                              barWidth: 3,
                              color: AppColors.primaryRed,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.primaryRed,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryRed.withValues(alpha: 0.3),
                                    AppColors.primaryRed.withValues(
                                      alpha: 0.05,
                                    ),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Enhanced Save Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryRed, AppColors.redDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveScanResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                  label: Text(
                    _isSaving ? 'Menyimpan...' : 'Simpan ke Riwayat',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_notificationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: Text(
                      _notificationMessage!,
                      style: GoogleFonts.poppins(
                        color: _isError ? AppColors.primaryRed : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              _buildDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Disclaimer Penting',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hasil ini dibuat oleh model AI untuk mendeteksi Retinopati Diabetik. '
            'Informasi ini bukan pengganti nasihat medis profesional. '
            'Silakan konsultasikan dengan dokter spesialis mata untuk diagnosis yang akurat.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
