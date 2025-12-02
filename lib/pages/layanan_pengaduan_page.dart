import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout.dart';
import 'package:login_tes/widgets/tambah_pengaduan_dialog.dart';
import 'package:login_tes/widgets/detail_pengaduan_dialog.dart';

class LayananPengaduanPage extends StatefulWidget {
  const LayananPengaduanPage({super.key});

  @override
  State<LayananPengaduanPage> createState() => _LayananPengaduanPageState();
}

class _LayananPengaduanPageState extends State<LayananPengaduanPage> {
  final List<Map<String, dynamic>> _pengaduanList = [
    {
      'kategori': 'Kerusakan',
      'deskripsi': 'Lampu taman rusak.',
      'status': 'Menunggu',
      'tanggal': '2025-11-05 20:00',
    },
    {
      'kategori': 'Kebersihan',
      'deskripsi': 'Sampah menumpuk di jalan.',
      'status': 'Diproses',
      'tanggal': '2025-11-04 18:30',
    },
  ];

  void _tambahPengaduan(Map<String, dynamic> dataPengaduan) {
    setState(() {
      _pengaduanList.add(dataPengaduan);
    });
  }

  void _showTambahPengaduanDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahPengaduanDialog(onSubmit: _tambahPengaduan),
    );
  }

  void _showDetailPengaduan(Map<String, dynamic> pengaduan) {
    showDialog(
      context: context,
      builder: (context) => DetailPengaduanDialog(pengaduan: pengaduan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayout(
      title: "Layanan Pengaduan",
      onBack: () => Navigator.pop(context),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pengaduanList.length,
              itemBuilder: (context, index) {
                final pengaduan = _pengaduanList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pengaduan['kategori'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pengaduan['tanggal'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status: ${pengaduan['status']}"),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: const Size(90, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _showDetailPengaduan(pengaduan),
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showTambahPengaduanDialog,
              child: const Text(
                'Tambah Pengaduan',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
