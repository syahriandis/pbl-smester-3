import 'package:flutter/material.dart';

//Frondend
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/layanan_surat_page.dart';
import 'pages/layanan_pengaduan_page.dart'
    as LayananPengaduanFrontend;
import 'pages/layanan_administrasi_page.dart';

//security
import 'pages/dashboard_security_page.dart';
import 'pages/layanan_pengaduan_warga_page.dart';
import 'pages/layanan_administrasi_security.dart';
import 'pages/layanan_surat_security_page.dart';
import 'pages/profile_security_page.dart';


//rt
import 'package:login_tes/pages/dashboard_page_rt.dart';
import 'package:login_tes/pages/riwayat_page_rt.dart';
import 'package:login_tes/pages/profile_page_rt.dart';
import 'package:login_tes/pages/layanan_surat_page_rt.dart';
import 'package:login_tes/pages/layanan_pengaduan_page_rt.dart'
    as LayananPengaduanMain;
import 'package:login_tes/pages/layanan_pengaduan_page_rt.dart'
    as LayananPengaduanRT;
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
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color(0xFF164E47)),
        useMaterial3: true,
      ),

      // ROUTE DEFAULT
      initialRoute: '/login',

      routes: {
        // ---------- FRONTEND ----------
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/layananSurat': (context) => const LayananSuratPage(),
        '/layananPengaduan': (context) =>const LayananPengaduanFrontend.LayananPengaduanPage(),  
        '/layananAdministrasi': (context) => const LayananAdministrasiPage(),
       

            
        // ---------- SECURITY ----------
        '/dashboardSecurity': (context) => const DashboardSecurityPage(),
        '/layananPengaduanWarga': (context) =>  const LayananPengaduanWargaPage(),
        '/LayananAdministrasiSecurity': (context) => const LayananAdministrasiSecurityPage(),
        '/layananSuratSecurity': (context) => const LayananSuratSecurityPage(),
        '/profileSecurity': (context) => const ProfileSecurityPage(),
            
        
           

        // ---------- RT ----------
        '/rtDashboard': (context) => const DashboardPageRT(),
        '/riwayatRT': (context) => const RiwayatPageRT(),
        '/profileRT': (context) => const ProfilePageRT(),
        '/layananSuratRT': (context) => const LayananSuratPageRT(),
        '/layananPengaduanRT': (context) =>
            LayananPengaduanRT.LayananPengaduanPageRT(),
        '/layananAdministrasiRT': (context) =>
            const LayananAdministrasiPageRT(),
      },

      // ---------- 404 HANDLER ----------
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
      },
    );
  }
}

// ====== PAGE 404 ======
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
