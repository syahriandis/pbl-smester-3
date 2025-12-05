import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';

void showInfoDetailDialog(BuildContext context, Map<String, dynamic> info) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= Gambar =================
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (info['image'] != null && info['image'].toString().isNotEmpty)
                    ? (info['image'].toString().startsWith('http')
                        ? Image.network(
                            info['image'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            info['image'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ))
                    : Image.asset(
                        "assets/images/default.jpg", // fallback default
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 16),

              // ================= Judul =================
              Text(
                info['title'] ?? 'Tanpa Judul',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // ================= Lokasi =================
              Row(
                children: [
                  const Icon(Icons.location_on, color: primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      info['location'] ?? '-',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ================= Tanggal + Hari + Jam =================
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${info['day'] ?? ''}, ${info['date'] ?? ''} ${info['time'] ?? ''}",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ================= Deskripsi =================
              Text(
                info['description'] ?? 'Tidak ada deskripsi',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),

              // ================= Tombol Tutup =================
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    },
  );
}