import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/pages/dashboard_page.dart';
import 'package:login_tes/pages/riwayat_page.dart';
import 'package:login_tes/pages/informasi_page.dart';
import 'package:login_tes/pages/profile_page.dart';

class MainLayout extends StatefulWidget {
  final int selectedIndex;
  final Widget child;

  const MainLayout({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onItemTapped(int index) {
    if (index == widget.selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const RiwayatPage();
        break;
      case 2:
        page =  InformasiPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        page = const DashboardPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget buildNavIcon(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 221, 221),
      body: widget.child,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: BottomNavigationBar(
              iconSize: 28,
              selectedItemColor: secondaryColor,
              unselectedItemColor: greyColor,
              currentIndex: widget.selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: buildNavIcon('assets/icons/home.svg', greyColor),
                  activeIcon:
                      buildNavIcon('assets/icons/home.svg', secondaryColor),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: buildNavIcon('assets/icons/history.svg', greyColor),
                  activeIcon:
                      buildNavIcon('assets/icons/history.svg', secondaryColor),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: buildNavIcon('assets/icons/info.svg', greyColor),
                  activeIcon:
                      buildNavIcon('assets/icons/info.svg', secondaryColor),
                  label: 'Informasi',
                ),
                BottomNavigationBarItem(
                  icon: buildNavIcon('assets/icons/profile.svg', greyColor),
                  activeIcon:
                      buildNavIcon('assets/icons/profile.svg', secondaryColor),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
