import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

Future<bool?> showCreateInformasiDialog({
  required BuildContext context,
  required String token,
}) async {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();
  
  // Auto-fill dengan tanggal & waktu sekarang
  final now = DateTime.now();
  final dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(now),
  );
  final timeController = TextEditingController(
    text: DateFormat('HH:mm').format(now),
  );
  final dayController = TextEditingController(
    text: _getDayName(now),
  );

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
            child: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Judul (Required)
                  _buildTextField(titleController, "Judul *", Icons.title),
                  const SizedBox(height: 12),
                  
                  // Row: Date & Time
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
                            child: _buildTextField(dateController, "Tanggal", Icons.calendar_today),
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
                            child: _buildTextField(timeController, "Waktu", Icons.access_time),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Hari (Auto-filled)
                  _buildTextField(dayController, "Hari", Icons.event, readOnly: true),
                  const SizedBox(height: 12),
                  
                  // Lokasi (Required sesuai validasi backend)
                  _buildTextField(locationController, "Lokasi *", Icons.place),
                  const SizedBox(height: 12),
                  
                  // Deskripsi
                  _buildTextField(descController, "Deskripsi", Icons.description, maxLines: 3),
                  const SizedBox(height: 16),
                  
                  // Image Upload
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
                    label: Text(fileName != null ? "Ganti Gambar" : "Pilih Gambar"),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fileName ?? "Belum ada gambar dipilih",
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Image Preview
                  if (kIsWeb && selectedImageBytes != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(selectedImageBytes!, height: 160, fit: BoxFit.cover),
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
                          child: Image.file(selectedImageFile!, height: 160, fit: BoxFit.cover),
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
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      // Validasi sesuai backend
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
                        final uri = Uri.parse("http://localhost:8000/api/informasi");

                        final request = http.MultipartRequest("POST", uri)
                          ..headers['Authorization'] = "Bearer $token"
                          ..headers['Accept'] = "application/json"
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

                        print("🚀 Request: ${uri.toString()}");
                        print("📝 Fields: ${request.fields}");

                        final response = await request.send();
                        final responseBody = await response.stream.bytesToString();
                        
                        print("📥 Status: ${response.statusCode}");
                        print("📄 Body: $responseBody");

                        if (response.statusCode == 201 || response.statusCode == 200) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Informasi berhasil dibuat"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Gagal: $responseBody"),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print("❌ Error: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: Colors.red,
                            ),
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
        ),
      );
    },
  );
}

Widget _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  int maxLines = 1,
  bool readOnly = false,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade100,
    ),
  );
}

String _getDayName(DateTime date) {
  const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  return days[date.weekday % 7];
}