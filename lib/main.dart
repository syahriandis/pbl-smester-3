import 'package:flutter/material.dart';
import 'package:login_tes/pages/login_page.dart';
import 'package:login_tes/pages/dashboard_page.dart';
import 'package:login_tes/pages/dashboard_page_rt.dart';
import 'package:login_tes/pages/riwayat_page_rt.dart';
import 'package:login_tes/pages/profile_page_rt.dart';
import 'package:login_tes/pages/layanan_surat_page.dart';
import 'package:login_tes/pages/layanan_pengaduan_page.dart'
    as LayananPengaduanPage;
import 'package:login_tes/pages/layanan_administrasi_page.dart';
import 'package:login_tes/pages/layanan_administrasi_page_rt.dart';
import 'package:login_tes/pages/layanan_pengaduan_page_rt.dart'
    as LayananPengaduanPageRT;
import 'package:login_tes/pages/layanan_surat_page_rt.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF164E47)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/layananSurat': (context) => const LayananSuratPage(),
        '/layananPengaduan': (context) =>
            const LayananPengaduanPage.LayananPengaduanPage(),
        '/layananAdministrasi': (context) => const LayananAdministrasiPage(),
        '/rtDashboard': (context) => const DashboardPageRT(),
        '/riwayatRT': (context) => const RiwayatPageRT(),
        '/profileRT': (context) => const ProfilePageRT(),
        '/layananSuratRT': (context) => const LayananSuratPageRT(),
        '/layananPengaduanRT': (context) =>
            LayananPengaduanPageRT.LayananPengaduanPageRT(),
        '/layananAdministrasiRT': (context) =>
            const LayananAdministrasiPageRT(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
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
