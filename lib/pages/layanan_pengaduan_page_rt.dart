import 'package:flutter/material.dart';
import 'package:login_tes/widgets/card_widget_pengaduan.dart'; // Pastikan ini sudah diimpor
import 'package:login_tes/widgets/main_layanan_layout_rt.dart';

class LayananPengaduanPageRT extends StatefulWidget {
  LayananPengaduanPageRT({super.key});

  @override
  _LayananPengaduanPageRTState createState() => _LayananPengaduanPageRTState();
}

class _LayananPengaduanPageRTState extends State<LayananPengaduanPageRT> {
  final List<Map<String, dynamic>> _pengaduanList = [
    {
      'nama': 'Raymond Jefri Silalahi',
      'deskripsi': 'Sampah dipinggir jembatan numpuk.',
      'lokasi': 'Masjid al Ikhlas Bengkong, Jl. Sudirman',
      'status': 'Menunggu',
      'image': 'assets/images/maulidd.jpg',
    },
  ];

  // Daftar history pengaduan
  final List<Map<String, dynamic>> _historyPengaduanList = [];

  // Fungsi untuk memperbarui status pengaduan dan memindahkannya ke history
  void _updateStatus(int index, String status) {
    setState(() {
      // Menambahkan pengaduan yang diproses ke history
      _historyPengaduanList.add({..._pengaduanList[index], 'status': status});
      // Menghapus pengaduan yang sudah diproses dari daftar aktif
      _pengaduanList.removeAt(index);
    });
  }

  // Fungsi untuk menampilkan halaman history pengaduan
  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('History Pengaduan'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Tentukan tinggi dialog
            child: ListView.builder(
              itemCount: _historyPengaduanList.length,
              itemBuilder: (context, index) {
                final history = _historyPengaduanList[index];
                return ListTile(
                  leading: Image.asset(
                    history['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(history['nama']),
                  subtitle: Text(history['deskripsi']),
                  trailing: Text(history['status']),
                );
              },
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayoutRT(
      title: "Layanan Pengaduan RT",
      onBack: () => Navigator.pop(context),
      body: Column(
        children: [
          // AppBar dengan tombol History
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Pengaduan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: _showHistory, // Menampilkan history saat diklik
                  tooltip: 'Lihat History Pengaduan',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Pengaduan Aktif
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: _pengaduanList.length,
              itemBuilder: (context, index) {
                final pengaduan = _pengaduanList[index];
                return CardWidgetPengaduan(
                  imagePath: pengaduan['image'],
                  nama: pengaduan['nama'],
                  deskripsi: pengaduan['deskripsi'],
                  lokasi: pengaduan['lokasi'],
                  status: pengaduan['status'],
                  onTolak: () {
                    _updateStatus(index, 'Ditolak');
                  },
                  onTerima: () {
                    _updateStatus(index, 'Disetujui');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
