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
  final TextEditingController alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKeluarga();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
Future<void> _updateKeluargaDanAlamat() async {
  final token = await _getToken();
  final res = await http.put(
    Uri.parse("http://127.0.0.1:8000/api/profile"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "address": alamatController.text,
      "families": keluarga.map((f) => {
        "nama": f["nama"],
        "hubungan": f["hubungan"],
      }).toList(),
    }),
  );

  debugPrint("Update status: ${res.statusCode}, body: ${res.body}");
}
  Future<void> _loadKeluarga() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)["data"] as Map<String, dynamic>;
      final List<dynamic> family = data["families"] ?? [];

      setState(() {
        alamatController.text = (data["address"] ?? '').toString();
        keluarga = family.map((f) => {
              "id": f["id"],
              "nama": f["nama"] ?? '',
              "hubungan": f["hubungan"] ?? '',
            }).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }


  Future<void> _tambahKeluarga(String nama, String hubungan) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/family"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"nama": nama, "hubungan": hubungan}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final created = jsonDecode(res.body);
      setState(() {
        keluarga.add({
          "id": created["id"],
          "nama": created["nama"],
          "hubungan": created["hubungan"],
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anggota keluarga berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menambah anggota: ${res.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
      Future<void> _hapusKeluarga(int id, int index) async {
        final token = await _getToken();
        final res = await http.delete(
          Uri.parse("http://127.0.0.1:8000/api/family/$id"),
          headers: {"Authorization": "Bearer $token"},
        );

        if (res.statusCode == 200) {
          setState(() {
            keluarga.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Anggota keluarga berhasil dihapus"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus: ${res.body}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
  void _showTambahDialog() {
    namaController.clear();
    hubunganController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Tambah Anggota Keluarga"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: null,
                decoration: const InputDecoration(
                  labelText: "Hubungan",
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Anak", child: Text("Anak")),
                  DropdownMenuItem(value: "Ibu", child: Text("Ibu")),
                  DropdownMenuItem(value: "Ayah", child: Text("Ayah")),
                ],
                onChanged: (value) {
                  hubunganController.text = value ?? '';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (namaController.text.isEmpty || hubunganController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nama dan hubungan harus diisi"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                await _tambahKeluarga(namaController.text, hubunganController.text);
                Navigator.pop(context);
              },
              child: const Text("Tambah", style: TextStyle(color: whiteColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Edit Keluarga", style: TextStyle(color: whiteColor)),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: alamatController,
                    decoration: const InputDecoration(
                      labelText: "Alamat",
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Isi alamat rumah dengan jelas agar data keluarga tersimpan dengan benar.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: keluarga.isEmpty
                        ? const Center(child: Text("Belum ada anggota keluarga"))
                        : ListView.builder(
                            itemCount: keluarga.length,
                            itemBuilder: (context, index) {
                              final item = keluarga[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: secondaryColor,
                                    child: const Icon(Icons.person, color: whiteColor),
                                  ),
                                  title: Text(
                                    (item["nama"] ?? '').toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text((item["hubungan"] ?? '').toString()),
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
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                                ),
                              );
                            },
                          ),
                  ),

                  const Text(
                    "Gunakan tombol di bawah untuk menambah anggota keluarga atau menyimpan perubahan.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _showTambahDialog,
                          icon: const Icon(Icons.add, color: whiteColor),
                          label: const Text("Tambah", style: TextStyle(color: whiteColor)),
                        ),
                      ),
                      const SizedBox(width: 12),
                     Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setState(() => isSaving = true);
                                try {
                                  await _updateKeluargaDanAlamat();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Data keluarga & alamat berhasil disimpan"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context, true);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Gagal menyimpan: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => isSaving = false);
                                }
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
                            : const Icon(Icons.save, color: whiteColor),
                        label: Text(
                          isSaving ? "Menyimpan..." : "Simpan",
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                    ),

                    ],
                  ),
                ],
              ),
            ),
    );
  }
}