import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout.dart';
import 'package:login_tes/widgets/tambah_surat_dialog.dart';
import 'package:login_tes/widgets/detail_surat_dialog.dart';

class LayananSuratPage extends StatefulWidget {
  final String role;
  final String token;

  const LayananSuratPage({
    super.key,
    required this.role,
    required this.token,
  });

  @override
  State<LayananSuratPage> createState() => _LayananSuratPageState();
}

class _LayananSuratPageState extends State<LayananSuratPage> {
  List<Map<String, dynamic>> _suratList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    print("TOKEN DARI LOGIN (LAYANAN SURAT): ${widget.token}");
    _fetchSuratList();
  }

  Future<void> _fetchSuratList() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/surat'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];

      setState(() {
        _suratList = data.map((item) {
          return {
            'id': item['id_pengajuan'],
            'jenisSurat': item['jenis_surat']['nama_jenis_surat'],
            'tanggal': item['tanggal_pengajuan'],
            'status': item['status'],
            'detail': item,
          };
        }).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _tambahSurat(Map<String, dynamic> dataSurat) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/surat'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'id_jenis_surat': dataSurat['id_jenis_surat'],
      }),
    );

    print("=== HASIL SUBMIT SURAT ===");
    print("STATUS: ${response.statusCode}");

    try {
      print("BODY DECODED: ${jsonDecode(response.body)}");
    } catch (e) {
      print("BODY RAW: ${response.body}");
    }

    if (response.statusCode == 200) {
      Navigator.pop(context);
      _fetchSuratList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengajukan surat")),
      );
    }
  }

  void _showTambahSuratDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahSuratDialog(
        token: widget.token,
        onSubmit: _tambahSurat,
      ),
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
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _suratList.isEmpty
                  ? const Center(child: Text("Belum ada pengajuan surat"))
                  : ListView.builder(
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
                                  surat['tanggal'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
          if (widget.role == "warga" || widget.role == "security")
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