import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';

class InfoDetailDialog extends StatelessWidget {
  final String imagePath;
  final String title;
  final String date;
  final String day;
  final String time;
  final String location;

  const InfoDetailDialog({
    super.key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.day,
    required this.time,
    required this.location,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Gambar event
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Kotak detail (judul, tanggal, hari, waktu, lokasi)
              _buildInfoBox(title, bold: true),
              _buildInfoBox(date),
              _buildInfoBox(day),
              _buildInfoBox(time),
              _buildInfoBox(location, maxLines: 2),

              const SizedBox(height: 20),

              // ✅ Tombol CLOSE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text, {int maxLines = 1, bool bold = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }
}
void showInfoDetailDialog(BuildContext context, Map<String, String> info) {
  showDialog(
    context: context,
    builder: (context) => InfoDetailDialog(
      imagePath: info['image']!,
      title: info['title']!,
      date: '04/09/2025', // contoh tanggal dummy
      day: 'Minggu',
      time: '14.00 s/d selesai',
      location: info['subtitle']!,
    ),
  );
}
