import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout.dart';
import 'package:login_tes/widgets/tambah_surat_dialog.dart';
import 'package:login_tes/widgets/detail_surat_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _fetchSuratList();
  }

  Future<void> _fetchSuratList() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/warga/surat'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      data.sort((a, b) => b['tanggal_pengajuan'].compareTo(a['tanggal_pengajuan']));

      setState(() {
        _suratList = data.map((item) {
          return {
            'id': item['id_pengajuan'],
            'jenisSurat': item['jenis_surat']['nama_jenis_surat'],
            'tanggal': item['tanggal_pengajuan'],
            'status': item['status'],
            'file_surat': item['file_surat'],
            'keperluan': item['keperluan'],
            'detail': item,
          };
        }).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _downloadSurat(String fileName) async {
  final encoded = Uri.encodeComponent(fileName);
  // ✅ Pakai storage route aja, konsisten
  final url = "http://localhost:8000/api/storage/surat_jadi/$encoded";
  final uri = Uri.parse(url);

  if (!await canLaunchUrl(uri)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gagal membuka file surat")),
    );
    return;
  }

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

  void _showTambahSuratDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahSuratDialog(token: widget.token),
    ).then((_) async {
      await _fetchSuratList(); // refresh list setelah dialog ditutup
    });
  }

  void _showDetailSurat(Map<String, dynamic> surat) {
    showDialog(
      context: context,
      builder: (context) => DetailSuratDialog(surat: surat),
    );
  }

  Widget _buildSuratList(String status) {
    final filtered = _suratList.where((s) => s['status'] == status).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("Belum ada surat di status ini"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final surat = filtered[index];
        final isToday = surat['tanggal'] == DateFormat('yyyy-MM-dd').format(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getStatusIcon(surat['status']), color: _getStatusColor(surat['status'])),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        surat['jenisSurat'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    if (isToday)
                      const Text("Baru", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(surat['tanggal'], style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text("Keperluan: ${surat['keperluan'] ?? '-'}"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(surat['status']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        surat['status'].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (surat['status'] == "selesai" && surat['file_surat'] != null)
                      ElevatedButton(
                        onPressed: () => _downloadSurat(surat['file_surat']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(80, 30),
                        ),
                        child: const Text("Download", style: TextStyle(color: Colors.white)),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _showDetailSurat(surat),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(80, 30),
                        ),
                        child: const Text("Lihat Detail", style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'disetujui': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_top;
      case 'disetujui': return Icons.check_circle_outline;
      case 'selesai': return Icons.download_done;
      case 'ditolak': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MainLayananLayout(
        title: "Layanan Surat",
        onBack: () => Navigator.pop(context),
        body: Stack(
          children: [
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black,
                        indicatorColor: Colors.green,
                        tabs: [
                          Tab(text: "Pending"),
                          Tab(text: "Disetujui"),
                          Tab(text: "Selesai"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildSuratList("pending"),
                            _buildSuratList("disetujui"),
                            _buildSuratList("selesai"),
                          ],
                        ),
                      ),
                    ],
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
      ),
    );
  }
}