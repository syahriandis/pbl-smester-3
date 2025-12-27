import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';

class CardWidgetPengaduan extends StatelessWidget {
  final String imagePath;   // URL gambar dari API
  final String nama;        // Nama pengadu
  final String deskripsi;   // Deskripsi pengaduan
  final String lokasi;      // Lokasi pengaduan
  final String status;      // Status dari API (pending, approved, rejected, in_progress, done)
  final VoidCallback onTolak;
  final VoidCallback onTerima;

  const CardWidgetPengaduan({
    super.key,
    required this.imagePath,
    required this.nama,
    required this.deskripsi,
    required this.lokasi,
    required this.status,
    required this.onTolak,
    required this.onTerima,
  });

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'in_progress':
        return 'Diproses';
      case 'done':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar pengaduan dari URL
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imagePath,
                width: screenWidth * 0.25,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),

            // Nama Pengadu
            Text(
              nama,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),

            // Deskripsi
            Text(
              deskripsi,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),

            // Lokasi
            Text(
              lokasi,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // Status
            Text(
              'Status: ${_statusLabel(status)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Tolak & Terima hanya muncul kalau status pending
            if (status == 'pending') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTolak,
                      child: const Text('Tolak', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTerima,
                      child: const Text('Terima', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}