import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/edit_keluarga_dialog.dart';

// Layouts
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/main_layout_security.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';

// Dialogs
import 'package:login_tes/widgets/ganti_password_dialog.dart';
import 'package:login_tes/widgets/edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  final String role;

  const ProfilePage({
    super.key,
    required this.token,
    required this.role,
  });

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
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8000/api/profile"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      debugPrint("Fetch profile status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        return json["data"];
      } else {
        throw Exception("Gagal memuat profil (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("Error fetch profile: $e");
      rethrow;
    }
  }

  String _getRoleTitle(String role) {
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

    // Helper untuk get foto URL
  String _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) {
      return 'assets/images/avatar.jpg';
    }
    if (photo.startsWith('http')) {
      return photo;
    }
    
    final url = 'http://localhost:8000/api/storage/$photo';
    debugPrint('🖼️ Photo URL: $url'); // ✅ Add this
    return url;
  }

  @override
  Widget build(BuildContext context) {
    Widget layout;

    if (widget.role == "security") {
      layout = MainLayoutSecurity(
        selectedIndex: 3,
        token: widget.token,
        role: widget.role,
        child: _buildBody(),
      );
    } else if (widget.role == "rt" || widget.role == "rw") {
      layout = MainLayoutRT(
        selectedIndex: 3,
        tokenRT: widget.token,
        role: widget.role,
        child: _buildBody(),
      );
    } else {
      layout = MainLayout(
        selectedIndex: 3,
        token: widget.token,
        role: widget.role,
        child: _buildBody(),
      );
    }

    return layout;
  }

  Widget _buildBody() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text("Memuat profil..."),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Terjadi kesalahan: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _profileFuture = _fetchProfile();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Coba Lagi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: whiteColor,
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Data profil tidak tersedia"),
            );
          }

          final data = snapshot.data!;
          final role = data["role"];
          final name = data["name"];
          final nik = data["nik"];
          final gender = data["gender"];
          final phone = data["phone"];
          final address = data["address"];
          final photo = data["photo"];
          final families = (data["families"] ?? []) as List<dynamic>;

          return SafeArea(
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logoputih.png', height: 50),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: whiteColor,
                        child: ClipOval(
                          child: photo != null && photo.toString().isNotEmpty
                              ? Image.network(
                                  _getPhotoUrl(photo.toString()),
                                  fit: BoxFit.cover,
                                  width: 44,
                                  height: 44,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint("Error loading header photo: $error");
                                    return Image.asset(
                                      'assets/images/avatar.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/avatar.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
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
                          // ROLE TITLE WITH EDIT BUTTON
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getRoleTitle(role ?? ""),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final updated = await showDialog(
                                    context: context,
                                    builder: (context) => EditProfileDialog(
                                      token: widget.token,
                                      currentData: data,
                                    ),
                                  );
                                  if (updated == true) {
                                    setState(() {
                                      _profileFuture = _fetchProfile();
                                    });
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Edit"),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // PROFILE CARD
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: photo != null && photo.toString().isNotEmpty
                                      ? Image.network(
                                          _getPhotoUrl(photo.toString()),
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              height: 60,
                                              width: 60,
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            debugPrint("Error loading profile photo: $error");
                                            return Image.asset(
                                              'assets/images/avatar.jpg',
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/avatar.jpg',
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (name ?? 'Nama tidak tersedia').toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.badge, size: 14, color: greyColor),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'NIK: ${(nik ?? 'NIK tidak tersedia').toString()}',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            gender == 'LAKI-LAKI' 
                                                ? Icons.male 
                                                : Icons.female,
                                            size: 14,
                                            color: greyColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (gender ?? 'Jenis kelamin tidak tersedia').toString(),
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 14, color: greyColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            (phone ?? 'Nomor tidak tersedia').toString(),
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // KELUARGA TITLE
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
                              // Semua role bisa edit keluarga
                              TextButton(
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditKeluargaPage(),
                                    ),
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

                          // KELUARGA CARD
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
                                const SizedBox(height: 8),
                                if (families.isEmpty)
                                  const Text("Belum ada anggota keluarga")
                                else
                                  ...families.map((f) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text((f["nama"] ?? 'Nama anggota').toString()),
                                            Text(
                                              (f["hubungan"] ?? 'Hubungan tidak tersedia').toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: greyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                const SizedBox(height: 12),
                                const Text(
                                  "Alamat",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text((address ?? 'Alamat belum tersedia').toString()),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // PASSWORD
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const EditPasswordDialog(),
                                );
                              },
                              child: const Text(
                                "Edit Password",
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }
}