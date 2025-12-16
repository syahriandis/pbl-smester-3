import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahSuratDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final String token;

  const TambahSuratDialog({
    super.key,
    required this.onSubmit,
    required this.token,
  });

  @override
  State<TambahSuratDialog> createState() => _TambahSuratDialogState();
}

class _TambahSuratDialogState extends State<TambahSuratDialog> {
  List jenisSuratList = [];
  int? selectedJenis;
  final TextEditingController keperluanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJenisSurat();
  }

  Future<void> _fetchJenisSurat() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/jenis-surat'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Ajukan Surat",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
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
                  onChanged: (value) {
                    setState(() {
                      selectedJenis = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ✅ Catatan merah
                const Text(
                  "* Isi keperluan (opsional)",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                // ✅ Field keperluan
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedJenis != null) {
              widget.onSubmit({
                'id_jenis_surat': selectedJenis,
                'keperluan': keperluanController.text, // ✅ dikirim ke backend
              });
            }
          },
          child: const Text("Ajukan"),
        ),
      ],
    );
  }
}