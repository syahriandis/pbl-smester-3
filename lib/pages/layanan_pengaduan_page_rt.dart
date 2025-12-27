import 'package:flutter/material.dart';
import 'package:login_tes/widgets/card_widget_pengaduan.dart';
import 'package:login_tes/widgets/main_layanan_layout_rt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LayananPengaduanPageRT extends StatefulWidget {
  final String tokenRT;
  final String role;

  const LayananPengaduanPageRT({
    super.key,
    required this.tokenRT,
    required this.role,
  });

  @override
  _LayananPengaduanPageRTState createState() => _LayananPengaduanPageRTState();
}

class _LayananPengaduanPageRTState extends State<LayananPengaduanPageRT> {
  List<Map<String, dynamic>> _pengaduanList = [];
  List<Map<String, dynamic>> _historyPengaduanList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/rt/pengaduan"),
        headers: {"Authorization": "Bearer ${widget.tokenRT}"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pengaduanList = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int index, String action) async {
    final pengaduan = _pengaduanList[index];
    try {
      String url =
          "http://localhost:8000/api/rt/pengaduan/${pengaduan['id']}/$action";
      final response = await http.put(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.tokenRT}"},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Pengaduan $action")));
        setState(() {
          _historyPengaduanList.add({
            ...pengaduan,
            'status': action == 'approve' ? 'Disetujui' : 'Ditolak'
          });
          _pengaduanList.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal update status")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.history, color: Colors.blue),
            SizedBox(width: 8),
            Text('History Pengaduan',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _historyPengaduanList.isEmpty
              ? const Center(
                  child: Text("Belum ada history",
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: _historyPengaduanList.length,
                  itemBuilder: (context, index) {
                    final history = _historyPengaduanList[index];
                    final status = history['status'] ?? '';
                    final statusColor =
                        status == 'Disetujui' ? Colors.green : Colors.red;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.2),
                          child: Icon(
                            status == 'Disetujui'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: statusColor,
                          ),
                        ),
                        title: Text(
                          history['title'] ?? history['nama'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(history['description'] ??
                                history['deskripsi'] ??
                                ''),
                            const SizedBox(height: 4),
                            Text(
                              "Lokasi: ${history['location'] ?? history['lokasi'] ?? '-'}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(status),
                          backgroundColor: statusColor.withOpacity(0.1),
                          labelStyle: TextStyle(color: statusColor),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayoutRT(
      title: "Layanan Pengaduan RT",
      onBack: () => Navigator.pop(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daftar Pengaduan",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                          icon: const Icon(Icons.history),
                          onPressed: _showHistory),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _pengaduanList.length,
                    itemBuilder: (context, index) {
                      final pengaduan = _pengaduanList[index];
                      return CardWidgetPengaduan(
                        imagePath: pengaduan['image'] ?? '',
                        nama: pengaduan['title'] ?? pengaduan['nama'],
                        deskripsi:
                            pengaduan['description'] ?? pengaduan['deskripsi'],
                        lokasi: pengaduan['location'] ?? pengaduan['lokasi'],
                        status: pengaduan['status'],
                        onTolak: () => _updateStatus(index, 'reject'),
                        onTerima: () => _updateStatus(index, 'approve'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}