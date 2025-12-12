import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:login_tes/widgets/main_layanan_layout_rt.dart';
import 'package:login_tes/widgets/surat_list_widget.dart';

class LayananSuratPageRT extends StatefulWidget {
  final String tokenRT; 
  final String role;// ✅ token dikirim dari login RT

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

  // ✅ Ambil data dari backend
  Future<void> _fetchSurat() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/rt/surat"),
        headers: {
          "Authorization": "Bearer ${widget.tokenRT}",
          "Accept": "application/json",
        },
      );

      print("FETCH STATUS: ${response.statusCode}");
      print("FETCH BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];

        setState(() {
          _suratList = List<Map<String, dynamic>>.from(data.map((s) {
            return {
              'id_pengajuan': s['id_pengajuan'],
              'jenisSurat': s['jenis_surat']['nama_jenis_surat'],
              'nama': s['user']['name'],
              'deskripsi': s['catatan_rt'] ?? '-',
              'lokasi': 'Tidak ada lokasi',
              'status': s['status'],
              'detail': s['data_final']?.toString() ?? '-',
              'foto': null,
            };
          }));

          _loading = false;
        });
      } else {
        _loading = false;
      }
    } catch (e) {
      print("Error fetch surat: $e");
      setState(() => _loading = false);
    }
  }

  // ✅ Update status ke backend
  Future<void> _updateStatusBackend(int index, String status) async {
    final surat = _suratList[index];

    final response = await http.put(
      Uri.parse("http://127.0.0.1:8000/api/rt/surat/${surat['id_pengajuan']}"),
      headers: {
        "Authorization": "Bearer ${widget.tokenRT}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "status": status,
        "catatan_rt": surat['deskripsi'],
        "data_final": surat['detail'],
      }),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        _suratList[index]['status'] = status;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui status surat")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayoutRT(
      title: 'Layanan Surat RT',
      onBack: () => Navigator.pop(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SuratListWidget(
                      suratList: _suratList,

                      // ✅ Detail
                      onDetail: (surat) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(surat['jenisSurat']),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Nama: ${surat['nama']}'),
                                  Text('Deskripsi: ${surat['detail']}'),
                                  Text('Lokasi: ${surat['lokasi']}'),
                                  Text('Status: ${surat['status']}'),
                                  const SizedBox(height: 10),
                                  if (surat['foto'] != null)
                                    Image.asset(surat['foto'], height: 150),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      // ✅ Setujui → diproses
                      onSetujui: (surat) {
                        final index = _suratList.indexOf(surat);
                        _updateStatusBackend(index, 'diproses');
                      },

                      // ✅ Tolak → pending
                      onTolak: (surat) {
                        final index = _suratList.indexOf(surat);
                        _updateStatusBackend(index, 'pending');
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}