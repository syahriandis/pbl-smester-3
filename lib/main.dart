import 'package:flutter/material.dart';

// FRONTEND (WARGA)
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/layanan_surat_page.dart';
import 'pages/layanan_pengaduan_page.dart' as LayananPengaduanFrontend;
import 'pages/layanan_administrasi_page.dart';

// SECURITY
import 'pages/dashboard_security_page.dart';
import 'pages/layanan_pengaduan_warga_page.dart';
import 'pages/layanan_administrasi_security.dart';

// RT & RW (SAMA)
import 'pages/dashboard_page_rt.dart';
import 'pages/riwayat_page_rt.dart';
import 'pages/layanan_surat_page_rt.dart';
import 'pages/layanan_pengaduan_page_rt.dart' as LayananPengaduanRT;
import 'pages/layanan_administrasi_page_rt.dart';

// UNIVERSAL PROFILE PAGE
import 'pages/profile_page.dart';

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

        // ✅ DASHBOARD WARGA
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardPage(
            token: args['token'],
            role: args['role'],
          );
        },

      '/layananPengaduan': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return LayananPengaduanFrontend.LayananPengaduanPage(
          token: args['token'],
          role: args['role'],
        );
      },

      '/layananAdministrasi': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return LayananAdministrasiPage(
          token: args['token'],
          role: args['role'],
        );
      },

       '/layananPengaduanWarga': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananPengaduanWargaPage(
            token: args['token'],
            role: args['role'],
          );
        },

        '/layananAdministrasiSecurity': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananAdministrasiSecurityPage(
            token: args['token'],
            role: args['role'],
          );
        },

        // ✅ DASHBOARD RT / RW (SAMA)
        '/rtDashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardPageRT(
            tokenRT: args['tokenRT'],
            role: args['role'], // ✅ bisa "rt" atau "rw"
          );
        },

        '/riwayatRT': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RiwayatPageRT(
            tokenRT: args['tokenRT'],
            role: args['role'],
          );
        },

        '/layananPengaduanRT': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananPengaduanRT.LayananPengaduanPageRT(
            tokenRT: args['tokenRT'],
            role: args['role'],
          );
        },

        '/layananAdministrasiRT': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LayananAdministrasiPageRT(
            tokenRT: args['tokenRT'],
            role: args['role'],
          );
        },

        // ✅ UNIVERSAL PROFILE PAGE
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProfilePage(
            token: args['token'] ?? args['tokenRT'],
            role: args['role'],
          );
        },
      },

      // ✅ ROUTE DINAMIS UNTUK SURAT
      onGenerateRoute: (settings) {
        if (settings.name == '/layananSurat') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => LayananSuratPage(
              role: args['role'],
              token: args['token'],
            ),
          );
        }

        if (settings.name == '/layananSuratRT') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => LayananSuratPageRT(
              tokenRT: args['tokenRT'],
              role: args['role'], // ✅ RT atau RW
            ),
          );
        }

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
      body: const Center(
        child: Text(
          '404: Halaman Tidak Ditemukan',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}