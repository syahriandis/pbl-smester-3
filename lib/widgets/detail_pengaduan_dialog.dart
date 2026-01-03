import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_tes/constants/colors.dart';

class DetailPengaduanDialog extends StatefulWidget {
  final Map<String, dynamic> pengaduan;
  final String role;
  final String token;
  final VoidCallback onRefresh;

  const DetailPengaduanDialog({
    super.key,
    required this.pengaduan,
    required this.role,
    required this.token,
    required this.onRefresh,
  });

  @override
  State<DetailPengaduanDialog> createState() => _DetailPengaduanDialogState();
}

class _DetailPengaduanDialogState extends State<DetailPengaduanDialog> {
  final feedbackController = TextEditingController();
  bool _loading = false;

  Future<void> _updateStatus(String action, {String? feedback}) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final id = widget.pengaduan['id'];
      final role = widget.role;
      final url = role == "rt"
          ? "http://localhost:8000/api/rt/pengaduan/$id/$action"
          : "http://localhost:8000/api/security/pengaduan/$id/$action";

      final response = await http.put(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
        body: feedback != null && feedback.isNotEmpty
            ? {"feedback": feedback}
            : null,
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aksi berhasil: $action")),
        );
        widget.onRefresh();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal aksi (${response.statusCode})")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pengaduan;
    final status = p['status']?.toString().toLowerCase() ?? '';
    final hasFeedback =
        p['feedback'] != null && p['feedback'].toString().isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
      title: const Text("Detail Pengaduan",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p['image'] != null && p['image'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "http://localhost:8000/${p['image']}",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text("Gambar tidak tersedia"),
                ),
              ),
            const SizedBox(height: 12),
            Text("📝 Judul: ${p['title'] ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("📍 Lokasi: ${p['location'] ?? '-'}"),
            const SizedBox(height: 6),
            Text("📄 Deskripsi: ${p['description'] ?? '-'}"),
            const SizedBox(height: 6),
            Text("📅 Tanggal: ${p['created_at'] ?? '-'}"),
            const SizedBox(height: 6),
            Text("📌 Status: $status",
                style: TextStyle(
                    color: status == 'done'
                        ? Colors.green
                        : status == 'rejected'
                            ? Colors.red
                            : status == 'in_progress'
                                ? Colors.orange
                                : primaryColor,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (hasFeedback)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("✅ Feedback: ${p['feedback']}",
                    style: const TextStyle(color: Colors.green)),
              ),
            if (widget.role == "security" && status == "approved")
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: "Tulis Feedback",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () {
            if (mounted) Navigator.pop(context);
          },
          child: const Text("Tutup"),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        if (widget.role == "rt" && status == "pending") ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _updateStatus("approve"),
            label: const Text("Approve"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.close),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _updateStatus("reject"),
            label: const Text("Reject"),
          ),
        ],
        if (widget.role == "security" && status == "approved")
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () =>
                _updateStatus("feedback", feedback: feedbackController.text),
            label: const Text("Kirim Feedback"),
          ),
        if (widget.role == "security" && status == "in_progress")
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _updateStatus("done"),
            label: const Text("Tandai Selesai"),
          ),
      ],
    );
  }
}