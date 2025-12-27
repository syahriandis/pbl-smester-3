import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_security.dart';

class LayananPengaduanSecurityPage extends StatefulWidget {
  final String token;
  final String role;

  const LayananPengaduanSecurityPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<LayananPengaduanSecurityPage> createState() =>
      _LayananPengaduanSecurityPageState();
}

class _LayananPengaduanSecurityPageState
    extends State<LayananPengaduanSecurityPage> {
  List<Map<String, dynamic>> _pengaduanList = [];
  bool _loading = true;
  File? selectedImage;
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/security/pengaduan"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pengaduanList = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Map<String, dynamic> pengaduan, String action,
      {String? feedback}) async {
    try {
      final url =
          "http://localhost:8000/api/security/pengaduan/${pengaduan['id']}/$action";

      final response = await http.put(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
        body: feedback != null ? {"feedback": feedback} : null,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aksi berhasil: $action")),
        );
        await _fetchPengaduan();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal aksi (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final extension = picked.name.split('.').last.toLowerCase();
      if (!["jpg", "jpeg", "png"].contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Format harus JPG/JPEG/PNG")),
        );
        return;
      }
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ukuran maksimal 5 MB")),
        );
        return;
      }
      setState(() => selectedImage = file);
    }
  }

  void _showDetailPengaduan(Map<String, dynamic> pengaduan) {
    final status = (pengaduan['status']?.toString().toLowerCase() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengaduan['title'] ?? pengaduan['kategori'] ?? 'Pengaduan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pengaduan['image'] != null &&
                  pengaduan['image'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "http://localhost:8000/${pengaduan['image']}",
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text("Deskripsi: ${pengaduan['description'] ?? '-'}"),
              const SizedBox(height: 8),
              Text("Lokasi: ${pengaduan['location'] ?? '-'}"),
              const SizedBox(height: 8),
              Text("Tanggal: ${pengaduan['created_at'] ?? '-'}"),
              const SizedBox(height: 16),
              Text("Status: ${pengaduan['status'] ?? '-'}"),
              const SizedBox(height: 16),

              if (status == 'approved') ...[
                const Text("Kirim Feedback:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Tulis feedback...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Foto"),
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      selectedImage!,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],

              if (pengaduan['feedback'] != null &&
                  pengaduan['feedback'].toString().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text("Feedback:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(pengaduan['feedback']),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          if (status == 'approved')
            TextButton(
              onPressed: () => _updateStatus(
                pengaduan,
                "feedback",
                feedback: feedbackController.text,
              ),
              child: const Text("Kirim Feedback"),
            ),
          if (status == 'in_progress')
            TextButton(
              onPressed: () => _updateStatus(pengaduan, "done"),
              child: const Text("Tandai Selesai"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaduanList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Text("Tidak ada pengaduan"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(p['title'] ?? p['kategori'] ?? '-'),
            subtitle: Text(p['description'] ?? '-'),
            trailing: Text(p['status'] ?? '-'),
            onTap: () => _showDetailPengaduan(p),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Normalisasi status ke lowercase untuk mencegah mismatch filter
    final normalizedList = _pengaduanList.map((p) {
      return {
        ...p,
        'status': p['status']?.toString().toLowerCase() ?? '',
      };
    }).toList();

    // Aktif = approved tanpa feedback
    final aktifList = normalizedList
        .where((p) =>
            p['status'] == 'approved' &&
            (p['feedback'] == null || p['feedback'].toString().isEmpty))
        .toList();

    // Riwayat = in_progress, done, rejected, atau approved + feedback
    final riwayatList = normalizedList
        .where((p) =>
            p['status'] == 'in_progress' ||
            p['status'] == 'done' ||
            p['status'] == 'rejected' ||
            (p['status'] == 'approved' &&
                p['feedback'] != null &&
                p['feedback'].toString().isNotEmpty))
        .toList();

    return MainLayoutSecurity(
      selectedIndex: 0,
      token: widget.token,
      role: widget.role,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: primaryColor,
                    child: const Text(
                      "Pengaduan Warga",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                        _buildPengaduanList(riwayatList),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}