import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_tes/constants/colors.dart';

void showInfoEditDialog(
  BuildContext context,
  Map<String, dynamic> info,
  Function(Map<String, dynamic>) onEdited,
) {
  final titleC = TextEditingController(text: info['title'] ?? '');
  final descC = TextEditingController(text: info['description'] ?? '');
  final dateC = TextEditingController(text: info['date'] ?? '');
  final dayC = TextEditingController(text: info['day'] ?? '');
  final timeC = TextEditingController(text: info['time'] ?? '');
  final locationC = TextEditingController(text: info['location'] ?? '');

  File? selectedImage;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage = File(picked.path);
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Informasi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: titleC,
                decoration: const InputDecoration(
                  labelText: "Judul",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: descC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: dateC,
                decoration: const InputDecoration(
                  labelText: "Tanggal (YYYY-MM-DD)",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: dayC,
                decoration: const InputDecoration(
                  labelText: "Hari",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: timeC,
                decoration: const InputDecoration(
                  labelText: "Jam",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: locationC,
                decoration: const InputDecoration(
                  labelText: "Lokasi",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () async {
                  await pickImage();
                  (context as Element).markNeedsBuild();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      Text(
                        selectedImage == null ? "Pilih/Ubah Foto" : "Foto dipilih",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              if (selectedImage != null || (info['image'] != null && info['image'].toString().isNotEmpty)) ...[
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: selectedImage != null
                      ? Image.file(selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover)
                      : Image.network(
                          info['image'].toString().startsWith('http')
                              ? info['image']
                              : "http://127.0.0.1:8000/${info['image']}",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final updated = {
                          'title': titleC.text,
                          'description': descC.text,
                          'date': dateC.text,
                          'day': dayC.text,
                          'time': timeC.text,
                          'location': locationC.text,
                          'image': selectedImage?.path ?? info['image'],
                        };
                        Navigator.pop(context);
                        onEdited(updated);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Simpan Perubahan"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Batal"),
                    ),
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