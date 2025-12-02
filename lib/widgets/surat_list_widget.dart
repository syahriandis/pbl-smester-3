import 'package:flutter/material.dart';

class SuratListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> suratList;
  final Function(Map<String, dynamic>) onDetail;
  final Function(Map<String, dynamic>)? onSetujui;
  final Function(Map<String, dynamic>)? onTolak;

  const SuratListWidget({
    super.key,
    required this.suratList,
    required this.onDetail,
    this.onSetujui,
    this.onTolak,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suratList.length,
      itemBuilder: (context, index) {
        final surat = suratList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surat['jenisSurat'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  surat['deskripsi'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text("Lokasi: ${surat['lokasi']}"),
                const SizedBox(height: 4),
                Text("Status: ${surat['status']}"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => onDetail(surat),
                      child: const Text('Lihat Detail'),
                    ),
                    if (onSetujui != null &&
                        surat['status'] == 'Menunggu Persetujuan')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => onSetujui!(surat),
                        child: const Text('Setujui'),
                      ),
                    if (onTolak != null &&
                        surat['status'] == 'Menunggu Persetujuan')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => onTolak!(surat),
                        child: const Text('Tolak'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
