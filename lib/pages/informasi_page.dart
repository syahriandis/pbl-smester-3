import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/main_layout_security.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';
import 'package:login_tes/widgets/info_card_widget.dart';
import 'package:login_tes/widgets/info_detail_dialog.dart';       // popup detail warga
import 'package:login_tes/widgets/info_create_dialog.dart';       // popup create informasi

class InformasiPage extends StatefulWidget {
  const InformasiPage({super.key});

  @override
<<<<<<< HEAD
<<<<<<< HEAD
=======
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  List<dynamic> informasiList = [];
  bool isLoading = true;
  String userRole = ""; // ROLE USER

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadInformasi();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "";
    });
  }

  Future<void> _loadInformasi() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/informasi"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        informasiList = body["data"];
        isLoading = false;
      });
    } else {
      setState(() {
        informasiList = [];
        isLoading = false;
      });
    }
  }

  @override
>>>>>>> parent of 5e86175 (frontend admin)
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 2,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
=======
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  List<dynamic> informasiList = [];
  bool isLoading = true;
  String userRole = "";

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadInformasi();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "";
    });
  }

  Future<void> _loadInformasi() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/informasi"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        informasiList = body["data"];
        isLoading = false;
      });
    } else {
      setState(() {
        informasiList = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Layout sesuai role
    final layout = userRole == "security"
        ? MainLayoutSecurity(selectedIndex: 2, child: _buildBody())
        : MainLayout(selectedIndex: 2, child: _buildBody());

    return layout;
>>>>>>> 30902f8 (menambahkan fitur informasi edit dan hapus buat rt/rw)
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
<<<<<<< HEAD
<<<<<<< HEAD
=======
          // Header
>>>>>>> 30902f8 (menambahkan fitur informasi edit dan hapus buat rt/rw)
=======
          // ================= HEADER =================
>>>>>>> parent of 5e86175 (frontend admin)
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

<<<<<<< HEAD
<<<<<<< HEAD
=======
          // Body
>>>>>>> 30902f8 (menambahkan fitur informasi edit dan hapus buat rt/rw)
=======
          // ================= BODY =================
>>>>>>> parent of 5e86175 (frontend admin)
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
<<<<<<< HEAD
<<<<<<< HEAD
                  const Text(
                    "Informasi Warga",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
=======
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userRole == "security"
                            ? "Informasi Security"
                            : "Informasi Warga",
                        style: const TextStyle(
=======
                  // TITLE + BUTTON CREATE (hanya untuk RT/RW)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Informasi Warga",
                        style: TextStyle(
>>>>>>> parent of 5e86175 (frontend admin)
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
<<<<<<< HEAD
                    ],
>>>>>>> 30902f8 (menambahkan fitur informasi edit dan hapus buat rt/rw)
=======

                      if (userRole == "rt" || userRole == "rw")
                        GestureDetector(
                          onTap: () async {
                            final refresh = await showCreateInformasiDialog(
                                context, _loadInformasi);

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
>>>>>>> parent of 5e86175 (frontend admin)
                  ),

                  const SizedBox(height: 10),

<<<<<<< HEAD
<<<<<<< HEAD
                  Expanded(
                    child: ListView.builder(
                      itemCount: informasiList.length,
                      itemBuilder: (context, index) {
                        final info = informasiList[index];
                        return GestureDetector(
                          onTap: () => showInfoDetailDialog(context, info),
                          child: InfoCardWidget(
                            imagePath: info['image']!,
                            title: info['title']!,
                            subtitle: info['subtitle']!,
=======
                  // List Informasi
                  Expanded(
=======
                  // LIST INFORMASI
                  Expanded(
>>>>>>> parent of 5e86175 (frontend admin)
                    child: informasiList.isEmpty
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
<<<<<<< HEAD
                              String image = info["image"] ?? "";

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
>>>>>>> 30902f8 (menambahkan fitur informasi edit dan hapus buat rt/rw)
                          ),
                        );
                      },
                    ),
                  ),
=======
>>>>>>> parent of 5e86175 (frontend admin)

                              String image = info["image"] ?? "";

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