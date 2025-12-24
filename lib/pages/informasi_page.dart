import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:login_tes/constants/colors.dart';

// Layouts
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/main_layout_security.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';

// Widgets
import 'package:login_tes/widgets/info_detail_dialog.dart';
import 'package:login_tes/widgets/info_create_dialog.dart';

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
  List<dynamic> informasiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  Future<void> _loadInformasi() async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/informasi"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        informasiList = body["data"];
      });
    } else {
      setState(() {
        informasiList = [];
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget layout;

    if (widget.role == "security") {
      layout = MainLayoutSecurity(
        selectedIndex: 2,
        token: widget.token,
        role: widget.role,
        child: _buildBody(),
      );
    } else if (widget.role == "rt") {
      layout = MainLayoutRT(
        selectedIndex: 2,
        tokenRT: widget.token,
        role: widget.role,
        child: _buildBody(),
      );
    } else {
      layout = MainLayout(
        selectedIndex: 2,
        token: widget.token,
        role: widget.role,
        child: _buildBody(),
      );
    }

    return layout;
  }

  Widget _buildBody() {
    final canManage = widget.role == "rt" || widget.role == "rw";

    return SafeArea(
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 50),
                Text(
                  widget.role == "security"
                      ? "Informasi Security"
                      : widget.role == "rt"
                          ? "Informasi RT"
                          : "Informasi Warga",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // BODY
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
                  // TITLE + BUTTON TAMBAH
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
                      if (canManage)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final refresh = await showCreateInformasiDialog(
                              context: context,
                              token: widget.token,
                            );
                            if (refresh == true) _loadInformasi();
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text("Tambah"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // LIST INFORMASI
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : informasiList.isEmpty
                            ? const Center(
                                child: Text(
                                  "Belum ada informasi.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadInformasi,
                                child: ListView.builder(
                                  itemCount: informasiList.length,
                                  itemBuilder: (context, index) {
                                    final info = informasiList[index];
                                    final image = info["image"] ?? "";
                                    final imageUrl = image.isNotEmpty
                                        ? "http://127.0.0.1:8000/storage/$image"
                                        : null;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      child: InkWell(
                                        onTap: () => showInfoDetailDialog(
                                          context,
                                          info,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (imageUrl != null)
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top: Radius.circular(12)),
                                                child: Image.network(
                                                  imageUrl,
                                                  height: 180,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                    height: 180,
                                                    color: Colors.grey.shade200,
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                        "Gambar tidak tersedia"),
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    info["title"] ?? "",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.place,
                                                          size: 16,
                                                          color: Colors.grey),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        info["location"] ?? "-",
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(info["description"] ?? ""),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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