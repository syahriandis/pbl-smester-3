import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:login_tes/constants/colors.dart';
import 'detail_surat_rt.dart';

class LayananSuratPageRT extends StatefulWidget {
  final String tokenRT;
  final String role;

  const LayananSuratPageRT({
    super.key,
    required this.tokenRT,
    required this.role,
  });

  @override
  _LayananSuratPageRTState createState() => _LayananSuratPageRTState();
}

class _LayananSuratPageRTState extends State<LayananSuratPageRT> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _suratList = [];
  bool _loading = true;
  String? _userPhoto;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _fetchSurat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer ${widget.tokenRT}',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final userData = result['data'];
        setState(() {
          _userPhoto = userData['photo'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchSurat() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/rt/surat"),
        headers: {
          "Authorization": "Bearer ${widget.tokenRT}",
          "Accept": "application/json",
        },
      );

      print("LIST RT STATUS: ${response.statusCode}");
      print("LIST RT BODY: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];

        setState(() {
          _suratList = List<Map<String, dynamic>>.from(data.map((s) {
            return {
              'id_pengajuan': s['id_pengajuan'],
              'jenisSurat': s['jenis_surat']?['nama_jenis_surat'] ?? '-',
              'nama': s['user']?['name'] ?? '-',
              'keperluan': s['keperluan'] ?? '-',
              'catatan_rt': s['catatan_rt'] ?? '-',
              'status': s['status'] ?? '-',
              'tanggal': s['tanggal_pengajuan'] ?? s['created_at'],
            };
          }));
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data surat")),
        );
      }
    } catch (e) {
      print("ERROR LIST RT: $e");
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat memuat data")),
      );
    }
  }

  Future<void> _updateStatusBackend(int index, String status, {String? catatan}) async {
    final surat = _suratList[index];

    try {
      final response = await http.put(
        Uri.parse("http://localhost:8000/api/rt/surat/${surat['id_pengajuan']}"),
        headers: {
          "Authorization": "Bearer ${widget.tokenRT}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "status": status,
          "catatan_rt": catatan ?? surat['catatan_rt'],
        }),
      );

      print("UPDATE STATUS CODE: ${response.statusCode}");
      print("UPDATE STATUS BODY: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _suratList[index]['status'] = status;
          _suratList[index]['catatan_rt'] = catatan ?? surat['catatan_rt'] ?? '-';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui status surat"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _inputCatatanDialog() async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.note_alt, color: primaryColor),
              const SizedBox(width: 8),
              const Text("Catatan RT/RW", style: TextStyle(fontSize: 18)),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Tambahkan catatan (opsional)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuratList(String status) {
    final filtered = _suratList.where((s) => s['status'] == status).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(status),
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada surat ${_getStatusText(status)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSurat,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final surat = filtered[index];
          final globalIndex = _suratList.indexWhere(
            (item) => item['id_pengajuan'] == surat['id_pengajuan'],
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getStatusColor(surat['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(surat['status']),
                            color: _getStatusColor(surat['status']),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
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
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    surat['nama'],
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getStatusColor(surat['status']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusLabel(surat['status']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description_outlined, size: 16, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                "Keperluan:",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            surat['keperluan'],
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(surat['tanggal'])),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailSuratRTPage(
                                    idPengajuan: surat['id_pengajuan'],
                                    token: widget.tokenRT,
                                    role: widget.role,
                                  ),
                                ),
                              );
                              if (result == true) _fetchSurat();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text("Detail"),
                          ),
                        ),
                        if (surat['status'] == 'pending') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final catatan = await _inputCatatanDialog();
                                await _updateStatusBackend(globalIndex, 'disetujui', catatan: catatan);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text("Setujui"),
                            ),
                          ),
                        ],
                        if (surat['status'] == 'disetujui') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final catatan = await _inputCatatanDialog();
                                await _updateStatusBackend(globalIndex, 'selesai', catatan: catatan);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.done_all, size: 18),
                              label: const Text("Selesai"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getEmptyIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'disetujui': return Icons.check_circle_outline;
      case 'selesai': return Icons.task_alt;
      default: return Icons.inbox;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'menunggu';
      case 'disetujui': return 'disetujui';
      case 'selesai': return 'selesai';
      default: return status;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'MENUNGGU';
      case 'disetujui': return 'DISETUJUI';
      case 'selesai': return 'SELESAI';
      case 'ditolak': return 'DITOLAK';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'disetujui': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.access_time;
      case 'disetujui': return Icons.check_circle;
      case 'selesai': return Icons.task_alt;
      case 'ditolak': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan foto profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.role == "rw" ? "Layanan Surat RW" : "Layanan Surat RT",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Kelola pengajuan surat warga",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _userPhoto != null && _userPhoto!.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.network(
                                'http://localhost:8000/api/storage/$_userPhoto',
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, color: primaryColor, size: 24);
                                },
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: primaryColor, size: 24),
                          ),
                        ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "Pending"),
                  Tab(text: "Disetujui"),
                  Tab(text: "Selesai"),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSuratList("pending"),
                        _buildSuratList("disetujui"),
                        _buildSuratList("selesai"),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}