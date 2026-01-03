import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/tambah_surat_dialog.dart';
import 'package:login_tes/widgets/detail_surat_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class LayananSuratPage extends StatefulWidget {
  final String role;
  final String token;

  const LayananSuratPage({
    super.key,
    required this.role,
    required this.token,
  });

  @override
  State<LayananSuratPage> createState() => _LayananSuratPageState();
}

class _LayananSuratPageState extends State<LayananSuratPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _suratList = [];
  bool _loading = true;
  String? _userPhoto;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _fetchSuratList();
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
          'Authorization': 'Bearer ${widget.token}',
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

  Future<void> _fetchSuratList() async {
    setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/warga/surat'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        data.sort((a, b) => b['tanggal_pengajuan'].compareTo(a['tanggal_pengajuan']));

        setState(() {
          _suratList = data.map((item) {
            return {
              'id': item['id_pengajuan'],
              'jenisSurat': item['jenis_surat']['nama_jenis_surat'],
              'tanggal': item['tanggal_pengajuan'],
              'status': item['status'],
              'file_surat': item['file_surat'],
              'keperluan': item['keperluan'],
              'detail': item,
            };
          }).toList();
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _downloadSurat(String fileName) async {
    final encoded = Uri.encodeComponent(fileName);
    final url = "http://localhost:8000/api/storage/surat_jadi/$encoded";
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka file surat")),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showTambahSuratDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahSuratDialog(token: widget.token),
    ).then((_) async {
      await _fetchSuratList();
    });
  }

  void _showDetailSurat(Map<String, dynamic> surat) {
    showDialog(
      context: context,
      builder: (context) => DetailSuratDialog(surat: surat),
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
      onRefresh: _fetchSuratList,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final surat = filtered[index];
          final isToday = surat['tanggal'] == DateFormat('yyyy-MM-dd').format(DateTime.now());

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
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showDetailSurat(surat),
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
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(surat['tanggal'])),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                "BARU",
                                style: TextStyle(
                                  color: Colors.red.shade700,
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
                        child: Row(
                          children: [
                            Icon(Icons.description_outlined, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                surat['keperluan'] ?? 'Tidak ada keperluan',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(surat['status']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusLabel(surat['status']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (surat['status'] == "selesai" && surat['file_surat'] != null)
                            ElevatedButton.icon(
                              onPressed: () => _downloadSurat(surat['file_surat']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text("Download", style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          else
                            TextButton.icon(
                              onPressed: () => _showDetailSurat(surat),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        const Text(
                          "Layanan Surat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Kelola pengajuan surat Anda",
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
      
      // FAB
      floatingActionButton: (widget.role == "warga" || widget.role == "security")
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              onPressed: _showTambahSuratDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Ajukan Surat",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}