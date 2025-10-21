import 'package:flutter/material.dart';
import 'dart:io';

class DetailSuratDialog extends StatelessWidget {
  final Map<String, dynamic> surat;
  const DetailSuratDialog({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jenis Surat: ${surat['jenisSurat']}"),
              Text("Nama: ${surat['nama']}"),
              Text("NIK: ${surat['nik']}"),
              Text("Alamat: ${surat['alamat']}"),
              Text("Keperluan: ${surat['keperluan']}"),
              Text("Tanggal: ${surat['tanggal']}"),
              Text("Status: ${surat['status']}"),
              const SizedBox(height: 10),
              if (surat['dokumen'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(surat['dokumen']), height: 150),
                ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
