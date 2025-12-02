import 'package:flutter/material.dart';

// === IMPORT DARI FRONTEND ===
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/layanan_surat_page.dart';
import 'pages/layanan_pengaduan_page.dart' as LayananPengaduanPageFrontend;
import 'pages/layanan_administrasi_page.dart';
import 'pages/dashboard_security_page.dart';
import 'pages/layanan_pengaduan_Warga_page.dart';

// === IMPORT DARI MAIN ===
import 'package:login_tes/pages/dashboard_page_rt.dart';
import 'package:login_tes/pages/riwayat_page_rt.dart';
import 'package:login_tes/pages/layanan_surat_page_rt.dart';
import 'package:login_tes/pages/layanan_pengaduan_page.dart'
    as LayananPengaduanPageMain;
import 'package:login_tes/pages/layanan_pengaduan_page_rt.dart'
    as LayananPengaduanPageRT;
import 'package:login_tes/pages/layanan_administrasi_page_rt.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF164E47),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        // === ROUTE FRONTEND ===
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/layananSurat': (context) => const LayananSuratPage(),
        '/layananPengaduan': (context) =>
            const LayananPengaduanPageFrontend.LayananPengaduanPage(),
        '/layananAdministrasi': (context) => const LayananAdministrasiPage(),

        // Security
        '/DashboardSecurity': (context) => const DashboardSecurityPage(),
        '/layananPengaduanWarga': (context) =>
            const LayananPengaduanWargaPage(),

        // === ROUTE RT (dari main) ===
        '/rtDashboard': (context) => const DashboardPageRT(),
        '/riwayatRT': (context) => const RiwayatPageRT(),
        '/layananSuratRT': (context) => const LayananSuratPageRT(),
        '/layananPengaduanRT': (context) =>
            LayananPengaduanPageRT.LayananPengaduanPageRT(),
        '/layananAdministrasiRT': (context) =>
            const LayananAdministrasiPageRT(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
      },
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404: Halaman Tidak Ditemukan')),
    );
  }
}
