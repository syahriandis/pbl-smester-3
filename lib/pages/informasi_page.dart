import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:login_tes/constants/colors.dart';

// Layouts
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/main_layout_security.dart';

// Widgets
import 'package:login_tes/widgets/info_card_widget.dart';
import 'package:login_tes/widgets/info_detail_dialog.dart';

class InformasiPage extends StatefulWidget {
  final String token;
  final String role;

  const InformasiPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  List<Map<String, dynamic>> _listInformasi = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  // =============================
  // LOAD INFORMASI (GET)
  // =============================
  Future<void> _loadInformasi() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/informasi'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;

        setState(() {
          _listInformasi =
              data.map((e) => Map<String, dynamic>.from(e)).toList();

          _unreadCount =
              _listInformasi.where((e) => e['is_read'] == 0).length;

          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat informasi');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // =============================
  // MARK AS READ (POST)
  // =============================
  Future<void> _markAsRead(int id) async {
    try {
      await http.post(
        Uri.parse('http:localhost:8000/api/informasi/$id/read'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );
    } catch (_) {}
  }

  void _openDetail(Map<String, dynamic> info) async {
    if (info['is_read'] == 0) {
      await _markAsRead(info['id']);

      setState(() {
        info['is_read'] = 1;
        _unreadCount--;
      });
    }

    showInfoDetailDialog(context, info);
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (widget.role == "security") {
      return MainLayoutSecurity(
        selectedIndex: 2,
        token: widget.token,
        role: widget.role,
        child: body,
      );
    }

    return MainLayout(
      selectedIndex: 2,
      token: widget.token,
      role: widget.role,
      child: body,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.85)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 44),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.role == "security"
                          ? "Informasi Security"
                          : "Informasi Warga",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$_unreadCount Baru",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: primaryColor),
                  )
                : _listInformasi.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada informasi",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInformasi,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _listInformasi.length,
                          itemBuilder: (context, index) {
                            final info = _listInformasi[index];

                            return InfoCardWidget(
                              imagePath: info['image'] ?? '',
                              title: info['title'] ?? '-',
                              subtitle: info['location'] ?? '-',
                              date: info['date'],
                              isRead: info['is_read'] == 1,
                              onTap: () => _openDetail(info),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
