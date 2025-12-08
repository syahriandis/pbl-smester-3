import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/utils/user_storage.dart';
import 'package:login_tes/widgets/tambah_pendaftar_dialog.dart';

class AdminPendaftaranPage extends StatefulWidget {
  const AdminPendaftaranPage({super.key});

  @override
  State<AdminPendaftaranPage> createState() => _AdminPendaftaranPageState();
}

class _AdminPendaftaranPageState extends State<AdminPendaftaranPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _pendaftarList = [];
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _loadPendaftar();
    _searchController.addListener(_filterPendaftar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPendaftar() {
    setState(() {
      _pendaftarList = UserStorage.getAllPendaftar();
      _filteredList = _pendaftarList;
    });
  }

  void _filterPendaftar() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredList = _pendaftarList;
      } else {
        _filteredList = _pendaftarList.where((pendaftar) {
          final nama = pendaftar['nama']?.toString().toLowerCase() ?? '';
          final nik = pendaftar['nik']?.toString().toLowerCase() ?? '';
          final telp = pendaftar['telp']?.toString().toLowerCase() ?? '';
          return nama.contains(query) || nik.contains(query) || telp.contains(query);
        }).toList();
      }
    });
  }

  void _tambahPendaftar(Map<String, dynamic> data) {
    UserStorage.addPendaftar(data);
    _loadPendaftar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftar berhasil ditambahkan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPendaftar(String id, Map<String, dynamic> data) {
    UserStorage.updatePendaftar(id, data);
    _loadPendaftar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftar berhasil diupdate'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _hapusPendaftar(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus pendaftar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: greyColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              UserStorage.removePendaftar(id);
              _loadPendaftar();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pendaftar berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _terimaPendaftar(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Konfirmasi Terima',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menerima pendaftar ini? Data akan ditambahkan ke daftar user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: greyColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              UserStorage.terimaPendaftar(id);
              _loadPendaftar();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pendaftar berhasil diterima dan ditambahkan ke user'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Terima',
              style: TextStyle(color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showTambahDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahPendaftarDialog(
        onSubmit: _tambahPendaftar,
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> pendaftar) {
    showDialog(
      context: context,
      builder: (context) => TambahPendaftarDialog(
        onSubmit: (data) => _editPendaftar(pendaftar['id'], data),
        pendaftar: pendaftar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      body: SingleChildScrollView(
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
                          'Pendaftaran',
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
                                  controller: _searchController,
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
                          'Pendaftaran',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Row(
                          children: [
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
                                      controller: _searchController,
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
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _showTambahDialog,
                              icon: const Icon(Icons.add, color: whiteColor),
                              label: const Text(
                                'Tambah',
                                style: TextStyle(color: whiteColor),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
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
                      minWidth: isMobile ? 800 : MediaQuery.of(context).size.width - (isMobile ? 32 : 48),
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
                                SizedBox(width: 50, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                SizedBox(width: 120, child: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                SizedBox(width: 150, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                SizedBox(width: 120, child: Text('Telp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                                SizedBox(width: 200, child: Text('Opsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
                              ],
                            ),
                          ),
                          // Table Content
                          if (_filteredList.isEmpty)
                            Container(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              child: const Text(
                                'Tidak ada data pendaftar',
                                style: TextStyle(color: greyColor),
                              ),
                            )
                          else
                            ...List.generate(_filteredList.length, (index) {
                              final pendaftar = _filteredList[index];
                              return Container(
                                padding: EdgeInsets.all(isMobile ? 12 : 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 50, child: Text('${index + 1}', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                                    SizedBox(width: 120, child: Text(pendaftar['nik'] ?? '', style: TextStyle(fontSize: isMobile ? 12 : 14), overflow: TextOverflow.ellipsis)),
                                    SizedBox(width: 150, child: Text(pendaftar['nama'] ?? '', style: TextStyle(fontSize: isMobile ? 12 : 14), overflow: TextOverflow.ellipsis)),
                                    SizedBox(width: 120, child: Text(pendaftar['telp'] ?? '', style: TextStyle(fontSize: isMobile ? 12 : 14), overflow: TextOverflow.ellipsis)),
                                    SizedBox(
                                      width: 200,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () => _showEditDialog(pendaftar),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text('Edit', style: TextStyle(color: primaryColor, fontSize: isMobile ? 10 : 11)),
                                          ),
                                          TextButton(
                                            onPressed: () => _terimaPendaftar(pendaftar['id']),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text('Terima', style: TextStyle(color: Colors.green, fontSize: isMobile ? 10 : 11)),
                                          ),
                                          TextButton(
                                            onPressed: () => _hapusPendaftar(pendaftar['id']),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text('Hapus', style: TextStyle(color: Colors.red, fontSize: isMobile ? 10 : 11)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: _showTambahDialog,
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: whiteColor),
            )
          : null,
    );
  }
}
