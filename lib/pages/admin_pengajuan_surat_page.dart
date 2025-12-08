import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/detail_surat_dialog.dart';

class AdminPengajuanSuratPage extends StatelessWidget {
  const AdminPengajuanSuratPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 24,
          isMobile ? 16 : 0,
          isMobile ? 16 : 24,
          isMobile ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header dengan title dan search
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pengajuan Surat',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: greyColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pengajuan Surat',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: greyColor, size: 20),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: isMobile ? 20 : 24),
            // Tabel dengan scroll horizontal untuk mobile
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: isMobile ? 900 : MediaQuery.of(context).size.width - (isMobile ? 32 : 48),
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Table Header
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 120, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 120, child: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 150, child: Text('Jenis Surat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 200, child: Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 200, child: Text('Keperluan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 100, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 100, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                              SizedBox(width: 120, child: Text('Opsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12))),
                            ],
                          ),
                        ),
                        // Table Content
                        _buildTableRow(
                          'John Doe',
                          '1234567890123456',
                          'Surat Keterangan',
                          'Jl. Contoh No. 123',
                          'Keperluan administrasi',
                          '15/10/2025',
                          'Menunggu',
                          context,
                          isMobile,
                        ),
                        _buildTableRow(
                          'Jane Smith',
                          '9876543210987654',
                          'Surat Domisili',
                          'Jl. Test No. 456',
                          'Keperluan kerja',
                          '16/10/2025',
                          'Diproses',
                          context,
                          isMobile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String nama, String nik, String jenisSurat, String alamat,
      String keperluan, String tanggal, String status, BuildContext context, bool isMobile) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'menunggu':
        statusColor = Colors.orange;
        break;
      case 'diproses':
        statusColor = Colors.blue;
        break;
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              nama,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              nik,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              jenisSurat,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              alamat,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              keperluan,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              tanggal,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 100,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 6, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(
                status,
                style: TextStyle(color: whiteColor, fontSize: isMobile ? 10 : 11),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextButton(
              onPressed: () {
                // Tampilkan detail surat
                showDialog(
                  context: context,
                  builder: (context) => DetailSuratDialog(
                    surat: {
                      'jenisSurat': jenisSurat,
                      'nama': nama,
                      'nik': nik,
                      'alamat': alamat,
                      'keperluan': keperluan,
                      'tanggal': tanggal,
                      'status': status,
                    },
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Detail',
                style: TextStyle(color: primaryColor, fontSize: isMobile ? 11 : 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

