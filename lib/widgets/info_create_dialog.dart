import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<bool?> showCreateInformasiDialog({
  required BuildContext context,
  required String token,
}) async {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();

  File? selectedImageFile;
  Uint8List? selectedImageBytes;
  String? fileName;
  bool isSubmitting = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text("Tambah Informasi", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(titleController, "Judul", Icons.title),
                const SizedBox(height: 12),
                _buildTextField(locationController, "Lokasi", Icons.place),
                const SizedBox(height: 12),
                _buildTextField(descController, "Deskripsi", Icons.description, maxLines: 3),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (kIsWeb) {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null && result.files.single.bytes != null) {
                        setState(() {
                          selectedImageBytes = result.files.single.bytes!;
                          fileName = result.files.single.name;
                        });
                      }
                    } else {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          selectedImageFile = File(picked.path);
                          fileName = picked.name;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                ),
                const SizedBox(height: 8),
                Text(
                  fileName ?? "Belum ada gambar dipilih",
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (kIsWeb && selectedImageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(selectedImageBytes!, height: 160, fit: BoxFit.cover),
                  )
                else if (!kIsWeb && selectedImageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(selectedImageFile!, height: 160, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Judul wajib diisi")),
                        );
                        return;
                      }
                      setState(() => isSubmitting = true);
                      try {
                        final uri = Uri.parse(kIsWeb
                            ? "http://localhost:8000/api/informasi"
                            : "http://127.0.0.1:8000/api/informasi");

                        final request = http.MultipartRequest("POST", uri)
                          ..headers['Authorization'] = "Bearer $token"
                          ..fields['title'] = titleController.text.trim()
                          ..fields['location'] = locationController.text.trim()
                          ..fields['description'] = descController.text.trim();

                        if (kIsWeb && selectedImageBytes != null) {
                          request.files.add(http.MultipartFile.fromBytes(
                            'image',
                            selectedImageBytes!,
                            filename: fileName ?? "upload.jpg",
                            contentType: MediaType('image', 'jpeg'),
                          ));
                        } else if (!kIsWeb && selectedImageFile != null) {
                          request.files.add(await http.MultipartFile.fromPath(
                            'image',
                            selectedImageFile!.path,
                            contentType: MediaType('image', 'jpeg'),
                          ));
                        }

                        final response = await request.send();
                        if (response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Informasi berhasil dibuat")),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal membuat informasi (${response.statusCode})")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      } finally {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Simpan"),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon,
    {int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey.shade100,
    ),
  );
}