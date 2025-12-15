import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_tes/widgets/main_layout_rt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/info_card_widget_rt.dart';
import 'package:login_tes/widgets/info_detail_dialog_rt.dart';
import 'package:login_tes/widgets/info_create_dialog.dart';

class InformasiPageRT extends StatefulWidget {
  final String tokenRT;
  final String role;
  const InformasiPageRT({
    super.key,
    required this.tokenRT,
    required this.role,  
  });


  @override
  State<InformasiPageRT> createState() => _InformasiPageRTState();
}

class _InformasiPageRTState extends State<InformasiPageRT> {
  List<Map<String, dynamic>> _listInformasi = [];
  bool _isLoading = true;
  String userRole = "rt";

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  /// Fetch data dari backend Laravel
  Future<void> _loadInformasi() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/informasi'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _listInformasi = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal memuat informasi (${response.statusCode})");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error memuat informasi: $e")),
        );
      }
    }
  }

  /// Tambah informasi
  void _navigateToAddInfo() async {
    final bool? refresh = await showCreateInformasiDialog(context, _loadInformasi);
    if (refresh == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informasi baru berhasil dibuat.")),
        );
      }
      _loadInformasi();
    }
  }

  /// Hapus informasi
  Future<void> _deleteInformasi(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/informasi/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Informasi berhasil dihapus.")),
          );
        }
        _loadInformasi();
      } else {
        throw Exception("Gagal menghapus informasi (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error hapus informasi: $e")),
        );
      }
    }
  }

  /// Update informasi
  Future<void> _updateInformasi(int id, Map<String, dynamic> updated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/informasi/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updated),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Informasi berhasil diupdate.")),
          );
        }
        _loadInformasi();
      } else {
        throw Exception("Gagal update informasi (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error update informasi: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutRT(
      selectedIndex: 2,
      tokenRT: widget.tokenRT,
      role: widget.role,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 50),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
                ),
              ],
            ),
          ),
          // Body
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
                  // Title + Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar Informasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      if (userRole == "rt" || userRole == "rw")
                        GestureDetector(
                          onTap: _navigateToAddInfo,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "Tambah",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List
                  Expanded(
                    child: _listInformasi.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Belum ada informasi.", style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                ElevatedButton(onPressed: _loadInformasi, child: const Text("Muat Ulang")),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadInformasi,
                            child: ListView.builder(
                              itemCount: _listInformasi.length,
                              itemBuilder: (context, index) {
                                final info = _listInformasi[index];
                                final image = info["image"] ?? "";

                                return InfoCardWidgetRT(
                                  imagePath: image.isNotEmpty ? image : "assets/images/default.jpg",
                                  title: info["title"] ?? "",
                                  subtitle: info["location"] ?? "",
                                  onEdit: () {
                                    showInfoDetailDialog(
                                      context,
                                      info,
                                      (updated) => _updateInformasi(info["id"], updated),
                                      (id) => _deleteInformasi(id),
                                    );
                                  },
                                  onDelete: () => _deleteInformasi(info["id"]),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}