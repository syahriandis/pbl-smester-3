import 'package:flutter/material.dart';

class SuratListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> suratList;
  final Function(Map<String, dynamic>) onDetail;
  final Function(Map<String, dynamic>)? onSetujui;
  final Function(Map<String, dynamic>)? onTolak;
  final Function(Map<String, dynamic>)? onSelesai;

  const SuratListWidget({
    super.key,
    required this.suratList,
    required this.onDetail,
    this.onSetujui,
    this.onTolak,
    this.onSelesai,
  });

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "disetujui":
        return Colors.blue;
      case "selesai":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "pending":
        return Icons.hourglass_empty;
      case "disetujui":
        return Icons.check_circle_outline;
      case "selesai":
        return Icons.verified;
      case "ditolak":
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suratList.length,
      itemBuilder: (context, index) {
        final surat = suratList[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onDetail(surat),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            surat['jenisSurat'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text("Nama: ${surat['nama'] ?? '-'}",
                        style: const TextStyle(fontSize: 15)),
                    Text("Keperluan: ${surat['keperluan'] ?? '-'}",
                        style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 10),

                    // ✅ Status Badge
                    Row(
                      children: [
                        Icon(
                          _statusIcon(surat['status']),
                          color: _statusColor(surat['status']),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(surat['status']).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            surat['status'].toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(surat['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ✅ Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => onDetail(surat),
                          icon: const Icon(Icons.visibility),
                          label: const Text("Detail"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ✅ SETUJUI
                        if (onSetujui != null && surat['status'] == 'pending')
                          ElevatedButton.icon(
                            onPressed: () => onSetujui!(surat),
                            icon: const Icon(Icons.check),
                            label: const Text("Setujui"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),

                        const SizedBox(width: 8),

                        // ✅ TOLAK
                        if (onTolak != null && surat['status'] == 'pending')
                          ElevatedButton.icon(
                            onPressed: () => onTolak!(surat),
                            icon: const Icon(Icons.close),
                            label: const Text("Tolak"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),

                        const SizedBox(width: 8),

                        // ✅ SELESAI
                        if (onSelesai != null && surat['status'] == 'disetujui')
                          ElevatedButton.icon(
                            onPressed: () => onSelesai!(surat),
                            icon: const Icon(Icons.done_all),
                            label: const Text("Selesai"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}