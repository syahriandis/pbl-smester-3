import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_security.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class DashboardSecurityPage extends StatefulWidget {
  final String token;
  final String role;

  const DashboardSecurityPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<DashboardSecurityPage> createState() => _DashboardSecurityPageState();
}

class _DashboardSecurityPageState extends State<DashboardSecurityPage> {
  String? _userPhoto;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final userData = result['data'];
        setState(() {
          _userPhoto = userData['photo'];
          _userName = userData['name'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openWhatsAppGroup() async {
    final Uri whatsappUrl = Uri.parse('https://chat.whatsapp.com/IAj4pHWayaYCeGQUUu6lfs');
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Tidak dapat membuka WhatsApp')),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) {
      return 'assets/images/avatar.jpg';
    }
    if (photo.startsWith('http')) {
      return photo;
    }
    return 'http://localhost:8000/api/storage/$photo';
  }

  @override
  Widget build(BuildContext context) {
    print("TOKEN SECURITY (DASHBOARD): ${widget.token}");
    print("ROLE SECURITY (DASHBOARD): ${widget.role}");

    return MainLayoutSecurity(
      selectedIndex: 0,
      token: widget.token,
      role: widget.role,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logoputih.png', height: 50),
                    _userPhoto != null && _userPhoto!.isNotEmpty
                        ? CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.network(
                                _getPhotoUrl(_userPhoto),
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, color: primaryColor);
                                },
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: primaryColor, size: 24),
                          ),
                  ],
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: whiteColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang, Security',
                            style: TextStyle(
                              fontSize: 14,
                              color: whiteColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userName ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: whiteColor,
                            ),
                          ),
                        ],
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
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Forum komunikasi - CLICKABLE
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openWhatsAppGroup,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF25D366).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/whatsapp.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Forum Komunikasi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Grup WhatsApp Warga',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: const [
                        Icon(Icons.security, color: primaryColor, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Layanan Security',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/pengajuansurat.png'),
                        width: 32,
                      ),
                      title: 'Layanan Surat',
                      subtitle: 'Pengajuan surat dengan mengisi form',
                      color: const Color(0xFF4A90E2),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananSurat',
                          arguments: {
                            'role': widget.role,
                            'token': widget.token,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/administrasi.png'),
                        width: 32,
                      ),
                      title: 'Layanan Administrasi',
                      subtitle: 'Dapat membayar uang iuran dan sebagainya',
                      color: const Color(0xFF27AE60),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananAdministrasi',
                          arguments: {
                            'token': widget.token,
                            'role': widget.role,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildServiceCard(
                      context: context,
                      icon: const Icon(Icons.report, size: 32, color: Color(0xFFE74C3C)),
                      title: 'Layanan Pengaduan Warga',
                      subtitle: 'Melihat semua pengaduan warga',
                      color: const Color(0xFFE74C3C),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananPengaduanSecurity',
                          arguments: {
                            'role': widget.role,
                            'token': widget.token,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}