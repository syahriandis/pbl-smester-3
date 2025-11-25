import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';

class CardWidgetPengaduan extends StatelessWidget {
  final String imagePath;
  final String nama;
  final String deskripsi;
  final String lokasi;
  final String status;
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
            // Gambar pengaduan
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width:
                    screenWidth *
                    0.25, // Ukuran gambar responsif berdasarkan lebar layar
                height: 80, // Sesuaikan tinggi gambar
                fit: BoxFit.cover, // Menjaga agar gambar tidak terdistorsi
              ),
            ),
            const SizedBox(height: 12),

            // Nama Pengadu
            Text(
              nama,
              style: const TextStyle(
                color: Colors.white, // Nama pengadu tetap warna putih dan bold
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),

            // Deskripsi dengan teks putih, tidak bold
            Text(
              deskripsi,
              style: const TextStyle(
                color: Colors.white, // Warna putih
                fontSize: 14,
                fontWeight: FontWeight.normal, // Tidak bold
              ),
            ),
            const SizedBox(height: 6),

            // Lokasi dengan teks putih, tidak bold
            Text(
              lokasi,
              style: const TextStyle(
                color: Colors.white, // Warna putih
                fontSize: 12,
                fontWeight: FontWeight.normal, // Tidak bold
              ),
            ),
            const SizedBox(height: 12),

            // Status dengan warna putih juga
            Text(
              'Status: $status',
              style: const TextStyle(
                color: Colors.white, // Warna putih
                fontWeight: FontWeight.normal, // Tidak bold
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Tolak dan Terima dipindah ke bawah
            if (status == 'Menunggu') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Tombol Tolak
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTolak,
                      child: const Text(
                        'Tolak',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Tombol Terima
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTerima,
                      child: const Text(
                        'Terima',
                        style: TextStyle(color: Colors.white),
                      ),
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
