import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eyexaminer_refactor/services/firestore_service.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  ScanHistoryPageState createState() => ScanHistoryPageState();
}

class ScanHistoryPageState extends State<ScanHistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _confirmDelete(BuildContext context, String scanId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Confirm Deletion', style: GoogleFonts.poppins()),
          content: Text(
            'Are you sure you want to delete this scan history?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                await _firestoreService.deleteScanFromHistory(scanId);
                if (!mounted) return;
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'History item deleted.',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: AppColors.primaryRed),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Scan History',
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getScanHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'Error loading history',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: Colors.white, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'No scan history found.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your scan results will appear here after you save them.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: docs.length,
                itemBuilder: (contedocsxt, index) {
                  final doc = docs[index];
                  return _buildHistoryCard(context, doc);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
        : 'No date';
    final detectedCondition =
        data['detectedCondition'] ??
        (data['label'] ?? 'No Label').replaceAll('_', ' ');
    final imageUrl = data['imageUrl'];
    final double rawLogit = (data['confidence'] ?? 0.0).toDouble();
    final double confidence = rawLogit * 100;
    final blindnessRisk5y =
        data['blindnessRisk5Years'] ?? data['blindRisk5y'] ?? 'N/A';
    final riskLevel = data['riskLevel'] ?? 'Unknown';
    final riskCategory = data['riskCategory'] ?? 'Unknown';
    final urgencyLevel = data['urgencyLevel'] ?? 'Consult Specialist';
    final checkupInterval =
        data['recommendedCheckupInterval'] ?? 'Consult doctor';

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // putih semi transparan
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(12.0),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const SizedBox(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 30),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detectedCondition,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.accentBackground,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Confidence: ${confidence.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(riskLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    riskLevel,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Text(
              '5Y Blindness Risk: $blindnessRisk5y%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF046399), // biru muda
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Next checkup: $checkupInterval',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.accentBackground.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.accentBackground.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: AppColors.primaryRed.withValues(alpha: 0.8),
          ), // merah tua
          onPressed: () => _confirmDelete(context, doc.id),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentBackground.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Prediction Analysis',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.accentBackground,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Risk Category', riskCategory),
                _buildDetailRow('Urgency Level', urgencyLevel),
                _buildDetailRow('Recommended Action', checkupInterval),
                const SizedBox(height: 8),
                if (data['progressionRisk'] != null)
                  _buildDetailRow('Progression Risk', data['progressionRisk']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan Version: ${data['scanVersion'] ?? '1.0'}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (imageUrl != null)
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                Dialog(child: Image.network(imageUrl)),
                          );
                        },
                        icon: const Icon(Icons.zoom_in, size: 16),
                        label: Text(
                          'View Image',
                          style: GoogleFonts.poppins(fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBackground.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.accentBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
