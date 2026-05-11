import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eyexaminer_refactor/screens/scan_result_page.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:eyexaminer_refactor/widgets/glass_container.dart';
import 'package:eyexaminer_refactor/widgets/gradient_button.dart';
import 'package:eyexaminer_refactor/widgets/common_textfield.dart';
import 'package:eyexaminer_refactor/services/common_api_service.dart';

class InputDataPasienPage extends StatefulWidget {
  final String imagePath;
  final String? imagePathRaw;
  final String? imagePathCrop;
  final Map<String, dynamic> analysisResult;

  const InputDataPasienPage({
    required this.imagePath,
    required this.imagePathRaw,
    required this.imagePathCrop,
    required this.analysisResult,
    super.key,
  });

  @override
  State<InputDataPasienPage> createState() => _InputDataPasienPageState();
}

class _InputDataPasienPageState extends State<InputDataPasienPage> {
  final _formKey = GlobalKey<FormState>();
  final _usiaController = TextEditingController();
  final _bmiController = TextEditingController();
  final _durasiController = TextEditingController();
  String? _jenisKelamin;
  bool _merokok = false;
  bool _loading = false;

  Future<Map<String, dynamic>> _callPredictionAPI() async {
    final dataMap = {
      'severity_class': widget.analysisResult['reorderedIndex'],
      'usia': _usiaController.text.isNotEmpty
          ? int.tryParse(_usiaController.text)
          : null,
      'bmi': _bmiController.text.isNotEmpty
          ? double.tryParse(_bmiController.text)
          : null,
      'jenis_kelamin': _jenisKelamin,
      'durasi_diabetes': _durasiController.text.isNotEmpty
          ? int.tryParse(_durasiController.text)
          : null,
      'riwayat_merokok': _merokok ? 1 : 0,
    };

    return await CommonApiService.post(
          "https://eyexaminer-pkm.onrender.com/predict",
          dataMap,
          isFormData: true,
          parser: (response) => Map<String, dynamic>.from(response),
        ) ??
        {};
  }

  void _submitForm() async {
    setState(() => _loading = true);

    try {
      final apiResult = await _callPredictionAPI();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanResultPage(
            imagePath: widget.imagePath,
            imagePathRaw: widget.imagePathRaw,
            imagePathCrop: widget.imagePathCrop,
            analysisResult: {
              'label': widget.analysisResult['label'],
              'confidence': widget.analysisResult['confidence'],
              'probEvent5y': (((apiResult['prob_event_5y'] ?? 0) * 100)
                  .toStringAsFixed(2)),
              'survivalCurve': Map<String, double>.from(
                apiResult['survival_curve'] ?? {},
              ),
              'riskCurves': Map<String, double>.from(
                apiResult['risk_curve'] ?? {},
              ),
            },
            detectedDRType: widget.analysisResult['label'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal kirim ke API: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Input Data Pasien',
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
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primaryRed,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hasil Analisis CNN',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          widget.analysisResult['label'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Lengkapi Data (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data tambahan akan meningkatkan akurasi prediksi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(25),
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
                      CommonTextField(
                        controller: _usiaController,
                        label: 'Usia',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      CommonTextField(
                        controller: _bmiController,
                        label: 'BMI (Body Mass Index)',
                        icon: Icons.monitor_weight,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(),
                      const SizedBox(height: 20),
                      CommonTextField(
                        controller: _durasiController,
                        label: 'Durasi Diabetes (tahun)',
                        icon: Icons.timeline,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildSwitchTile(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Analisis Lanjutan',
                  icon: Icons.send,
                  onPressed: _submitForm,
                  isLoading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _jenisKelamin,
        style: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkText),
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        items: [
          DropdownMenuItem(
            value: 'L',
            child: Text('Laki-laki', style: GoogleFonts.poppins()),
          ),
          DropdownMenuItem(
            value: 'P',
            child: Text('Perempuan', style: GoogleFonts.poppins()),
          ),
        ],
        onChanged: (v) => setState(() => _jenisKelamin = v),
      ),
    );
  }

  Widget _buildSwitchTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.smoking_rooms,
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Riwayat Merokok',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _merokok,
            onChanged: (v) => setState(() => _merokok = v),
            activeThumbColor: AppColors.primaryRed,
            activeTrackColor: AppColors.primaryRed.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
