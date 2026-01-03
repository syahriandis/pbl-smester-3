import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditKeluargaPage extends StatefulWidget {
  const EditKeluargaPage({super.key});

  @override
  State<EditKeluargaPage> createState() => _EditKeluargaPageState();
}

class _EditKeluargaPageState extends State<EditKeluargaPage> {
  List<Map<String, dynamic>> keluarga = [];
  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController hubunganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKeluarga();
  }

  @override
  void dispose() {
    namaController.dispose();
    hubunganController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadKeluarga() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final res = await http.get(
        Uri.parse("http://localhost:8000/api/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      debugPrint("Load keluarga status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)["data"] as Map<String, dynamic>;
        final List<dynamic> family = data["families"] ?? [];

        if (mounted) {
          setState(() {
            keluarga = family.map((f) => {
              "id": f["id"],
              "nama": f["nama"] ?? '',
              "hubungan": f["hubungan"] ?? '',
            }).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception("Gagal memuat data: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading keluarga: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _tambahKeluarga(String nama, String hubungan) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final res = await http.post(
        Uri.parse("http://localhost:8000/api/family"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"nama": nama, "hubungan": hubungan}),
      );

      debugPrint("Tambah keluarga status: ${res.statusCode}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final created = jsonDecode(res.body);
        
        if (mounted) {
          setState(() {
            keluarga.add({
              "id": created["id"] ?? created["data"]?["id"],
              "nama": nama,
              "hubungan": hubungan,
            });
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Anggota keluarga berhasil ditambahkan"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Reload data untuk sinkronisasi
          await _loadKeluarga();
        }
      } else {
        throw Exception("Gagal menambah anggota: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error tambah keluarga: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menambah anggota: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _hapusKeluarga(int id, int index) async {
    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus anggota keluarga ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: whiteColor)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final res = await http.delete(
        Uri.parse("http://localhost:8000/api/family/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      debugPrint("Hapus keluarga status: ${res.statusCode}");

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            keluarga.removeAt(index);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Anggota keluarga berhasil dihapus"),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Reload data untuk sinkronisasi
          await _loadKeluarga();
        }
      } else {
        throw Exception("Gagal menghapus: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error hapus keluarga: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTambahDialog() {
    namaController.clear();
    hubunganController.text = '';
    String? selectedHubungan;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.family_restroom, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Tambah Anggota Keluarga",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        hintText: "Masukkan nama lengkap",
                        prefixIcon: const Icon(Icons.person, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedHubungan,
                      decoration: InputDecoration(
                        labelText: "Hubungan Keluarga",
                        hintText: "Pilih hubungan",
                        prefixIcon: const Icon(Icons.people, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Anak", child: Text("Anak")),
                        DropdownMenuItem(value: "Ibu", child: Text("Ibu")),
                        DropdownMenuItem(value: "Ayah", child: Text("Ayah")),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedHubungan = value;
                          hubunganController.text = value ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: greyColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    if (namaController.text.trim().isEmpty || 
                        hubunganController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nama dan hubungan harus diisi"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    Navigator.pop(context);
                    await _tambahKeluarga(
                      namaController.text.trim(), 
                      hubunganController.text.trim()
                    );
                  },
                  child: const Text(
                    "Tambah",
                    style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Edit Keluarga",
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text("Memuat data keluarga..."),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Kelola data anggota keluarga Anda",
                              style: TextStyle(
                                color: primaryColor.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Anggota Keluarga (${keluarga.length})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showTambahDialog,
                          icon: const Icon(Icons.add_circle, size: 20),
                          label: const Text("Tambah"),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // List Keluarga
                    Expanded(
                      child: keluarga.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.family_restroom,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Belum ada anggota keluarga",
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Tap tombol Tambah untuk menambahkan",
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: keluarga.length,
                              itemBuilder: (context, index) {
                                final item = keluarga[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          primaryColor.withOpacity(0.02),
                                        ],
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [primaryColor, secondaryColor],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: whiteColor,
                                          size: 28,
                                        ),
                                      ),
                                      title: Text(
                                        item["nama"]?.toString() ?? 'Nama tidak tersedia',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: secondaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item["hubungan"]?.toString() ?? 'Hubungan tidak tersedia',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: secondaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () async {
                                          final id = item["id"];
                                          if (id != null) {
                                            await _hapusKeluarga(id, index);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Data keluarga tidak valid"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red,
                                        iconSize: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom Button
                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 3,
                          ),
                          onPressed: isSaving
                              ? null
                              : () {
                                  Navigator.pop(context, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Data keluarga berhasil disimpan"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: whiteColor,
                                  ),
                                )
                              : const Icon(Icons.check_circle, color: whiteColor),
                          label: Text(
                            isSaving ? "Menyimpan..." : "Selesai",
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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