import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layanan_layout_security.dart';

class LayananPengaduanSecurityPage extends StatefulWidget {
  final String token;
  final String role;

  const LayananPengaduanSecurityPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<LayananPengaduanSecurityPage> createState() =>
      _LayananPengaduanSecurityPageState();
}

class _LayananPengaduanSecurityPageState
    extends State<LayananPengaduanSecurityPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _pengaduanList = [];
  bool _loading = true;
  late TabController _tabController;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPengaduan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Helper untuk construct URL gambar pengaduan
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    debugPrint('🖼️ Processing image path: $imagePath');
    
    // Jika sudah full URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Extract filename dari path
    String filename = imagePath;
    
    // Jika path berisi folder structure, ambil filename saja
    if (imagePath.contains('/')) {
      filename = imagePath.split('/').last;
    }
    
    // Gunakan route khusus pengaduan dari Laravel
    final url = 'http://localhost:8000/api/pengaduan/$filename';
    debugPrint('✅ Constructed URL: $url');
    
    return url;
  }

  Future<void> _fetchPengaduan() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/security/pengaduan"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      
      debugPrint('📥 Fetch status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pengaduanList = List<Map<String, dynamic>>.from(data['data']);
          
          // Debug: Print semua image paths
          for (var p in _pengaduanList) {
            debugPrint('Pengaduan ID ${p['id']}: ${p['image']}');
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memuat data (${response.statusCode})")),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Map<String, dynamic> pengaduan, String action,
      {String? feedback}) async {
    try {
      final url = "http://localhost:8000/api/security/pengaduan/${pengaduan['id']}/$action";

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: feedback != null ? json.encode({"feedback": feedback}) : null,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                action == 'feedback'
                    ? 'Feedback berhasil dikirim'
                    : action == 'done'
                        ? 'Pengaduan ditandai selesai'
                        : 'Status berhasil diupdate',
              ),
              backgroundColor: Colors.green,
            ),
          );
          await _fetchPengaduan();
          Navigator.pop(context);
          _feedbackController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal update (${response.statusCode})")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _showDetailPengaduan(Map<String, dynamic> pengaduan) {
    final status = (pengaduan['status']?.toString().toLowerCase() ?? '');
    final imageUrl = _getImageUrl(pengaduan['image']?.toString());
    _feedbackController.text = pengaduan['feedback']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.report_problem, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pengaduan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _getStatusText(status),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              color: _getStatusColor(status),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Image from Warga - FIXED URL
                      if (imageUrl.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📷 Foto dari Warga',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('❌ Error loading image: $error');
                                  debugPrint('   URL: $imageUrl');
                                  return Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image, size: 50, color: Colors.red),
                                        const SizedBox(height: 8),
                                        const Text('Gambar tidak dapat dimuat'),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'Path: ${pengaduan['image']}',
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      _buildInfoCard(
                        icon: Icons.title,
                        label: 'Judul',
                        value: pengaduan['title'] ?? '-',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.location_on,
                        label: 'Lokasi',
                        value: pengaduan['location'] ?? '-',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.description,
                        label: 'Deskripsi',
                        value: pengaduan['description'] ?? '-',
                        maxLines: null,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.access_time,
                        label: 'Tanggal',
                        value: pengaduan['created_at'] ?? '-',
                      ),

                      // Feedback Section
                      if (status == 'approved') ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Kirim Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _feedbackController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Tulis feedback untuk warga...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ],

                      // Display Existing Feedback
                      if (pengaduan['feedback'] != null &&
                          pengaduan['feedback'].toString().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.chat_bubble, color: Colors.green.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Feedback Anda',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pengaduan['feedback'].toString(),
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (status == 'approved')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_feedbackController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Feedback tidak boleh kosong')),
                              );
                              return;
                            }
                            _updateStatus(
                              pengaduan,
                              'feedback',
                              feedback: _feedbackController.text.trim(),
                            );
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Kirim Feedback'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (status == 'in_progress') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(pengaduan, 'done'),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Tandai Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    int? maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: maxLines,
                  overflow: maxLines != null ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'done':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.engineering;
      case 'done':
        return Icons.task_alt;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'DISETUJUI - MENUNGGU FEEDBACK';
      case 'in_progress':
        return 'SEDANG DITANGANI';
      case 'done':
        return 'SELESAI';
      case 'rejected':
        return 'DITOLAK';
      default:
        return status.toUpperCase();
    }
  }

  Widget _buildPengaduanCard(Map<String, dynamic> pengaduan) {
    final status = pengaduan['status']?.toString().toLowerCase() ?? '';
    final statusColor = _getStatusColor(status);
    final hasFeedback = pengaduan['feedback'] != null &&
        pengaduan['feedback'].toString().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetailPengaduan(pengaduan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pengaduan['title'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pengaduan['location'] ?? '-',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (hasFeedback) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.chat, size: 10, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Feedback',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPengaduanList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pengaduan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchPengaduan,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildPengaduanCard(list[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedList = _pengaduanList.map((p) {
      return {
        ...p,
        'status': p['status']?.toString().toLowerCase() ?? '',
      };
    }).toList();

    final aktifList = normalizedList
        .where((p) =>
            p['status'] == 'approved' &&
            (p['feedback'] == null || p['feedback'].toString().isEmpty))
        .toList();

    final riwayatList = normalizedList
        .where((p) =>
            p['status'] == 'in_progress' ||
            p['status'] == 'done' ||
            p['status'] == 'rejected' ||
            (p['status'] == 'approved' &&
                p['feedback'] != null &&
                p['feedback'].toString().isNotEmpty))
        .toList();

    return MainLayananLayoutSecurity(
      title: "Pengaduan Warga",
      token: widget.token,
      onBack: () => Navigator.pop(context),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Memuat pengaduan...'),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.pending_actions),
                        text: "Aktif",
                      ),
                      Tab(
                        icon: Icon(Icons.history),
                        text: "Riwayat",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPengaduanList(aktifList),
                      _buildPengaduanList(riwayatList),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}