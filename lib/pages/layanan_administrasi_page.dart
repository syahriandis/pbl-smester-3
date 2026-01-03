import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class LayananAdministrasiPage extends StatefulWidget {
  final String token;
  final String role;

  const LayananAdministrasiPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<LayananAdministrasiPage> createState() => _LayananAdministrasiPageState();
}

class _LayananAdministrasiPageState extends State<LayananAdministrasiPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isUploading = false;
  
  Map<String, dynamic>? _statusPembayaran;
  List<dynamic> _riwayatPembayaran = [];
  
  final TextEditingController _catatanController = TextEditingController();
  String _metodePembayaran = 'qris';
  XFile? _buktiImage;
  
  final String _baseUrl = 'http://localhost:8000/api';
  final Color primaryColor = const Color(0xFF164E47);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchStatusPembayaran(),
        _fetchRiwayatPembayaran(),
      ]);
    } catch (e) {
      _showSnackBar('Gagal memuat data: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStatusPembayaran() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pembayaran/status-bulan-ini'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() => _statusPembayaran = data['data']);
    }
  }

  Future<void> _fetchRiwayatPembayaran() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pembayaran/riwayat'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() => _riwayatPembayaran = data['data']);
    }
  }

  Future<void> _uploadBuktiPembayaran() async {
    if (_buktiImage == null) {
      _showSnackBar('Silakan pilih bukti pembayaran', Colors.orange);
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Konversi XFile ke bytes untuk web
      final bytes = await _buktiImage!.readAsBytes();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/pembayaran/upload-bukti'),
      );
      
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.headers['Accept'] = 'application/json';
      request.fields['bulan'] = DateTime.now().month.toString();
      request.fields['tahun'] = DateTime.now().year.toString();
      request.fields['metode_pembayaran'] = _metodePembayaran;
      
      // Gunakan fromBytes untuk kompatibilitas web
      request.files.add(
        http.MultipartFile.fromBytes(
          'bukti_pembayaran',
          bytes,
          filename: _buktiImage!.name,
        ),
      );

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody.body);
        _showSnackBar(data['message'], Colors.green);
        
        setState(() => _buktiImage = null);
        _catatanController.clear();
        
        await _fetchData();
        
        if (mounted) Navigator.pop(context);
      } else {
        final data = json.decode(responseBody.body);
        _showSnackBar(data['message'] ?? 'Upload gagal', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() => _buktiImage = image);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getBulanName(int bulan) {
    const bulanNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanNames[bulan - 1];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sudah_bayar':
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
        return Icons.check_circle;
      case 'menunggu_verifikasi':
        return Icons.pending;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Layanan Administrasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: primaryColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildAksiCard(),
                    const SizedBox(height: 24),
                    _buildRiwayatCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF2E7D6F)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pembayaran Bulanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Periode: ${_getBulanName(DateTime.now().month)} ${DateTime.now().year}',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Iuran bulan ini: Rp110.000',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _statusPembayaran?['status'] ?? 'belum_bayar';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    
    String statusText = status == 'sudah_bayar' ? 'Lunas' 
      : status == 'menunggu_verifikasi' ? 'Menunggu Verifikasi'
      : status == 'ditolak' ? 'Ditolak' : 'Belum Bayar';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(statusText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            if (status == 'menunggu_verifikasi') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Sedang dalam proses verifikasi', style: TextStyle(fontSize: 12, color: Colors.orange[800]))),
                  ],
                ),
              ),
            ],
            if (status == 'ditolak') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_statusPembayaran?['catatan_admin'] ?? 'Ditolak', style: TextStyle(fontSize: 12, color: Colors.red[800]))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAksiCard() {
    final status = _statusPembayaran?['status'] ?? 'belum_bayar';
    final canUpload = status == 'belum_bayar' || status == 'ditolak';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aksi Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 12),
            if (canUpload) ...[
              _buildMetodePembayaran(),
              const SizedBox(height: 12),
              _buildUploadArea(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _showUploadDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text('Upload Bukti', style: TextStyle(color: Colors.white)),
                ),
              ),
            ] else if (status == 'menunggu_verifikasi') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(child: Text('Menunggu verifikasi', style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Sudah lunas', style: TextStyle(color: Colors.green))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetodePembayaran() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _metodePembayaran = 'qris'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _metodePembayaran == 'qris' ? primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _metodePembayaran == 'qris' ? primaryColor : Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, color: _metodePembayaran == 'qris' ? Colors.white : primaryColor, size: 24),
                  const SizedBox(height: 4),
                  Text('QRIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _metodePembayaran == 'qris' ? Colors.white : Colors.grey[800])),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _metodePembayaran = 'transfer'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _metodePembayaran == 'transfer' ? primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _metodePembayaran == 'transfer' ? primaryColor : Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_balance, color: _metodePembayaran == 'transfer' ? Colors.white : primaryColor, size: 24),
                  const SizedBox(height: 4),
                  Text('Transfer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _metodePembayaran == 'transfer' ? Colors.white : Colors.grey[800])),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _buktiImage != null ? Colors.green : Colors.grey[300]!),
        ),
        child: _buktiImage != null
            ? Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 40),
                  const SizedBox(height: 8),
                  Text('File: ${_buktiImage!.name}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                ],
              )
            : Column(
                children: [
                  Icon(Icons.cloud_upload, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Text('Klik untuk upload', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Upload'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_metodePembayaran == 'qris') _buildQRISInfo(),
              if (_metodePembayaran == 'transfer') _buildTransferInfo(),
              const SizedBox(height: 16),
              if (_buktiImage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Bukti: ${_buktiImage!.name}', style: const TextStyle(color: Colors.green, fontSize: 12))),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Pilih bukti terlebih dahulu', style: TextStyle(color: Colors.orange, fontSize: 12))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _buktiImage == null || _isUploading ? null : () {
              Navigator.pop(context);
              _uploadBuktiPembayaran();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQRISInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text('Langkah QRIS:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildStep('1', 'Buka aplikasi e-wallet (GoPay, OVO, Dana)'),
          _buildStep('2', 'Scan QR Code QRIS'),
          _buildStep('3', 'Bayar Rp110.000'),
          _buildStep('4', 'Screenshot bukti'),
          _buildStep('5', 'Upload bukti'),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 80, color: primaryColor),
                const SizedBox(height: 8),
                const Text('QR Code QRIS', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text('Langkah Transfer:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildStep('1', 'Pilih rekening tujuan'),
          _buildStep('2', 'Buka m-banking/ATM'),
          _buildStep('3', 'Transfer Rp110.000'),
          _buildStep('4', 'Simpan bukti transfer'),
          _buildStep('5', 'Upload bukti'),
          const SizedBox(height: 12),
          _buildBankInfo('BCA', '1234567890'),
          const SizedBox(height: 8),
          _buildBankInfo('Mandiri', '9876543210'),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildBankInfo(String bank, String norek) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bank, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
              Text(norek, style: const TextStyle(fontSize: 11)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: norek));
              _showSnackBar('Nomor disalin', Colors.green);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 12),
            _riwayatPembayaran.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('Belum ada riwayat', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _riwayatPembayaran.length,
                    itemBuilder: (context, index) {
                      final item = _riwayatPembayaran[index];
                      final status = item['status'] ?? 'belum_bayar';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _getStatusColor(status).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_getBulanName(item['bulan'])} ${item['tahun']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text(status == 'sudah_bayar' ? 'Lunas' : status, style: TextStyle(fontSize: 11, color: _getStatusColor(status))),
                                ],
                              ),
                            ),
                            const Text('Rp110.000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}