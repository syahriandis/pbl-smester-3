import 'package:flutter/material.dart';

class DetailPengaduanDialog extends StatelessWidget {
  final Map<String, dynamic> pengaduan;

  const DetailPengaduanDialog({super.key, required this.pengaduan});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detail Pengaduan'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(pengaduan['kategori']),
            const SizedBox(height: 10),
            const Text(
              'Deskripsi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(pengaduan['deskripsi']),
            const SizedBox(height: 10),
            const Text(
              'Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(pengaduan['status']),
            const SizedBox(height: 10),
            const Text(
              'Tanggal Pengaduan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(pengaduan['tanggal']),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
