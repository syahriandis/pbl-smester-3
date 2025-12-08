import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/utils/user_storage.dart';
import 'package:login_tes/pages/login_page.dart';
import 'package:login_tes/pages/admin_pendaftaran_page.dart';
import 'package:login_tes/pages/admin_pengaduan_page.dart';
import 'package:login_tes/pages/admin_pengajuan_surat_page.dart';
import 'package:login_tes/pages/admin_user_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  // State untuk menentukan halaman yang ditampilkan
  // 'dashboard', 'pendaftaran', 'pengaduan', 'user'
  String _currentPage = 'dashboard';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Map index ke halaman
      switch (index) {
        case 0:
          _currentPage = 'dashboard';
          break;
        case 1:
          _currentPage = 'pendaftaran';
          break;
        case 2:
          _currentPage = 'user';
          break;
      }
    });
  }

  void _navigateFromDashboard(String page) {
    setState(() {
      _currentPage = page;
      // Update selected index untuk highlight menu yang sesuai
      if (page == 'pendaftaran') {
        _selectedIndex = 1;
      } else if (page == 'pengaduan') {
        // Pengaduan tidak ada di sidebar, tetap di index 0 (Dashboard)
        _selectedIndex = 0;
      } else if (page == 'pengajuan_surat') {
        // Pengajuan Surat tidak ada di sidebar, tetap di index 0 (Dashboard)
        _selectedIndex = 0;
      } else {
        // Reset ke dashboard jika page tidak dikenali
        _selectedIndex = 0;
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: greyColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                UserStorage.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: whiteColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar() {
    final profile = UserStorage.getCurrentUserProfile();
    final nama = profile?.nama ?? 'Admin';

    return Container(
      width: 250,
      color: primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage('assets/images/avatar.jpg'),
              backgroundColor: whiteColor,
            ),
            const SizedBox(height: 12),
            // Nama Admin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                nama,
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 40),
            // Menu Items
            _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
            _buildMenuItem(1, Icons.person_add, 'Pendaftaran'),
            _buildMenuItem(2, Icons.people, 'User'),
            const Spacer(),
            // Logout
            InkWell(
              onTap: () {
                Navigator.pop(context); // Tutup drawer jika mobile
                _showLogoutDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: whiteColor, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        _onItemTapped(index);
        // Tutup drawer jika mobile
        if (MediaQuery.of(context).size.width < 768) {
          Navigator.pop(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? whiteColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: whiteColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Tampilkan halaman berdasarkan _currentPage
    switch (_currentPage) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'pengaduan':
        return const AdminPengaduanPage();
      case 'pengajuan_surat':
        return const AdminPengajuanSuratPage();
      case 'user':
        return const AdminUserPage();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 24,
          isMobile ? 16 : 0,
          isMobile ? 16 : 24,
          isMobile ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: isMobile ? 20 : 24),
            // Akses Cepat - Tombol Pengajuan dan Pengaduan (Dipindah ke atas)
            const Text(
              'Akses Cepat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            // Tombol Akses Cepat - Selalu horizontal (menyamping)
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    'Pengaduan',
                    Icons.report_problem,
                    Colors.orange,
                    () => _navigateFromDashboard('pengaduan'),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: _buildQuickAccessButton(
                    'Pengajuan Surat',
                    Icons.description,
                    Colors.green,
                    () => _navigateFromDashboard('pengajuan_surat'),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 24 : 32),
            // Statistik Cards - Responsive untuk mobile
            LayoutBuilder(
              builder: (context, constraints) {
                // Jika lebar kurang dari 600, gunakan Column (mobile)
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildStatCard('Total Pendaftaran', '0', Icons.person_add, Colors.blue),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildStatCard('Total Pengaduan', '0', Icons.report_problem, Colors.orange),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildStatCard('Total User', '0', Icons.people, Colors.green),
                    ],
                  );
                } else {
                  // Desktop - Row horizontal
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total Pendaftaran', '0', Icons.person_add, Colors.blue),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: _buildStatCard('Total Pengaduan', '0', Icons.report_problem, Colors.orange),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: _buildStatCard('Total User', '0', Icons.people, Colors.green),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(String title, IconData icon, Color color, VoidCallback onTap) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isMobile ? 40 : 48),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: isMobile ? 28 : 32),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: greyColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout untuk mobile
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    if (isMobile) {
      // Mobile: Gunakan drawer untuk sidebar
      return Scaffold(
        drawer: Drawer(
          width: 250,
          child: _buildSidebar(),
        ),
        body: Container(
          color: Colors.grey.shade100,
          child: _buildContent(),
        ),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Dashboard Admin', style: TextStyle(color: whiteColor)),
          iconTheme: const IconThemeData(color: whiteColor),
        ),
      );
    } else {
      // Desktop: Sidebar tetap terlihat
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                alignment: Alignment.topLeft,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      );
    }
  }
}

