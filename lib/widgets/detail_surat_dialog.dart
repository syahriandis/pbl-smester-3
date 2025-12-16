import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/pages/preview_surat_page.dart';

class DetailSuratDialog extends StatelessWidget {
  final Map<String, dynamic> surat;

  const DetailSuratDialog({
    super.key,
    required this.surat,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Detail Surat",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jenis Surat: ${surat['jenisSurat']}"),
            const SizedBox(height: 6),
            Text("Tanggal: ${surat['tanggal']}"),
            const SizedBox(height: 6),
            Text("Status: ${surat['status']}"),
            const SizedBox(height: 6),
            Text("Keperluan: ${surat['keperluan'] ?? '-'}"),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // ✅ ACTION BUTTONS (khusus warga/security)
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tutup"),
        ),

        // ✅ Jika surat sudah selesai → tampilkan tombol Preview
        if (surat['status'] == "selesai" && surat['file_surat'] != null)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PreviewSuratPage(
                    fileSurat: surat['file_surat'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Preview Surat"),
          ),
      ],
    );
  }
}