import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/layanan_surat_page.dart';
import 'pages/layanan_pengaduan_page.dart';
import 'pages/layanan_administrasi_page.dart';

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
        '/layananPengaduan': (context) => const LayananPengaduanPage(),
        '/layananAdministrasi': (context) => const LayananAdministrasiPage(),
      },
    );
  }
}
