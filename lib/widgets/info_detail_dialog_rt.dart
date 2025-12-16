import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/info_edit_detail.dart';

void showInfoDetailDialog(
  BuildContext context,
  Map<String, dynamic> info,
  Function(Map<String, dynamic>) onEdited,
  Function(int) onDelete,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Detail Informasi",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (info['image'] != null && info['image'].toString().isNotEmpty)
                    ? Image.network(
                        info['image'].toString().startsWith('http')
                            ? info['image']
                            : "http://127.0.0.1:8000/${info['image']}",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/default.jpg",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  info['title'] ?? 'Tanpa Judul',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.location_on, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(info['location'] ?? '-', style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.calendar_today, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${info['day'] ?? ''}, ${info['date'] ?? ''} ${info['time'] ?? ''}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                info['description'] ?? 'Tidak ada deskripsi',
                style: const TextStyle(fontSize: 15, height: 1.4),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showInfoEditDialog(context, info, onEdited);
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Edit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete(info['id']);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text("Hapus", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Tutup"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}