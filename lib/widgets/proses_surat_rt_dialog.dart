import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProsesSuratRTDialog extends StatefulWidget {
  final Map surat;

  const ProsesSuratRTDialog({super.key, required this.surat});

  @override
  State<ProsesSuratRTDialog> createState() => _ProsesSuratRTDialogState();
}

class _ProsesSuratRTDialogState extends State<ProsesSuratRTDialog> {
  final TextEditingController catatanController = TextEditingController();
  final TextEditingController dataFinalController = TextEditingController();

  String status = "diproses";

  // TODO: ganti token dari login RT
  final String token = "TOKEN_RT_KAMU";

  @override
  void initState() {
    super.initState();

    // ✅ Isi field dari data backend
    catatanController.text = widget.surat["catatan_rt"] ?? "";

    // ✅ data_final adalah JSON → convert ke string
    final df = widget.surat["data_final"];
    dataFinalController.text = df is Map ? jsonEncode(df) : (df?.toString() ?? "");

    status = widget.surat["status"] ?? "diproses";
  }

  Future<void> simpan() async {
    final int id = widget.surat['id_pengajuan'];

    final Map<String, dynamic> payload = {
      "status": status,
      "catatan_rt": catatanController.text,
      "data_final": {
        "isi": dataFinalController.text,
      },
    };

    final response = await http.put(
      Uri.parse("http://127.0.0.1:8000/api/rt/surat/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // ✅ return true agar list refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Proses Surat"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            value: status,
            items: const [
              DropdownMenuItem(value: "pending", child: Text("Pending")),
              DropdownMenuItem(value: "diproses", child: Text("Diproses")),
              DropdownMenuItem(value: "selesai", child: Text("Selesai")),
            ],
            onChanged: (v) => setState(() => status = v!),
          ),
          TextField(
            controller: catatanController,
            decoration: const InputDecoration(labelText: "Catatan RT"),
          ),
          TextField(
            controller: dataFinalController,
            decoration: const InputDecoration(labelText: "Data Final"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: simpan,
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}