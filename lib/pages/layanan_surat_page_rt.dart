// lib/pages/layanan_surat_page_rt.dart
import 'package:flutter/material.dart';
import 'package:login_tes/widgets/main_layanan_layout_rt.dart'; // Import layout RT
import 'package:login_tes/widgets/surat_list_widget.dart'; // Import widget Surat

class LayananSuratPageRT extends StatefulWidget {
  const LayananSuratPageRT({super.key});

  @override
  _LayananSuratPageRTState createState() => _LayananSuratPageRTState();
}

class _LayananSuratPageRTState extends State<LayananSuratPageRT> {
  final List<Map<String, dynamic>> _suratList = [
    {
      'jenisSurat': 'Surat Keterangan Domisili',
      'nama': 'Raymond Jefri',
      'deskripsi': 'Permohonan surat domisili untuk keperluan administrasi.',
      'lokasi': 'Jl. Raya No. 5, Batam',
      'status': 'Menunggu Persetujuan',
      'detail':
          'Surat ini digunakan untuk keperluan administrasi kependudukan di daerah Batam. Dibutuhkan untuk pengajuan KTP atau SIM baru.',
      'foto': 'assets/images/foto_domisili.jpg', // Path ke foto
    },
    {
      'jenisSurat': 'Surat Keterangan Tidak Mampu',
      'nama': 'Syahriland Sitangung',
      'deskripsi':
          'Permohonan surat keterangan tidak mampu untuk pengajuan bantuan.',
      'lokasi': 'Jl. Merdeka No. 10, Batam',
      'status': 'Menunggu Persetujuan',
      'detail':
          'Surat keterangan ini digunakan untuk pengajuan bantuan sosial dari pemerintah, seperti bantuan pangan atau kesehatan.',
      'foto': 'assets/images/foto_tidak_mampu.jpg', // Path ke foto
    },
    // Surat lainnya...
  ];

  void _updateStatus(int index, String status) {
    setState(() {
      _suratList[index]['status'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayoutRT(
      title: 'Layanan Surat RT',
      onBack: () => Navigator.pop(
        context,
      ), // Tombol back yang akan kembali ke halaman sebelumnya
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SuratListWidget(
                suratList: _suratList,
                onDetail: (surat) {
                  // Menampilkan detail surat dalam dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(surat['jenisSurat']),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nama: ${surat['nama']}'),
                            Text(
                              'Deskripsi: ${surat['detail']}',
                            ), // Deskripsi lengkap
                            Text('Lokasi: ${surat['lokasi']}'),
                            Text('Status: ${surat['status']}'),
                            SizedBox(height: 10),
                            // Menampilkan foto jika ada
                            if (surat['foto'] != null)
                              Image.asset(surat['foto'], height: 150),
                          ],
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
                    },
                  );
                },
                onSetujui: (surat) {
                  // Memperbarui status saat disetujui
                  _updateStatus(_suratList.indexOf(surat), 'Disetujui');
                },
                onTolak: (surat) {
                  // Memperbarui status saat ditolak
                  _updateStatus(_suratList.indexOf(surat), 'Ditolak');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
