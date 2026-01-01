import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
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

  showDialog(
    context: context,
    builder: (context) {
      File? selectedImage;
      Uint8List? selectedImageBytes;
      String? fileName;

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
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
                  selectedImage = File(picked.path);
                  fileName = picked.name;
                });
              }
            }
          }

          String _getImageUrl(String? imagePath) {
            if (imagePath == null || imagePath.isEmpty) return '';
            
            if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
              return imagePath;
            }
            
            return 'http://127.0.0.1:8000/api/storage/$imagePath';
          }

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
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: descC,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Deskripsi",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: dateC,
                    decoration: const InputDecoration(
                      labelText: "Tanggal (YYYY-MM-DD)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        dateC.text = date.toString().split(' ')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: dayC,
                    decoration: const InputDecoration(
                      labelText: "Hari",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: timeC,
                    decoration: const InputDecoration(
                      labelText: "Jam",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        timeC.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: locationC,
                    decoration: const InputDecoration(
                      labelText: "Lokasi",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Picker
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (selectedImage != null || selectedImageBytes != null)
                                ? "Foto dipilih: ${fileName ?? 'upload'}"
                                : "Pilih/Ubah Foto",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Image Preview
                  if (kIsWeb && selectedImageBytes != null) ...[
                    const SizedBox(height: 15),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            selectedImageBytes!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                selectedImageBytes = null;
                                fileName = null;
                              });
                            },
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            style: IconButton.styleFrom(backgroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ] else if (!kIsWeb && selectedImage != null) ...[
                    const SizedBox(height: 15),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                selectedImage = null;
                                fileName = null;
                              });
                            },
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            style: IconButton.styleFrom(backgroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ] else if (info['image'] != null && info['image'].toString().isNotEmpty) ...[
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _getImageUrl(info['image']),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Text("Gambar tidak tersedia"),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                              'image': selectedImage?.path ?? 
                                       (selectedImageBytes != null ? fileName : info['image']),
                              'imageBytes': selectedImageBytes,
                            };
                            Navigator.pop(context);
                            onEdited(updated);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Simpan"),
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
    },
  );
}