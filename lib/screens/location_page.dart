import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eyexaminer_refactor/utils/colors.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.accentBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lokasi Anda",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Jl. Ir. Soekarno No.45, Surabaya",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  children: [
                    _buildClinicCard(
                      name: "RS Mata Undaan Surabaya",
                      address: "Jl. Raya Undaan No.109, Surabaya",
                      distance: "2.0 km",
                      context: context,
                    ),
                    _buildClinicCard(
                      name: "RS Mata Ciputra",
                      address: "Jl. Raya Darmo No.37, Surabaya",
                      distance: "3.5 km",
                      context: context,
                    ),
                    _buildClinicCard(
                      name: "RS Mata dr. Soetomo",
                      address: "Jl. Mayjen Prof. Dr. Moestopo No.6-8, Surabaya",
                      distance: "4.0 km",
                      context: context,
                    ),
                    _buildClinicCard(
                      name: "RS Mata dan Bedah Katarak Surabaya",
                      address: "Jl. Raya Gubeng No.67, Surabaya",
                      distance: "3.2 km",
                      context: context,
                    ),
                    _buildClinicCard(
                      name: "Klinik Mata Surya Sehat",
                      address: "Jl. Kertajaya Indah No.12, Surabaya",
                      distance: "5.1 km",
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard({
    required String name,
    required String address,
    required String distance,
    required BuildContext context,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBackground,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryRed,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.directions_walk,
                  color: Color(0xFF046399),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  distance,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF046399),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Lihat Rute",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
