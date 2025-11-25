import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_security.dart';
import 'package:login_tes/widgets/info_card_widget.dart';
import 'package:login_tes/widgets/info_detail_dialog.dart';

class InformasiSecurityPage extends StatelessWidget {
  const InformasiSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayoutSecurity(
      selectedIndex: 2, // tetap pakai index untuk tab security
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final List<Map<String, String>> informasiList = List.generate(
      20,
      (index) => {
        'image': 'assets/images/maulidd.jpg',
        'title': 'Maulid Nabi ke-${index + 1}',
        'subtitle': 'Masjid Al Ikhlas Bengkong, Jl. Sudirman',
      },
    );

    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 50),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Security",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: informasiList.length,
                      itemBuilder: (context, index) {
                        final info = informasiList[index];
                        return GestureDetector(
                          onTap: () => showInfoDetailDialog(context, info),
                          child: InfoCardWidget(
                            imagePath: info['image']!,
                            title: info['title']!,
                            subtitle: info['subtitle']!,
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
