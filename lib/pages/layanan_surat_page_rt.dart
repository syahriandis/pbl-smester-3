import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_tes/widgets/main_layanan_layout_rt.dart';
import 'package:login_tes/widgets/surat_list_widget.dart';
import 'detail_surat_rt.dart';

class LayananSuratPageRT extends StatefulWidget {
  final String tokenRT;
  final String role;

  const LayananSuratPageRT({
    super.key,
    required this.tokenRT,
    required this.role,
  });

  @override
  _LayananSuratPageRTState createState() => _LayananSuratPageRTState();
}

class _LayananSuratPageRTState extends State<LayananSuratPageRT> {
  List<Map<String, dynamic>> _suratList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurat();
  }

  // ✅ GET semua surat untuk RT/RW
  Future<void> _fetchSurat() async {
    setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/rt/surat"),
        headers: {
          "Authorization": "Bearer ${widget.tokenRT}",
          "Accept": "application/json",
        },
      );

      print("LIST RT STATUS: ${response.statusCode}");
      print("LIST RT BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];

        setState(() {
          _suratList = List<Map<String, dynamic>>.from(data.map((s) {
            return {
              'id_pengajuan': s['id_pengajuan'],
              'jenisSurat': s['jenis_surat']?['nama_jenis_surat'] ?? '-',
              'nama': s['user']?['name'] ?? '-',
              'keperluan': s['keperluan'] ?? '-',
              'catatan_rt': s['catatan_rt'] ?? '-',
              'status': s['status'] ?? '-',
              'tanggal': s['tanggal_pengajuan'] ?? s['created_at'],
            };
          }));
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data surat")),
        );
      }
    } catch (e) {
      print("ERROR LIST RT: $e");
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat memuat data")),
      );
    }
  }

  // ✅ UPDATE status ke backend
  Future<void> _updateStatusBackend(int index, String status,
      {String? catatan}) async {
    final surat = _suratList[index];

    final response = await http.put(
      Uri.parse("http://localhost:8000/api/rt/surat/${surat['id_pengajuan']}"),
      headers: {
        "Authorization": "Bearer ${widget.tokenRT}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "status": status,
        "catatan_rt": catatan ?? surat['catatan_rt'],
      }),
    );

    print("UPDATE STATUS CODE: ${response.statusCode}");
    print("UPDATE STATUS BODY: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        _suratList[index]['status'] = status;
        _suratList[index]['catatan_rt'] =
            catatan ?? surat['catatan_rt'] ?? '-';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui status surat")),
      );
    }
  }

  // ✅ Dialog input catatan
  Future<String?> _inputCatatanDialog() async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Catatan RT/RW"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Tambahkan catatan (opsional)",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // ✅ Helper untuk filter berdasarkan status
  Widget _buildSuratListByStatus(String status) {
    final filtered =
        _suratList.where((s) => s['status'] == status).toList();

    return SuratListWidget(
      suratList: filtered,

      // ✅ DETAIL
      onDetail: (surat) async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSuratRTPage(
              idPengajuan: surat['id_pengajuan'],
              token: widget.tokenRT,
              role: widget.role,
            ),
          ),
        );
        if (result == true) _fetchSurat();
      },

      // ✅ SETUJUI
      onSetujui: (surat) async {
        final index = _suratList.indexWhere(
            (item) => item['id_pengajuan'] == surat['id_pengajuan']);
        final catatan = await _inputCatatanDialog();
        await _updateStatusBackend(index, 'disetujui', catatan: catatan);
      },

      // ✅ SELESAI
      onSelesai: (surat) async {
        final index = _suratList.indexWhere(
            (item) => item['id_pengajuan'] == surat['id_pengajuan']);
        final catatan = await _inputCatatanDialog();
        await _updateStatusBackend(index, 'selesai', catatan: catatan);
      },

      // ✅ TOLAK
      onTolak: (surat) async {
        final index = _suratList.indexWhere(
            (item) => item['id_pengajuan'] == surat['id_pengajuan']);
        final catatan = await _inputCatatanDialog();
        await _updateStatusBackend(index, 'ditolak', catatan: catatan);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MainLayananLayoutRT(
        title: widget.role == "rw"
            ? "Layanan Surat RW"
            : "Layanan Surat RT",
        onBack: () => Navigator.pop(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading
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
                          _buildSuratListByStatus("pending"),
                          _buildSuratListByStatus("disetujui"),
                          _buildSuratListByStatus("selesai"),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}