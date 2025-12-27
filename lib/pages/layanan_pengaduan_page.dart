import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout.dart';
import 'package:login_tes/widgets/tambah_pengaduan_dialog.dart';
import 'package:login_tes/widgets/detail_pengaduan_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LayananPengaduanPage extends StatefulWidget {
  final String token;
  final String role;

  const LayananPengaduanPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<LayananPengaduanPage> createState() => _LayananPengaduanPageState();
}

class _LayananPengaduanPageState extends State<LayananPengaduanPage> {
  List<Map<String, dynamic>> _pengaduanList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    setState(() => _loading = true);
    try {
      String url;
      if (widget.role == "warga") {
        url = "http://localhost:8000/api/pengaduan";
      } else if (widget.role == "rt") {
        url = "http://localhost:8000/api/rt/pengaduan";
      } else {
        url = "http://localhost:8000/api/security/pengaduan";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pengaduanList =
              (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _tambahPengaduan(Map<String, dynamic> dataPengaduan) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:8000/api/pengaduan"),
        headers: {"Authorization": "Bearer ${widget.token}"},
        body: {
          "title": dataPengaduan['kategori'],
          "location": dataPengaduan['lokasi'] ?? '',
          "description": dataPengaduan['deskripsi'],
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengaduan berhasil dikirim")),
        );
        _fetchPengaduan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal kirim pengaduan (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showTambahPengaduanDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahPengaduanDialog(
        onSubmit: _tambahPengaduan,
        token: widget.token,
      ),
    );
  }

  void _showDetailPengaduan(Map<String, dynamic> pengaduan) {
    showDialog(
      context: context,
      builder: (context) => DetailPengaduanDialog(
        pengaduan: pengaduan,
        role: widget.role,
        token: widget.token,
        onRefresh: _fetchPengaduan,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey;
      case 'approved':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'done':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.black26;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'in_progress':
        return 'Diproses';
      case 'done':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayout(
      title: "Layanan Pengaduan",
      onBack: () => Navigator.pop(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                                pengaduan['title'] ??
                                    pengaduan['kategori'] ??
                                    '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pengaduan['created_at'] ??
                                    pengaduan['tanggal'] ??
                                    '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(
                                        _statusLabel(pengaduan['status'])),
                                    backgroundColor:
                                        _statusColor(pengaduan['status']),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      minimumSize: const Size(90, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showDetailPengaduan(pengaduan),
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
                if (widget.role == "warga")
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