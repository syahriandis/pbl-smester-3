import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';
import 'package:login_tes/widgets/main_layout_security.dart';

class RiwayatPage extends StatefulWidget {
  final String token;
  final String role;

  const RiwayatPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> _riwayatList = [];
  bool _isLoading = true;
  String? _userPhoto;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRiwayat();
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

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final userData = result['data'];
      
      // ✅ CEK MOUNTED SEBELUM SETSTATE
      if (!mounted) return;
      
      setState(() {
        _userPhoto = userData['photo'];
      });
    }
  } catch (e) {
    print('Error loading user data: $e');
  }
}

Future<void> _loadRiwayat() async {
  // ✅ CEK MOUNTED SEBELUM SETSTATE
  if (!mounted) return;
  
  setState(() => _isLoading = true);

  try {
    final url = 'http://localhost:8000/api/pembayaran/riwayat';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      
      if (result['success'] == true || result['data'] != null) {
        final List<dynamic> rawData = result['data'] ?? [];
        
        final List<Map<String, dynamic>> cleanData = rawData.map((item) {
          final Map<String, dynamic> cleanItem = Map<String, dynamic>.from(item);
          
          if (cleanItem['nominal'] != null) {
            cleanItem['nominal'] = _parseToInt(cleanItem['nominal']);
          }
          if (cleanItem['jumlah'] != null) {
            cleanItem['jumlah'] = _parseToInt(cleanItem['jumlah']);
          }
          if (cleanItem['amount'] != null) {
            cleanItem['amount'] = _parseToInt(cleanItem['amount']);
          }
          
          return cleanItem;
        }).toList();
        
        // ✅ CEK MOUNTED SEBELUM SETSTATE
        if (!mounted) return;
        
        setState(() {
          _riwayatList = cleanData;
          _isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Gagal memuat riwayat');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading riwayat: $e');
    
    // ✅ CEK MOUNTED SEBELUM SETSTATE
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final cleanValue = value
          .replaceAll(',', '')
          .split('.')[0];
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sudah_bayar':
      case 'Lunas':
        return Colors.green;
      case 'menunggu_verifikasi':
        return Colors.orange;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sudah_bayar':
      case 'Lunas':
        return Icons.check_circle;
      case 'menunggu_verifikasi':
        return Icons.access_time;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getNamaBulan(int bulan) {
    const bulanIndonesia = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanIndonesia[bulan - 1];
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'belum_bayar':
        return 'Belum Bayar';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'sudah_bayar':
        return 'Sudah Bayar';
      case 'ditolak':
        return 'Ditolak';
      case 'Lunas':
        return 'Lunas';
      default:
        return status;
    }
  }

  void _showDetailDialog(Map<String, dynamic> pembayaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detail Pembayaran\n${pembayaran['bulan'] != null ? _getNamaBulan(pembayaran['bulan']) : ''} ${pembayaran['tahun'] ?? ''}',
          style: const TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', _getStatusLabel(pembayaran['status'])),
              _buildDetailRow(
                'Nominal',
                currencyFormat.format(pembayaran['nominal'] ?? pembayaran['jumlah'] ?? 110000),
              ),
              if (pembayaran['metode_pembayaran'] != null)
                _buildDetailRow(
                  'Metode',
                  pembayaran['metode_pembayaran'] == 'qris' ? 'QRIS' : 'Transfer Bank',
                ),
              if (pembayaran['tanggal_bayar'] != null)
                _buildDetailRow(
                  'Tanggal Bayar',
                  DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                      .format(DateTime.parse(pembayaran['tanggal_bayar'])),
                ),
              if (pembayaran['tanggal_verifikasi'] != null)
                _buildDetailRow(
                  'Tanggal Verifikasi',
                  DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                      .format(DateTime.parse(pembayaran['tanggal_verifikasi'])),
                ),
              if (pembayaran['catatan_admin'] != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Catatan Admin:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    pembayaran['catatan_admin'],
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget layout;
    if (widget.role == 'rt' || widget.role == 'rw') {
      layout = MainLayoutRT(
        selectedIndex: 1,
        tokenRT: widget.token,
        role: widget.role,
        child: _buildContent(),
      );
    } else if (widget.role == 'security') {
      layout = MainLayoutSecurity(
        selectedIndex: 1,
        token: widget.token,
        role: widget.role,
        child: _buildContent(),
      );
    } else {
      layout = MainLayout(
        selectedIndex: 1,
        token: widget.token,
        role: widget.role,
        child: _buildContent(),
      );
    }

    return layout;
  }

  Widget _buildContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 50),
                _userPhoto != null && _userPhoto!.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        'http://localhost:8000/api/storage/$_userPhoto',
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: primaryColor);
                        },
                      ),
                    ),
                  )
                : const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: primaryColor),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Riwayat Administrasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadRiwayat,
                        color: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: primaryColor))
                        : _riwayatList.isEmpty
                            ? _buildEmptyState()
                            : _buildRiwayatList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Belum ada riwayat', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadRiwayat,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatList() {
    return RefreshIndicator(
      onRefresh: _loadRiwayat,
      color: primaryColor,
      child: ListView.builder(
        itemCount: _riwayatList.length,
        itemBuilder: (context, index) {
          final item = _riwayatList[index];
          final isNewFormat = item.containsKey('bulan') && item.containsKey('tahun');
          
          if (isNewFormat) {
            return _buildRiwayatCardNew(item);
          } else {
            return _buildRiwayatCardOld(item);
          }
        },
      ),
    );
  }

  Widget _buildRiwayatCardNew(Map<String, dynamic> pembayaran) {
    final status = pembayaran['status'] ?? 'belum_bayar';
    final bulan = pembayaran['bulan'];
    final tahun = pembayaran['tahun'];
    final nominal = pembayaran['nominal'] ?? 110000;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailDialog(pembayaran),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getNamaBulan(bulan)} $tahun',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(nominal), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildRiwayatCardOld(Map<String, dynamic> item) {
    final nama = item['nama'] ?? item['name'] ?? '';
    final jumlah = item['jumlah'] ?? item['amount'] ?? 0;
    final status = item['status'] ?? 'Lunas';
    final payment = item['payment'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8B0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text("Rp", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCC8800))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.isNotEmpty ? '$nama membayar $payment' : nama,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    if (status != 'Lunas')
                      Text(status, style: TextStyle(fontSize: 12, color: _getStatusColor(status))),
                  ],
                ),
              ),
              Text(currencyFormat.format(jumlah), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}