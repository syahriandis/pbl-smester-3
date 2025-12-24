import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

Future<bool?> showInfoDetailDialogRT({
  required BuildContext context,
  required String token,
  required Map<String, dynamic> info,
  required Future<void> Function(int id) onDelete,
}) async {
  final titleController = TextEditingController(text: info["title"] ?? "");
  final locationController = TextEditingController(text: info["location"] ?? "");
  final descController = TextEditingController(text: info["description"] ?? "");
  File? selectedImage;
  bool isSubmitting = false;

  final image = info["image"] ?? "";
  final imageUrl = image.isNotEmpty ? "http://127.0.0.1:8000/storage/$image" : null;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Detail Informasi"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Lokasi", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => selectedImage = File(picked.path));
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Ganti Gambar"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedImage != null ? selectedImage!.path.split('/').last : "Tidak ada gambar baru",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tutup")),
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Yakin ingin menghapus informasi ini?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Hapus"),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await onDelete(info["id"]);
                  if (context.mounted) Navigator.pop(context, true);
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
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
                        final uri = Uri.parse("http://127.0.0.1:8000/api/informasi/${info["id"]}");
                        final request = http.MultipartRequest("POST", uri)
                          ..headers['Authorization'] = "Bearer $token"
                          ..fields['title'] = titleController.text.trim()
                          ..fields['location'] = locationController.text.trim()
                          ..fields['description'] = descController.text.trim()
                          ..fields['_method'] = 'PUT'; // Laravel method spoofing

                        if (selectedImage != null) {
                          request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
                        }

                        final response = await request.send();
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Informasi berhasil diupdate")),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal update informasi (${response.statusCode})")),
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
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Simpan Perubahan"),
            ),
          ],
        ),
      );
    },
  );
}