import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahSuratDialog extends StatefulWidget {
  final String token;

  const TambahSuratDialog({
    super.key,
    required this.token,
  });

  @override
  State<TambahSuratDialog> createState() => _TambahSuratDialogState();
}

class _TambahSuratDialogState extends State<TambahSuratDialog> {
  List jenisSuratList = [];
  int? selectedJenis;
  final TextEditingController keperluanController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchJenisSurat();
  }

  Future<void> _fetchJenisSurat() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/jenis-surat'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        jenisSuratList = data;
        if (jenisSuratList.isNotEmpty) {
          selectedJenis = jenisSuratList.first['id'];
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil jenis surat")),
      );
    }
  }

  Future<void> _ajukanSurat() async {
    if (selectedJenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jenis surat belum dipilih"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final res = await http.post(
      Uri.parse("http://localhost:8000/api/warga/surat"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id_jenis_surat": selectedJenis,
        "keperluan": keperluanController.text,
      }),
    );

    setState(() => isSubmitting = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Surat berhasil diajukan"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengajukan surat: ${res.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Ajukan Surat", style: TextStyle(fontWeight: FontWeight.bold)),
      content: jenisSuratList.isEmpty
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Jenis Surat",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedJenis,
                  items: jenisSuratList.map<DropdownMenuItem<int>>((jenis) {
                    return DropdownMenuItem<int>(
                      value: jenis['id'],
                      child: Text(jenis['nama_jenis_surat']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedJenis = value),
                ),
                const SizedBox(height: 16),
                const Text("* Isi keperluan (opsional)", style: TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: keperluanController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Contoh: Untuk keperluan administrasi",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: isSubmitting ? null : _ajukanSurat,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Ajukan"),
        ),
      ],
    );
  }
}