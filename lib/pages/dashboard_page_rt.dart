import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';

class DashboardPageRT extends StatelessWidget {
  final String tokenRT;
  final String role;

  const DashboardPageRT({
    super.key,
    required this.tokenRT,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    print("TOKEN RT (DASHBOARD RT): $tokenRT");

    return MainLayoutRT(
      selectedIndex: 0,
      tokenRT: tokenRT,
      role: role,
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
                      backgroundImage: const AssetImage('assets/images/avatar.jpg'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selamat Datang Ketua RT 01',
                  style: TextStyle(
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
                    // FORUM
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/whatsapp.svg',
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Forum Komunikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: const [
                        Icon(Icons.people_alt, color: primaryColor, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Layanan RT',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ✅ LAYANAN SURAT RT (KIRIM TOKEN RT)
                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/pengajuansurat.png'),
                        width: 32,
                      ),
                      title: 'Layanan Surat',
                      subtitle: 'Pengajuan surat untuk keperluan warga',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananSuratRT',
                          arguments: {
                            'tokenRT': tokenRT,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ✅ LAYANAN PENGADUAN RT
                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/pengaduan.png'),
                        width: 32,
                      ),
                      title: 'Layanan Pengaduan',
                      subtitle: 'Pengaduan terkait masalah di lingkungan RT',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananPengaduanRT',
                          arguments: {
                            'tokenRT': tokenRT,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ✅ LAYANAN ADMINISTRASI RT
                    _buildServiceCard(
                      context: context,
                      icon: const Image(
                        image: AssetImage('assets/images/administrasi.png'),
                        width: 32,
                      ),
                      title: 'Layanan Administrasi',
                      subtitle: 'Pembayaran iuran dan administrasi RT',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/layananAdministrasiRT',
                          arguments: {
                            'tokenRT': tokenRT,
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}