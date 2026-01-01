import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';

// Ganti dengan path aktual di project kamu
import 'package:login_tes/widgets/info_create_dialog.dart';
import 'package:login_tes/widgets/info_detail_dialog_rt.dart';

class InformasiPageRT extends StatefulWidget {
  final String tokenRT;
  final String role;

  const InformasiPageRT({
    super.key,
    required this.tokenRT,
    required this.role,
  });

  @override
  State<InformasiPageRT> createState() => _InformasiPageRTState();
}

class _InformasiPageRTState extends State<InformasiPageRT> {
  List<Map<String, dynamic>> _listInformasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  Future<void> _loadInformasi() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/informasi'),
        headers: {'Authorization': 'Bearer ${widget.tokenRT}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _listInformasi = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal memuat informasi (${response.statusCode})");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error memuat informasi: $e")),
        );
      }
    }
  }

  Future<void> _deleteInformasi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/informasi/$id'),
        headers: {'Authorization': 'Bearer ${widget.tokenRT}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Informasi berhasil dihapus.")),
          );
        }
        _loadInformasi();
      } else {
        throw Exception("Gagal menghapus informasi (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error hapus informasi: $e")),
        );
      }
    }
  }

  void _navigateToAddInfo() async {
    final bool? refresh = await showCreateInformasiDialog(
      context: context,
      token: widget.tokenRT,
    );
    if (refresh == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informasi baru berhasil dibuat.")),
        );
      }
      _loadInformasi();
    }
  }

  void _openEditDialog(Map<String, dynamic> info) async {
    final bool? refresh = await showInfoDetailDialogRT(
      context: context,
      token: widget.tokenRT,
      info: info,
      onDelete: (id) async {
        await _deleteInformasi(id);
      },
    );
    if (refresh == true) {
      _loadInformasi();
    }
  }

  // ✅ Helper function untuk generate URL gambar
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Jika sudah full URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // ✅ Pakai endpoint API storage
    return 'http://127.0.0.1:8000/api/storage/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutRT(
      selectedIndex: 2,
      tokenRT: widget.tokenRT,
      role: widget.role,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final canManage = widget.role == "rt" || widget.role == "rw";

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 44),
                const Text(
                  "Informasi RT/RW",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar Informasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      if (canManage)
                        ElevatedButton.icon(
                          onPressed: _navigateToAddInfo,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            "Tambah",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List
                  Expanded(
                    child: _listInformasi.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Belum ada informasi.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loadInformasi,
                                  child: const Text("Muat Ulang"),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadInformasi,
                            child: ListView.builder(
                              itemCount: _listInformasi.length,
                              itemBuilder: (context, index) {
                                final info = _listInformasi[index];
                                final imagePath = info["image"] ?? "";
                                final imageUrl = _getImageUrl(imagePath); // ✅ Pakai helper function

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (imageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                height: 180,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              print('❌ Error loading image: $imageUrl');
                                              print('Error: $error');
                                              return Container(
                                                height: 180,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      "Gambar tidak tersedia",
                                                      style: TextStyle(color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 180,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Tidak ada gambar",
                                                style: TextStyle(color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              info["title"] ?? "",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.place,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  info["location"] ?? "-",
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(info["description"] ?? ""),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                if (canManage)
                                                  TextButton.icon(
                                                    onPressed: () => _openEditDialog(info),
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    label: const Text(
                                                      "Edit",
                                                      style: TextStyle(color: Colors.blue),
                                                    ),
                                                  ),
                                                if (canManage)
                                                  TextButton.icon(
                                                    onPressed: () =>
                                                        _confirmDelete(info["id"]),
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    label: const Text(
                                                      "Hapus",
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Informasi"),
        content: const Text("Yakin ingin menghapus informasi ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteInformasi(id);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}