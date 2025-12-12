import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout_rt.dart';

class LayananAdministrasiPageRT extends StatefulWidget {
  final String tokenRT;
  final String role;

  const LayananAdministrasiPageRT({
    super.key,
    required this.tokenRT,
    required this.role,
    });

  @override
  _LayananAdministrasiPageRTState createState() =>
      _LayananAdministrasiPageRTState();
}

class _LayananAdministrasiPageRTState extends State<LayananAdministrasiPageRT> {
  List<Map<String, dynamic>> tagihanList = [
    {"nama": "Iuran Kebersihan", "jumlah": 30000, "status": "Belum Bayar"},
    {"nama": "Iuran Keamanan", "jumlah": 30000, "status": "Belum Bayar"},
    {"nama": "Iuran Sampah", "jumlah": 30000, "status": "Belum Bayar"},
  ];

  bool isLoadingSemua = false;
  bool sudahUploadBukti = false;

  bool get semuaLunas => tagihanList.every((t) => t["status"] == "Lunas");

  Future<void> _bayarSemua() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Pembayaran"),
        content: const Text(
          "Apakah Anda yakin ingin membayar semua iuran bulan ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Bayar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoadingSemua = true);
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        for (var tagihan in tagihanList) {
          tagihan["status"] = "Lunas";
        }
        isLoadingSemua = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua tagihan berhasil dibayar.")),
      );
    }
  }

  Future<void> _bayarSatu(Map<String, dynamic> tagihan) async {
    if (tagihan["status"] == "Lunas") return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Bayar ${tagihan["nama"]}?"),
        content: Text(
          "Apakah Anda yakin ingin membayar iuran ${tagihan["nama"]}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Bayar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Memproses pembayaran ${tagihan["nama"]}...")),
      );

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        tagihan["status"] = "Lunas";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${tagihan["nama"]} berhasil dibayar!")),
      );
    }
  }

  void _uploadBuktiPembayaran() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upload Bukti Pembayaran"),
        content: const Text("Simulasi: bukti pembayaran berhasil diunggah."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Upload"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        sudahUploadBukti = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bukti pembayaran berhasil diunggah!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayananLayoutRT(
      title: "Layanan Administrasi RT",
      onBack: () => Navigator.pop(context),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tagihanList.length,
                  itemBuilder: (context, index) {
                    final tagihan = tagihanList[index];
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
                              tagihan['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp${tagihan['jumlah']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Status: ${tagihan['status']}"),
                                if (tagihan['status'] != 'Lunas')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      minimumSize: const Size(90, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _bayarSatu(tagihan),
                                    child: const Text(
                                      "Bayar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Tombol bagian bawah
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: (isLoadingSemua || semuaLunas)
                          ? null
                          : _bayarSemua,
                      child: isLoadingSemua
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Bayar Semua Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),

                    if (semuaLunas && !sudahUploadBukti)
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Upload Bukti Pembayaran",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _uploadBuktiPembayaran,
                      ),

                    if (sudahUploadBukti)
                      const Text(
                        "✅ Bukti pembayaran sudah diunggah.",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
