import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout.dart';
import 'package:login_tes/widgets/tambah_surat_dialog.dart';
import 'package:login_tes/widgets/detail_surat_dialog.dart';

class LayananSuratPage extends StatefulWidget {
  const LayananSuratPage({super.key});

  @override
  State<LayananSuratPage> createState() => _LayananSuratPageState();
}

class _LayananSuratPageState extends State<LayananSuratPage> {
  final List<Map<String, dynamic>> _suratList = [];

  void _tambahSurat(Map<String, dynamic> dataSurat) {
    setState(() {
      _suratList.add(dataSurat);
    });
  }

  void _showTambahSuratDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahSuratDialog(onSubmit: _tambahSurat),
    );
  }

  void _showDetailSurat(Map<String, dynamic> surat) {
    showDialog(
      context: context,
      builder: (context) => DetailSuratDialog(surat: surat),
    );
  }

  @override
Widget build(BuildContext context) {
  return MainLayananLayout(
    title: "Layanan Surat",
    onBack: () => Navigator.pop(context),
    body: Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _suratList.length,
                itemBuilder: (context, index) {
                  final surat = _suratList[index];
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
                            surat['jenisSurat'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            surat['tanggal'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Status: ${surat['status']}"),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  minimumSize: const Size(80, 30),
                                ),
                                onPressed: () => _showDetailSurat(surat),
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
          ],
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: _showTambahSuratDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
}