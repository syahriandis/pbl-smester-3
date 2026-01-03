import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatelessWidget {
  final String token;
  final String role;

  const DashboardPage({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    print("TOKEN DARI LOGIN (DASHBOARD): $token");
    print("ROLE DARI LOGIN (DASHBOARD): $role");

    return MainLayout(
      selectedIndex: 0,
      token: token,
      role: role,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Greeting dinamis sesuai role
    final String greetingTitle = role == "rw"
        ? "Selamat Datang Ketua RW 01"
        : role == "rt"
            ? "Selamat Datang Ketua RT 01"
            : "Selamat Datang Warga";

    return SafeArea(
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logoputih.png', height: 50),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          const AssetImage('assets/images/avatar.jpg'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  greetingTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
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
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Forum Komunikasi Warga (tampilan khusus hijau)
                    _buildServiceCard(
                      context: context,
                      icon: SvgPicture.asset(
                        'assets/icons/whatsapp.svg',
                        width: 32,
                        height: 32,
                      ),
                      title: 'Forum Komunikasi',
                      subtitle: 'Bergabung di grup WhatsApp warga',
                      onTap: () async {
                        const whatsappUrl =
                            'https://chat.whatsapp.com/ER0GjJkTUCl2NaLU7D9eNi'; 
                        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                          await launchUrl(
                            Uri.parse(whatsappUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tidak dapat membuka WhatsApp')),
                          );
                        }
                      },
                      backgroundColor: primaryColor,
                      titleColor: whiteColor,
                      subtitleColor: Colors.white70,
                    ),

                    const SizedBox(height: 24),

                    // ✅ Layanan Surat
                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/pengajuansurat.png'),
                        width: 32,
                      ),
                      title: 'Layanan Surat',
                      subtitle: 'Pengajuan surat dengan mengisi form',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananSurat',
                          arguments: {
                            'role': role,
                            'token': token,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ✅ Layanan Pengaduan
                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/pengaduan.png'),
                        width: 32,
                      ),
                      title: 'Layanan Pengaduan',
                      subtitle: 'Forum pengaduan dengan mengisi form',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananPengaduan',
                          arguments: {
                            'role': role,
                            'token': token,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ✅ Layanan Administrasi
                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/administrasi.png'),
                        width: 32,
                      ),
                      title: 'Layanan Administrasi',
                      subtitle: 'Dapat membayar uang iuran dan sebagainya',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananAdministrasi',
                          arguments: {
                            'role': role,
                            'token': token,
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

  // Service Card reusable
  Widget _buildServiceCard({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color backgroundColor = whiteColor,
    Color titleColor = primaryColor,
    Color subtitleColor = Colors.grey,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
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
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: backgroundColor == primaryColor
                      ? whiteColor
                      : primaryColor,
                  size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
