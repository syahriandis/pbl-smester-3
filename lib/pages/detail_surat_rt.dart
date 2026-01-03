import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_tes/constants/colors.dart';

class DetailSuratRTPage extends StatefulWidget {
  final int idPengajuan;
  final String token;
  final String role;

  const DetailSuratRTPage({
    super.key,
    required this.idPengajuan,
    required this.token,
    required this.role,
  });

  @override
  State<DetailSuratRTPage> createState() => _DetailSuratRTPageState();
}

class _DetailSuratRTPageState extends State<DetailSuratRTPage> {
  Map<String, dynamic>? surat;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final res = await http.get(
      Uri.parse("http://localhost:8000/api/rt/surat/${widget.idPengajuan}"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Accept": "application/json",
      },
    );

    print("DETAIL STATUS: ${res.statusCode}");
    print("DETAIL BODY: ${res.body}");

    if (res.statusCode == 200) {
      setState(() {
        surat = jsonDecode(res.body)["data"];
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat detail surat")),
      );
    }
  }

  // ✅ UPDATE STATUS
  Future<void> _updateStatus(String status, {String? catatan}) async {
    final res = await http.put(
      Uri.parse("http://localhost:8000/api/rt/surat/${widget.idPengajuan}"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "status": status,
        "catatan_rt": catatan ?? "",
      }),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update status: ${res.body}")),
      );
    }
  }

  // ✅ UPLOAD SURAT JADI (WEB + MOBILE SAFE)
  Future<void> _uploadSurat() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
      withData: true,
    );

    if (result == null) return;

    final picked = result.files.single;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://localhost:8000/api/rt/surat/${widget.idPengajuan}/upload"),
    );

    request.headers["Authorization"] = "Bearer ${widget.token}";
    request.headers["Accept"] = "application/json";

    http.MultipartFile multipartFile;

    if (picked.bytes != null) {
      multipartFile = http.MultipartFile.fromBytes(
        'file_surat',
        picked.bytes!,
        filename: picked.name,
      );
    } else {
      multipartFile = await http.MultipartFile.fromPath(
        'file_surat',
        picked.path!,
      );
    }

    request.files.add(multipartFile);

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    print("UPLOAD STATUS: ${response.statusCode}");
    print("UPLOAD BODY: $respStr");

    Navigator.pop(context);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload surat: $respStr")),
      );
    }
  }

  Future<String?> _inputCatatan() async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Catatan RT/RW"),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: "Tambahkan catatan (opsional)"),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, c.text), child: const Text("Simpan")),
        ],
      ),
    );
  }

    Widget _previewFile(String fileName) {
    final encoded = Uri.encodeComponent(fileName);
    final url = "http://localhost:8000/storage/surat_jadi/$encoded";

    final isImage = fileName.endsWith(".jpg") ||
        fileName.endsWith(".jpeg") ||
        fileName.endsWith(".png");

    final isPdf = fileName.endsWith(".pdf");

    if (isImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preview Gambar:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }

    if (isPdf) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preview PDF:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text("Buka PDF"),
          ),
        ],
      );
    }

    return const Text("Format file tidak didukung");
  }
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final s = surat!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(widget.role == "rw" ? "Detail Surat RW" : "Detail Surat RT"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['jenis_surat']?['nama_jenis_surat'] ?? "-",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "ID Pengajuan: ${widget.idPengajuan}",
                      style: const TextStyle(color: whiteColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _modernSection("Data Warga", [
                _modernRow("Nama", s['user']?['name'] ?? "-"),
                _modernRow("UserID", s['user']?['id']?.toString() ?? "-"),
              ]),

              _modernSection("Info Surat", [
                _modernRow("Keperluan", s['keperluan'] ?? "-"),
                _modernRow("Status", s['status'] ?? "-"),
                _modernRow("Tanggal Pengajuan", s['tanggal_pengajuan'] ?? "-"),
              ]),

              // ✅ CATATAN
              _modernSection("Catatan RT/RW", [
                Text(s['catatan_rt'] ?? "-", style: const TextStyle(fontSize: 15)),
              ]),

              _modernSection("Surat Jadi", [
                if (s['file_surat'] == null)
                  const Text("Belum ada file surat jadi.", style: TextStyle(fontSize: 15))
                else
                  _previewFile(s['file_surat']),
              ]),

              const SizedBox(height: 20),

              _modernButtons(s),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UI COMPONENTS
  Widget _modernSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              )),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _modernRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernButtons(Map<String, dynamic> s) {
    return Column(
      children: [
        if (s['status'] == "pending")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _pillButton("Setujui", secondaryColor, () async {
                final catatan = await _inputCatatan();
                await _updateStatus("disetujui", catatan: catatan);
              }),
              _pillButton("Tolak", Colors.red, () async {
                final catatan = await _inputCatatan();
                await _updateStatus("ditolak", catatan: catatan);
              }),
            ],
          ),

        if (s['status'] == "disetujui")
          _pillButton("Upload Surat Jadi", primaryColor, () async {
            await _uploadSurat();
          }),

        if (s['status'] == "selesai")
          const Text("Surat sudah selesai dan siap diunduh warga."),
      ],
    );
  }

  Widget _pillButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}