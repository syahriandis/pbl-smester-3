import 'package:flutter/material.dart';

class DetailSuratDialog extends StatelessWidget {
  final Map<String, dynamic> surat;

  const DetailSuratDialog({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    final detail = surat['detail'];

    return AlertDialog(
      title: Text(surat['jenisSurat']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tanggal: ${surat['tanggal']}"),
          Text("Status: ${surat['status']}"),
          const SizedBox(height: 10),
          Text("Catatan RT: ${detail['catatan_rt'] ?? '-'}"),
          const SizedBox(height: 10),
          Text("Data Final: ${detail['data_final'] ?? '-'}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tutup"),
        ),
      ],
    );
  }
}