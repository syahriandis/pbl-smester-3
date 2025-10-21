import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/ganti_password_dialog.dart';


class LayananPengaduanPage extends StatelessWidget {
  const LayananPengaduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layanan Surat')),
      body: const Center(child: Text('Ini halaman Layanan Pengaduan')),
    );
  }
}
