import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_tes/constants/colors.dart';

class InfoCreateDialog extends StatefulWidget {
  final Function onCreated; // callback untuk refresh data

  const InfoCreateDialog({super.key, required this.onCreated});

  @override
  State<InfoCreateDialog> createState() => _InfoCreateDialogState();
}

class _InfoCreateDialogState extends State<InfoCreateDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleC = TextEditingController();
  final TextEditingController descC = TextEditingController();
  final TextEditingController dateC = TextEditingController();
  final TextEditingController dayC = TextEditingController();
  final TextEditingController timeC = TextEditingController();
  final TextEditingController locationC = TextEditingController();

  File? selectedImage;

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    dateC.dispose();
    dayC.dispose();
    timeC.dispose();
    locationC.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        selectedImage = File(img.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateC.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://127.0.0.1:8000/api/informasi"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["title"] = titleC.text;
    request.fields["description"] = descC.text;
    request.fields["date"] = dateC.text;
    request.fields["day"] = dayC.text;
    request.fields["time"] = timeC.text;
    request.fields["location"] = locationC.text;

    if (selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", selectedImage!.path),
      );
    }

    var response = await request.send();
    var result = await response.stream.bytesToString();
    final data = jsonDecode(result);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true); // sukses → refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(data["message"] ??
                "Gagal menambah data. Status: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Informasi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                  controller: titleC,
                  decoration: const InputDecoration(labelText: "Judul"),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(
                  controller: descC,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(
                controller: dateC,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                    labelText: "Tanggal (YYYY-MM-DD)",
                    suffixIcon: Icon(Icons.calendar_today)),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                  controller: dayC,
                  decoration: const InputDecoration(labelText: "Hari"),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(
                  controller: timeC,
                  decoration: const InputDecoration(labelText: "Jam"),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(
                  controller: locationC,
                  decoration: const InputDecoration(labelText: "Lokasi"),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          selectedImage == null
                              ? "Pilih gambar (optional)"
                              : "Gambar dipilih: ${selectedImage!.path.split('/').last}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text("Simpan",
                    style: TextStyle(color: Colors.white)),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// FUNCTION PEMBANTU UNTUK MEMBUKA DIALOG
// ====================================================================
Future<bool?> showCreateInformasiDialog(
    BuildContext context, Future<void> Function() onCreated) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => InfoCreateDialog(onCreated: onCreated),
  );
}