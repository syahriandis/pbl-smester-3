import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TambahSuratDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const TambahSuratDialog({super.key, required this.onSubmit});

  @override
  State<TambahSuratDialog> createState() => _TambahSuratDialogState();
}

class _TambahSuratDialogState extends State<TambahSuratDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _jenisSurat;
  String? _nama;
  String? _nik;
  String? _alamat;
  String? _keperluan;
  File? _dokumen;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih Sumber Gambar"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("Kamera"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("Galeri"),
          ),
        ],
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source);
      if (picked != null) setState(() => _dokumen = File(picked.path));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit({
        'jenisSurat': _jenisSurat,
        'nama': _nama,
        'nik': _nik,
        'alamat': _alamat,
        'keperluan': _keperluan,
        'dokumen': _dokumen?.path,
        'status': 'Proses',
        'tanggal': DateTime.now().toString().split(' ')[0],
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Jenis Surat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _jenisSurat,
                items: const [
                  DropdownMenuItem(
                    value: 'Surat Izin Keramaian',
                    child: Text('Surat Izin Keramaian'),
                  ),
                  DropdownMenuItem(
                    value: 'Surat Pindah',
                    child: Text('Surat Pindah'),
                  ),
                  DropdownMenuItem(value: 'SKTM', child: Text('SKTM')),
                ],
                onChanged: (val) => setState(() => _jenisSurat = val),
                validator: (val) => val == null ? 'Pilih jenis surat' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField('Nama Lengkap', (val) => _nama = val),
              _buildTextField('NIK', (val) => _nik = val),
              _buildTextField('Alamat', (val) => _alamat = val),
              _buildTextField(
                'Keperluan',
                (val) => _keperluan = val,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              const Text("Upload Dokumen (KTP/KK):"),
              const SizedBox(height: 5),
              OutlinedButton(
                onPressed: _pickFile,
                child: Text(
                  _dokumen == null
                      ? "Pilih File"
                      : _dokumen!.path.split('/').last,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Kirim Pengajuan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSaved, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (val) => val == null || val.isEmpty ? 'Harus diisi' : null,
        onSaved: onSaved,
      ),
    );
  }
}
