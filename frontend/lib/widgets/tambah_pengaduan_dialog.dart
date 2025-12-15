import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TambahPengaduanDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const TambahPengaduanDialog({super.key, required this.onSubmit});

  @override
  _TambahPengaduanDialogState createState() => _TambahPengaduanDialogState();
}

class _TambahPengaduanDialogState extends State<TambahPengaduanDialog> {
  final _deskripsiController = TextEditingController();
  String? _selectedKategori;
  final String _status = 'Pending';
  File? _image;

  final List<String> _kategoriList = [
    'Kerusakan',
    'Kebersihan',
    'Keamanan',
    'Pelayanan',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // Pilih dari galeri
    if (image != null) {
      setState(() {
        _image = File(image.path); // Menyimpan path gambar yang dipilih
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Pengaduan'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kategori Pengaduan'),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              value: _selectedKategori,
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem(value: kategori, child: Text(kategori));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKategori = value;
                });
              },
              hint: const Text('Pilih kategori'),
            ),
            const SizedBox(height: 10),
            const Text('Deskripsi Pengaduan'),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Deskripsi pengaduan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _pickImage, child: const Text('Pilih Foto')),
            const SizedBox(height: 10),
            _image != null
                ? Image.file(_image!) // Menampilkan gambar yang dipilih
                : const Text('Belum ada foto yang dipilih'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_selectedKategori == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kategori harus dipilih')),
              );
            } else if (_deskripsiController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deskripsi tidak boleh kosong')),
              );
            } else {
              final pengaduan = {
                'kategori': _selectedKategori,
                'deskripsi': _deskripsiController.text,
                'status': _status,
                'tanggal': DateTime.now().toString(),
                'foto': _image, // Menyimpan foto yang di-upload
              };
              widget.onSubmit(pengaduan);
              Navigator.pop(context);
            }
          },
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}
