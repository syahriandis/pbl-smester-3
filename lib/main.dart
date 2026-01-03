import 'package:flutter/material.dart';

// ========== UNIVERSAL PAGES (untuk semua role) ==========
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/layanan_administrasi_page.dart'; // ✅ UNIFIED
import 'pages/riwayat_page.dart'; // ✅ UNIFIED (yang baru lu bikin)

// ========== WARGA PAGES ==========
import 'pages/dashboard_page.dart';
import 'pages/layanan_surat_page.dart';
import 'pages/layanan_pengaduan_page.dart';

// ========== SECURITY PAGES ==========
import 'pages/dashboard_security_page.dart';
import 'pages/layanan_pengaduan_security_page.dart';

// ========== RT/RW PAGES ==========
import 'pages/dashboard_page_rt.dart';
import 'pages/layanan_surat_page_rt.dart';
import 'pages/layanan_pengaduan_page_rt.dart' as LayananPengaduanRT;
import 'package:intl/date_symbol_data_local.dart'; // TAMBAHKAN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // TAMBAHKAN
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hawaii Garden',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF164E47)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        // ========== AUTH ==========
        '/login': (context) => const LoginPage(),

        // ========== WARGA ROUTES ==========
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardPage(
            token: args['token'],
            role: args['role'],
          );
        },

        '/layananPengaduan': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananPengaduanPage(
            token: args['token'],
            role: args['role'],
          );
        },

        // ========== SECURITY ROUTES ==========
        '/dashboardSecurity': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardSecurityPage(
            token: args['token'],
            role: args['role'],
          );
        },

        '/layananPengaduanSecurity': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananPengaduanSecurityPage(
            token: args['token'],
            role: args['role'],
          );
        },

        // ========== RT/RW ROUTES ==========
        '/rtDashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardPageRT(
            tokenRT: args['tokenRT'] ?? args['token'],
            role: args['role'],
          );
        },

        '/layananPengaduanRT': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananPengaduanRT.LayananPengaduanPageRT(
            tokenRT: args['tokenRT'] ?? args['token'],
            role: args['role'],
          );
        },

        // ========== UNIVERSAL ROUTES (semua role) ==========

        '/layananAdministrasi': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananAdministrasiPage(
            token: args['token'] ?? args['tokenRT'] ?? '',
            role: args['role'] ?? 'warga',
          );
        },

        // ✅ RIWAYAT (UNIFIED)
        '/riwayat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RiwayatPage(
            token: args['token'] ?? args['tokenRT'] ?? '',
            role: args['role'] ?? 'warga',
          );
        },

        // ✅ PROFILE (UNIFIED)
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProfilePage(
            token: args['token'] ?? args['tokenRT'] ?? '',
            role: args['role'] ?? 'warga',
          );
        },
      },

      // ========== DYNAMIC ROUTES ==========
      onGenerateRoute: (settings) {
        // Layanan Surat Warga
        if (settings.name == '/layananSurat') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => LayananSuratPage(
              role: args['role'],
              token: args['token'],
            ),
          );
        }

        // Layanan Surat RT/RW
        if (settings.name == '/layananSuratRT') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => LayananSuratPageRT(
              tokenRT: args['tokenRT'] ?? args['token'],
              role: args['role'],
            ),
          );
        }

        // 404 Page
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
      },
    );
  }
}

// ========== 404 PAGE ==========
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tidak Ditemukan'),
        backgroundColor: const Color(0xFF164E47),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Halaman Tidak Ditemukan',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.home),
              label: const Text('Kembali ke Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF164E47),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}