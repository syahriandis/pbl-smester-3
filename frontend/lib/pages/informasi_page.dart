import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login_tes/constants/colors.dart';

// Layouts
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/main_layout_security.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';

// Widgets
import 'package:login_tes/widgets/info_card_widget.dart';
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
      informasiList = [];
    }

    setState(() {
      isLoading = false;
    });
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
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
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
                      Text(
                        widget.role == "security"
                            ? "Informasi Security"
                            : widget.role == "rt"
                                ? "Informasi RT"
                                : "Informasi Warga",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),

                      if (widget.role == "rt" || widget.role == "rw")
                        GestureDetector(
                          onTap: () async {
                            final refresh = await showCreateInformasiDialog(
                              context,
                              _loadInformasi,
                            );
                            if (refresh == true) _loadInformasi();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
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
                            : ListView.builder(
                                itemCount: informasiList.length,
                                itemBuilder: (context, index) {
                                  final info = informasiList[index];
                                  final image = info["image"] ?? "";

                                  return GestureDetector(
                                    onTap: () => showInfoDetailDialog(context, {
                                      "image": image,
                                      "title": info["title"],
                                      "subtitle": info["location"],
                                      "date": info["date"],
                                      "day": info["day"],
                                      "time": info["time"],
                                      "description": info["description"],
                                    }),
                                    child: InfoCardWidget(
                                      imagePath: image.isNotEmpty
                                          ? image
                                          : "assets/images/default.jpg",
                                      title: info["title"],
                                      subtitle: info["location"],
                                    ),
                                  );
                                },
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