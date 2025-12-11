import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/ganti_password_dialog.dart';
import 'package:login_tes/widgets/edit_keluarga_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      return (json["data"] as Map<String, dynamic>);
    } else {
      throw Exception("Gagal memuat profil (${res.statusCode})");
    }
  }

  String _getRoleTitle(String? role) {
    switch (role) {
      case "rt":
        return "Profil Ketua RT";
      case "rw":
        return "Profil Ketua RW";
      case "security":
        return "Profil Security";
      default:
        return "Profil Warga";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Terjadi kesalahan: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("Data profil tidak tersedia"));
            }

            final data = snapshot.data!;
            return _buildBody(context, data);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> data) {
    final role = data["role"];
    final name = data["name"];
    final gender = data["gender"];
    final phone = data["phone"];
    final address = data["address"];
    final families = (data["families"] ?? []) as List<dynamic>;

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
                  backgroundColor: whiteColor,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role
                    Text(
                      _getRoleTitle(role),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/images/avatar.jpg',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (name ?? 'Nama tidak tersedia').toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text((gender ?? 'Jenis kelamin tidak tersedia').toString()),
                              Text((phone ?? 'Nomor tidak tersedia').toString()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Profile Keluarga",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final updated = await showDialog(
                              context: context,
                              builder: (context) => const EditKeluargaPage(),
                            );
                            if (updated == true) {
                              setState(() {
                                _profileFuture = _fetchProfile();
                              });
                            }
                          },
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Anggota keluarga",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),

                          if (families.isEmpty)
                            const Text("Belum ada anggota keluarga"),
                          for (var f in families)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text((f["nama"] ?? 'Nama anggota').toString()),
                                Text((f["hubungan"] ?? 'Hubungan tidak tersedia').toString()),
                              ],
                            ),

                          const SizedBox(height: 12),
                          const Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text((address ?? 'Alamat belum tersedia').toString()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Edit Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const EditPasswordDialog(),
                          );
                        },
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}