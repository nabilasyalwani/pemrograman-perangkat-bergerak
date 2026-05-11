import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:eyexaminer_refactor/screens/input_data_page.dart';
import 'package:eyexaminer_refactor/screens/home_page.dart';
import 'package:eyexaminer_refactor/services/common_api_service.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ScanPage extends StatefulWidget {
  final String? ipCameraBaseUrl;
  const ScanPage({super.key, this.ipCameraBaseUrl});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? controller;
  Interpreter? _interpreter;
  List<String>? _labels;
  List<CameraDescription>? cameras;
  String? _streamUrl;
  String? _captureUrl;
  bool _isRearCameraSelected = true;
  bool _isLoadingModel = true;
  bool _useIpCamera = false;
  bool _checkingStream = true;

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
    _initStreamCheck();
  }

  Future<void> _initStreamCheck() async {
    setState(() {
      _checkingStream = true;
    });

    final ip = widget.ipCameraBaseUrl ?? "http://192.168.137.92:5000";
    final streamUrl = "$ip/video_feed";
    final captureUrl = "$ip/capture";
    final testUrl = "$ip/";

    try {
      final resp = await CommonApiService.get<bool>(
        testUrl,
        parser: (_) => true,
      );
      if (resp == true) {
        setState(() {
          _useIpCamera = true;
          _streamUrl = streamUrl;
          _captureUrl = captureUrl;
        });
      } else {
        setState(() {
          _useIpCamera = false;
        });
        _initializeCamera();
      }
    } catch (e) {
      setState(() {
        _useIpCamera = false;
      });
      _initializeCamera();
    } finally {
      setState(() {
        _checkingStream = false;
      });
    }
  }

  Future<void> _processImageFromBytes(Uint8List bytes) async {
    final tmpDir = await getTemporaryDirectory();
    final file = File(
      '${tmpDir.path}/capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    final xfile = XFile(file.path);
    await _processImage(xfile);
  }

  Future<void> _onCapture() async {
    if (_useIpCamera) {
      if (_captureUrl == null) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );

      try {
        final resp = await http
            .get(Uri.parse(_captureUrl!))
            .timeout(const Duration(seconds: 3));

        if (!mounted) return;
        Navigator.of(context).pop();

        if (resp.statusCode == 200) {
          await _processImageFromBytes(resp.bodyBytes);
        } else {
          _showError(
            "Failed to get image from camera (status ${resp.statusCode})",
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _showError("Error fetching image from IP camera: $e");
      }
    } else {
      if (controller == null || !controller!.value.isInitialized) {
        _showError("Camera HP belum terinisialisasi.");
        return;
      }
      try {
        final image = await controller!.takePicture();
        await _processImage(image);
      } catch (e) {
        _showError("Error mengambil gambar dari HP: $e");
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _initializeCamera([bool rearCamera = true]) async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        if (mounted) {
          _showErrorDialog("Tidak ada kamera yang tersedia di perangkat ini.");
        }
        return;
      }

      final selectedCamera = cameras!.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (rearCamera ? CameraLensDirection.back : CameraLensDirection.front),
        orElse: () => cameras!.first,
      );

      controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal menginisialisasi kamera: $e');
      }
    }
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/dr_classification_model_mata_undaan.tflite',
      );
      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Gagal memuat model ML atau label: $e. Pastikan file ada di assets/models/ dan pubspec.yaml sudah benar.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingModel = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Error',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.accentBackground,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Oke',
              style: GoogleFonts.poppins(color: AppColors.mistBlue),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  Future<Map<String, dynamic>> callAPIWithForm(
    Uint8List image,
    bool opt,
  ) async {
    final response = await CommonApiService.post(
      "https://eyexaminer-pkm.onrender.com/classify",
      {
        'image_data': MultipartFile.fromBytes(image, filename: 'upload.jpg'),
        'option': opt,
      },
      isFormData: true,
      parser: (data) => Map<String, dynamic>.from(data),
    );

    if (response != null) {
      return response;
    }
    throw Exception('Gagal memanggil API');
  }

  Future<void> _processImage(XFile image) async {
    if (_interpreter == null || _labels == null || _labels!.isEmpty) {
      if (mounted) {
        _showErrorDialog(
          'Model ML atau label belum dimuat. Mohon tunggu atau restart aplikasi.',
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.mistBlue),
            SizedBox(height: 16),
            Text(
              'Menganalisis gambar...',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      final imageBytes = await image.readAsBytes();
      if (_useIpCamera) {
        debugPrint("Masuk ke upload image server");
        final apiResult = await callAPIWithForm(imageBytes, _useIpCamera);
        String detectedDRType = apiResult['label'] ?? 'Unknown';
        double maxConfidence = apiResult['confidence'] != null
            ? (apiResult['confidence'] as num).toDouble()
            : 0.0;
        int? reorderedIndex = apiResult['reorderedIndex'];
        String? base64ImageFix = apiResult['image_fix'];
        String? base64ImageRaw = apiResult['image_raw'];
        String? base64ImageCrop = apiResult['image_crop'];

        if ((base64ImageFix == null || base64ImageFix.isEmpty) &&
            (base64ImageRaw == null || base64ImageRaw.isEmpty) &&
            (base64ImageCrop == null || base64ImageCrop.isEmpty)) {
          throw Exception("Image from server is empty!");
        }

        Uint8List decodedImageFix = base64Decode(base64ImageFix!);
        Uint8List decodedImageRaw = base64Decode(base64ImageRaw!);
        Uint8List decodedImageCrop = base64Decode(base64ImageCrop!);

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/processed.png');
        final fileRaw = File('${tempDir.path}/raw.png');
        final fileCrop = File('${tempDir.path}/crop.png');
        await file.writeAsBytes(decodedImageFix);
        await fileRaw.writeAsBytes(decodedImageRaw);
        await fileCrop.writeAsBytes(decodedImageCrop);
        XFile xfile = XFile(file.path);
        XFile xfileRaw = XFile(fileRaw.path);
        XFile xfileCrop = XFile(fileCrop.path);
        if (mounted) {
          Navigator.of(context).pop();
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InputDataPasienPage(
                  imagePath: xfile.path,
                  imagePathRaw: xfileRaw.path,
                  imagePathCrop: xfileCrop.path,
                  analysisResult: {
                    'label': detectedDRType,
                    'confidence': maxConfidence,
                    'reorderedIndex': reorderedIndex,
                  },
                ),
              ),
            );
          }
        }
      } else {
        debugPrint("Masuk ke upload image biasa");
        final prediction = await _runInference(imageBytes);
        final remapping = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3};
        int reorderedIndex =
            remapping[prediction['index']] ?? prediction['index'];
        if (prediction['confidence'] < 0.5) {
          prediction['label'] = 'Unknown';
        }
        if (prediction['label'] == 'mild') {
          prediction['label'] = 'Mild DR';
        } else if (prediction['label'] == 'moderate') {
          prediction['label'] = 'Moderate DR';
        } else if (prediction['label'] == 'severe') {
          prediction['label'] = 'Severe DR';
        } else if (prediction['label'] == 'proliferative') {
          prediction['label'] = 'Proliferative DR';
        }
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InputDataPasienPage(
                imagePath: image.path,
                imagePathRaw: image.path,
                imagePathCrop: image.path,
                analysisResult: {
                  'label': prediction['label'],
                  'confidence': prediction['confidence'],
                  'reorderedIndex': reorderedIndex,
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        if (mounted) {
          _showErrorDialog('Gagal menganalisis gambar dengan model ML: $e');
        }
      }
    }
  }

  Future<Map<String, dynamic>> _runInference(Uint8List imageBytes) async {
    var inputShape = _interpreter!.getInputTensor(0).shape;
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    var input = _preprocessImageForTflite(imageBytes, inputShape);
    var output = List<double>.filled(outputShape[1], 0).reshape(outputShape);
    _interpreter!.run(input, output);
    List<double> probabilities = output[0];
    double maxConfidence = 0.0;
    int maxIndex = 0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }
    debugPrint(
      'Inference result: ${_labels![maxIndex]} with confidence $maxConfidence',
    );
    return {
      'label': _labels![maxIndex],
      'confidence': maxConfidence,
      'index': maxIndex,
    };
  }

  List<dynamic> _preprocessImageForTflite(Uint8List bytes, List<int> shape) {
    final image = img.decodeImage(bytes)!;
    final resized = img.copyResize(image, width: shape[1], height: shape[2]);
    var input = List.generate(
      1,
      (index) => List.generate(
        shape[1],
        (y) => List.generate(shape[2], (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );
    return input;
  }

  Future<void> _onPickFromGallery() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      await _processImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingModel ||
        _checkingStream ||
        ((!_useIpCamera) &&
            (controller == null || !controller!.value.isInitialized))) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.biruMedium, AppColors.biruGelap],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryRed),
                const SizedBox(height: 16),
                Text(
                  _checkingStream
                      ? 'Mengecek IP camera...'
                      : (_isLoadingModel
                            ? 'Memuat model ML...'
                            : 'Menginisialisasi kamera...'),
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _useIpCamera
                ? Container(
                    color: Colors.black,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          _streamUrl!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _useIpCamera = false;
                                });
                                _initializeCamera();
                              }
                            });

                            return const Center(
                              child: Text(
                                'Stream gagal, fallback ke kamera HP',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : CameraPreview(controller!),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ),

          // Kontrol bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.black.withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: _onPickFromGallery,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFFE53E3E),
                      size: 36,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onCapture,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF1F3467), width: 3),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isRearCameraSelected = !_isRearCameraSelected;
                      });
                      _initializeCamera(_isRearCameraSelected);
                    },
                    icon: const Icon(
                      Icons.flip_camera_ios_outlined,
                      color: Color.fromARGB(255, 44, 102, 227),
                      size: 36,
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
