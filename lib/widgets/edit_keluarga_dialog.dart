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

  Future<void> _updateKeluargaDanAlamat() async {
    final token = await _getToken();

    final List<Map<String, dynamic>> families = keluarga.map((f) => {
      "nama": f["nama"],
      "hubungan": f["hubungan"],
    }).toList();

    await http.post(
      Uri.parse("http://127.0.0.1:8000/api/profile/update-family"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "address": alamatController.text,
        "families": families,
      }),
    );
  }

  void _tambahKeluarga() {
    namaController.clear();
    hubunganController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                setState(() {
                  keluarga.add({
                    "nama": namaController.text,
                    "hubungan": hubunganController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Tambah", style: TextStyle(color: whiteColor)),
            ),
          ],
        );
      },
    );
  }

  void _hapusKeluarga(int index) {
    setState(() {
      keluarga.removeAt(index);
    });
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
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: keluarga.length,
                      itemBuilder: (context, index) {
                        final item = keluarga[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.person, color: primaryColor),
                            title: Text(
                              item["nama"],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item["hubungan"]),
                            trailing: IconButton(
                              onPressed: () => _hapusKeluarga(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _updateKeluargaDanAlamat();
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(color: whiteColor, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _tambahKeluarga,
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}