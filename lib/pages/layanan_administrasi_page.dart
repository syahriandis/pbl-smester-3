import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout.dart';
import 'package:login_tes/widgets/ganti_password_dialog.dart';


class LayananAdministrasiPage extends StatelessWidget {
  const LayananAdministrasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 0,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
          )
        ],
      ),
    );
  }
}
