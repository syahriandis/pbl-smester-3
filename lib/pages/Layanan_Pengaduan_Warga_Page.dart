import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_security.dart';

class LayananPengaduanWargaPage extends StatefulWidget {
  const LayananPengaduanWargaPage({super.key});

  @override
  State<LayananPengaduanWargaPage> createState() =>
      _LayananPengaduanWargaPageState();
}

class _LayananPengaduanWargaPageState
    extends State<LayananPengaduanWargaPage> {
  File? selectedImage;
  final TextEditingController feedbackController = TextEditingController();

  final List<Map<String, dynamic>> _pengaduanWargaList = [
    {
      'kategori': 'Kerusakan',
      'deskripsi': 'Lampu taman rusak di RT 03.',
      'status': 'Diproses',
      'tanggal': '2025-11-05 20:00',
      'feedback': '',
      'foto': null,
    },
    {
      'kategori': 'Kebersihan',
      'deskripsi': 'Sampah menumpuk di jalan utama.',
      'status': 'Diproses',
      'tanggal': '2025-11-04 18:30',
      'feedback': '',
      'foto': null,
    },
    {
      'kategori': 'Keamanan',
      'deskripsi': 'Ada anak-anak bermain di atap rumah kosong.',
      'status': 'Selesai',
      'tanggal': '2025-11-03 10:15',
      'feedback': 'Sudah dicek dan aman.',
      'foto': null,
    },
    {
      'kategori': 'Keamanan',
      'deskripsi': 'Pagar rusak di lingkungan RT 02.',
      'status': 'Batal',
      'tanggal': '2025-11-02 15:00',
      'feedback': '',
      'foto': null,
    },
  ];

  // =========================================================
  // VALIDASI FOTO: hanya JPG/JPEG/PNG dan maksimal 5MB
  // =========================================================
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);

      // Ambil ekstensi file
      final extension = picked.name.split('.').last.toLowerCase();

      // Validasi format file
      if (extension != "jpg" &&
          extension != "jpeg" &&
          extension != "png") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Format foto harus JPG, JPEG, atau PNG"),
          ),
        );
        return;
      }

      // Validasi ukuran file maksimal 5MB
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5 MB

      if (fileSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ukuran foto maksimal 5 MB"),
          ),
        );
        return;
      }

      setState(() {
        selectedImage = file;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto berhasil dipilih"),
        ),
      );
    }
  }

  // =========================================================

  void _ubahStatusPengaduan(Map<String, dynamic> pengaduan, String statusBaru) {
    setState(() {
      pengaduan['status'] = statusBaru;
    });
    Navigator.pop(context);
  }

  void _hapusPengaduan(Map<String, dynamic> pengaduan) {
    setState(() {
      _pengaduanWargaList.remove(pengaduan);
    });
  }

  void _showDetailPengaduan(Map<String, dynamic> pengaduan) {
    String dropdownValue = pengaduan['status'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pengaduan['kategori']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi: ${pengaduan['deskripsi']}'),
                const SizedBox(height: 8),
                Text('Tanggal: ${pengaduan['tanggal']}'),
                const SizedBox(height: 16),

                // Jika masih diproses
                if (pengaduan['status'] == 'Diproses') ...[
                  const Text(
                    "Kirim Feedback ke Warga:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan feedback...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Lampirkan Foto (opsional):",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Pilih Foto"),
                      ),
                      const SizedBox(width: 12),
                      if (selectedImage != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),

                  // 🔥 KETERANGAN FORMAT & UKURAN
                  const SizedBox(height: 6),
                  const Text(
                    "Format foto: JPG, JPEG, PNG — Maksimal ukuran 5 MB",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ubah Status Pengaduan:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  DropdownButton<String>(
                    value: dropdownValue,
                    isExpanded: true,
                    items: <String>['Diproses', 'Selesai', 'Batal']
                        .map((value) {
                      Color textColor;
                      switch (value) {
                        case 'Selesai':
                          textColor = Colors.green;
                          break;
                        case 'Diproses':
                          textColor = Colors.orange;
                          break;
                        case 'Batal':
                          textColor = Colors.red;
                          break;
                        default:
                          textColor = Colors.black;
                      }

                      return DropdownMenuItem(
                        value: value,
                        child: Text(value, style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        dropdownValue = newValue;
                        _ubahStatusPengaduan(pengaduan, newValue);
                      }
                    },
                  ),
                ],

                // TAMPILAN RIWAYAT (Selesai/Batal)
                if (pengaduan['status'] != 'Diproses') ...[
                  const SizedBox(height: 20),
                  const Text("Feedback:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(pengaduan['feedback'].isEmpty
                      ? "Tidak ada feedback"
                      : pengaduan['feedback']),
                  const SizedBox(height: 16),

                  const Text("Foto:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),

                  if (pengaduan['foto'] != null)
                    Image.file(
                      File(pengaduan['foto']),
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  else
                    const Text("Tidak ada foto dilampirkan"),
                ],
              ],
            ),
          ),
          actions: [
            if (pengaduan['status'] == 'Diproses')
              TextButton(
                onPressed: () {
                  setState(() {
                    pengaduan['feedback'] = feedbackController.text;
                    pengaduan['foto'] = selectedImage?.path;
                  });

                  feedbackController.clear();
                  selectedImage = null;

                  Navigator.pop(context);
                },
                child: const Text('Kirim'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPengaduanList(
    List<Map<String, dynamic>> list, {
    bool isRiwayat = false,
  }) {
    if (list.isEmpty) {
      return const Center(child: Text('Tidak ada pengaduan.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final pengaduan = list[index];

        Color statusColor;
        switch (pengaduan['status']) {
          case 'Selesai':
            statusColor = Colors.green;
            break;
          case 'Diproses':
            statusColor = Colors.orange;
            break;
          case 'Batal':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.black;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pengaduan['kategori'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(pengaduan['deskripsi']),
                const SizedBox(height: 6),
                Text(
                  "Tanggal: ${pengaduan['tanggal']}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pengaduan['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _showDetailPengaduan(pengaduan),
                          child: const Text("Detail"),
                        ),
                        if (isRiwayat)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusPengaduan(pengaduan),
                          ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final riwayatList = _pengaduanWargaList
        .where((p) => p['status'] == 'Selesai' || p['status'] == 'Batal')
        .toList();

    final aktifList =
        _pengaduanWargaList.where((p) => p['status'] == 'Diproses').toList();

    return MainLayoutSecurity(
      selectedIndex: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pengaduan Warga',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: whiteColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: primaryColor,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: "Aktif"),
                          Tab(text: "Riwayat"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildPengaduanList(aktifList),
                            _buildPengaduanList(riwayatList, isRiwayat: true),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
