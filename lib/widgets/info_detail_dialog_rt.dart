import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

Future<bool?> showInfoDetailDialogRT({
  required BuildContext context,
  required String token,
  required Map<String, dynamic> info,
  required Future<void> Function(int id) onDelete,
}) async {
  final titleController = TextEditingController(text: info["title"] ?? "");
  final locationController = TextEditingController(text: info["location"] ?? "");
  final descController = TextEditingController(text: info["description"] ?? "");
  final dateController = TextEditingController(text: info["date"] ?? "");
  final timeController = TextEditingController(text: info["time"] ?? "");
  final dayController = TextEditingController(text: info["day"] ?? "");

  File? selectedImageFile;
  Uint8List? selectedImageBytes;
  String? fileName;
  bool isSubmitting = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          String _getImageUrl(String? imagePath) {
            if (imagePath == null || imagePath.isEmpty) return '';
            
            if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
              return imagePath;
            }
            
            // ✅ Pakai endpoint API
            return 'http://127.0.0.1:8000/api/storage/$imagePath';
          }

          final imageUrl = _getImageUrl(info["image"]);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text("Detail Informasi", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gambar Preview
                    if (kIsWeb && selectedImageBytes != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              selectedImageBytes!,
                              height: 160,
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
                      )
                    else if (!kIsWeb && selectedImageFile != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImageFile!,
                              height: 160,
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
                                  selectedImageFile = null;
                                  fileName = null;
                                });
                              },
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              style: IconButton.styleFrom(backgroundColor: Colors.white),
                            ),
                          ),
                        ],
                      )
                    else if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 160,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Text("Gambar tidak tersedia"),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),

                    // Judul
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Judul *",
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                                dayController.text = _getDayName(picked);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: dateController,
                                decoration: const InputDecoration(
                                  labelText: "Tanggal",
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: timeController,
                                decoration: const InputDecoration(
                                  labelText: "Waktu",
                                  prefixIcon: Icon(Icons.access_time),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Hari (read-only)
                    TextField(
                      controller: dayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Hari",
                        prefixIcon: const Icon(Icons.event),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lokasi
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Lokasi *",
                        prefixIcon: Icon(Icons.place),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi",
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Button Ganti Gambar
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
                      label: Text(fileName != null ? "Ganti Gambar" : "Pilih Gambar Baru"),
                    ),
                    if (fileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        fileName!,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Tutup"),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Konfirmasi"),
                      content: const Text("Yakin ingin menghapus informasi ini?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        // Validasi
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Judul wajib diisi")),
                          );
                          return;
                        }
                        if (locationController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Lokasi wajib diisi")),
                          );
                          return;
                        }

                        setState(() => isSubmitting = true);
                        
                        try {
                          final uri = Uri.parse("http://127.0.0.1:8000/api/informasi/${info["id"]}");
                          final request = http.MultipartRequest("POST", uri)
                            ..headers['Authorization'] = "Bearer $token"
                            ..headers['Accept'] = "application/json"
                            ..fields['_method'] = 'PUT'
                            ..fields['title'] = titleController.text.trim()
                            ..fields['date'] = dateController.text
                            ..fields['time'] = timeController.text
                            ..fields['day'] = dayController.text
                            ..fields['location'] = locationController.text.trim()
                            ..fields['description'] = descController.text.trim();

                          // Handle image upload
                          if (kIsWeb && selectedImageBytes != null) {
                            String contentTypeStr = 'image/jpeg';
                            if (fileName != null) {
                              if (fileName!.toLowerCase().endsWith('.png')) {
                                contentTypeStr = 'image/png';
                              } else if (fileName!.toLowerCase().endsWith('.jpg') || 
                                         fileName!.toLowerCase().endsWith('.jpeg')) {
                                contentTypeStr = 'image/jpeg';
                              }
                            }
                            
                            final parts = contentTypeStr.split('/');
                            request.files.add(http.MultipartFile.fromBytes(
                              'image',
                              selectedImageBytes!,
                              filename: fileName ?? "upload.jpg",
                              contentType: MediaType(parts[0], parts[1]),
                            ));
                          } else if (!kIsWeb && selectedImageFile != null) {
                            request.files.add(await http.MultipartFile.fromPath(
                              'image',
                              selectedImageFile!.path,
                            ));
                          }

                          final response = await request.send();
                          final responseBody = await response.stream.bytesToString();

                          print("📥 Update Status: ${response.statusCode}");
                          print("📄 Body: $responseBody");

                          if (response.statusCode == 200) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Informasi berhasil diupdate"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal update: $responseBody"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print("❌ Error: $e");
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isSubmitting = false);
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Simpan"),
              ),
            ],
          );
        },
      );
    },
  );
}

String _getDayName(DateTime date) {
  const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  return days[date.weekday % 7];
}